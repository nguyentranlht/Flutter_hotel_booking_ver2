import 'dart:convert';
import 'package:flutter_hotel_booking_ver2/widgets/app_constant.dart';
import 'package:http/http.dart' as http;
import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';
import 'package:flutter_hotel_booking_ver2/routes/api_chat.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelegramBot {
  TeleDart? teledart;
  Map<int, Map<String, dynamic>> bookingData = {}; // Lưu dữ liệu đặt phòng

  TelegramBot();

  Future<void> _init() async {
    try {
      await Firebase.initializeApp(); // Khởi tạo Firebase
      final telegram = Telegram(ApiChat.botToken);
      final me = await telegram.getMe();
      final username = me.username ?? "default_bot";

      teledart = TeleDart(ApiChat.botToken, Event(username));
      _setupCommands();
    } catch (e) {
      print("Lỗi khởi tạo bot: $e");
    }
  }

  Future<void> start() async {
    await _init();
    if (teledart != null) {
      teledart!.start();
      print("Bot Telegram đang chạy...");
    } else {
      print("⚠️ Lỗi: Bot chưa được khởi tạo.");
    }
  }

  void _setupCommands() {
    if (teledart == null) return;

    teledart!.onCommand('start').listen((message) {
      message.reply("Nhập khu vực bạn muốn tìm khách sạn.");
    });

    teledart!.onMessage().listen((message) async {
      int userId = message.chat.id;
      String text = message.text?.trim().toLowerCase() ?? "";

      if (bookingData.containsKey(userId) &&
          bookingData[userId]!["step"] != null) {
        // Nếu user đã chọn phòng và đang nhập thông tin đặt phòng
        _handleBookingProcess(userId, text, message);
      } else if (text.isNotEmpty) {
        List<Map<String, dynamic>> foundHotels =
            await _searchHotelsByKeyword(text);

        if (foundHotels.isNotEmpty) {
          var inlineKeyboard = foundHotels.map((hotel) {
            return [
              InlineKeyboardButton(
                  text: hotel['hotelName'],
                  callbackData: "select_hotel_${hotel['hotelId']}")
            ];
          }).toList();

          message.reply("**Chọn khách sạn tại $text:**",
              replyMarkup: InlineKeyboardMarkup(inlineKeyboard: inlineKeyboard),
              parseMode: "Markdown");
        } else {
          message.reply("Không tìm thấy khách sạn nào tại: $text.",
              parseMode: "Markdown");
        }
      } else {
        message.reply("⚠️ Hãy nhập khu vực bạn muốn tìm khách sạn.");
      }
    });

    teledart!.onCallbackQuery().listen((query) async {
      int userId = query.message!.chat.id;

      if (query.data!.startsWith("select_hotel_")) {
        String hotelId = query.data!.replaceFirst("select_hotel_", "");
        bookingData[userId] = {"hotelId": hotelId};
        List<Map<String, dynamic>> rooms = await _getRoomsByHotelId(hotelId);

        if (rooms.isNotEmpty) {
          var inlineKeyboard = rooms.map((room) {
            return [
              InlineKeyboardButton(
                  text: room['roomName'] +
                      " - " +
                      room['pricePerNight'] +
                      " VND/đêm",
                  callbackData:
                      "select_room_${room['roomId']}_${room['pricePerNight']}"),
            ];
          }).toList();

          teledart!.editMessageReplyMarkup(
              chatId: query.message!.chat.id,
              messageId: query.message!.messageId,
              replyMarkup:
                  InlineKeyboardMarkup(inlineKeyboard: inlineKeyboard));
        } else {
          query.answer(
              text: "⚠️ Không có phòng nào sẵn sàng trong khách sạn này.");
        }
      } else if (query.data!.startsWith("select_room_")) {
        List<String> parts = query.data!.split("_");
        String roomId = parts[2]; // Lấy roomId từ callbackData
        int roomPrice = parts.length > 3 ? int.parse(parts[3]) : 0;
        // Lưu dữ liệu đặt phòng và yêu cầu nhập số lượng khách
        bookingData[userId] = {
          ...bookingData[userId] ?? {}, // Giữ lại dữ liệu cũ
          "roomPrice": roomPrice,
          "roomId": roomId,
          "step": "waiting_for_guest_count"
        };

        teledart!.sendMessage(userId, "Vui lòng nhập số lượng khách:");
      }
    });
  }

  Future<List<Map<String, dynamic>>> _searchHotelsByKeyword(
      String keyword) async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('hotels').get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .where((hotel) =>
              hotel["hotelAddress"].toString().toLowerCase().contains(keyword))
          .toList();
    } catch (e) {
      print("Lỗi truy vấn Firebase: $e");
      return [];
    }
  }

  void _handleBookingProcess(
      int userId, String input, TeleDartMessage message) async {
    if (!bookingData.containsKey(userId)) return;

    var userBooking = bookingData[userId]!;
    String step = userBooking["step"];

    switch (step) {
      case "waiting_for_guest_count":
        if (int.tryParse(input) != null) {
          userBooking["guestCount"] = int.parse(input);
          userBooking["step"] = "waiting_for_checkin_date";
          teledart!.sendMessage(userId, "Nhập ngày nhận phòng (YYYY-MM-DD):");
        } else {
          teledart!
              .sendMessage(userId, "⚠️ Vui lòng nhập số lượng khách hợp lệ.");
        }
        break;

      case "waiting_for_checkin_date":
        userBooking["checkInDate"] = input;
        userBooking["step"] = "waiting_for_checkout_date";
        teledart!.sendMessage(userId, "Nhập ngày trả phòng (YYYY-MM-DD):");
        break;

      case "waiting_for_checkout_date":
        userBooking["checkOutDate"] = input;
        userBooking["step"] = "waiting_for_contact_name";
        teledart!.sendMessage(userId, "Nhập tên của bạn:");
        break;

      case "waiting_for_contact_name":
        userBooking["contactName"] = input;
        userBooking["step"] = "waiting_for_contact_mail";
        teledart!.sendMessage(userId, "Nhập số email liên hệ:");
        break;

      case "waiting_for_contact_mail":
        print("📩 Nhận email từ user: $input"); // Xác nhận bot có nhận email

        if (input.isEmpty || !input.contains("@") || !input.contains(".")) {
          print("⚠️ Email không hợp lệ!");
          teledart!.sendMessage(userId, "⚠️ Vui lòng nhập email hợp lệ:");
          return;
        }

        userBooking["mail"] = input;
        userBooking["step"] = "waiting_for_contact_phone";

        print("✅ Email hợp lệ được lưu: ${userBooking["mail"]}");

        teledart!
            .sendMessage(userId, "Nhập số điện thoại liên hệ:")
            .catchError((e) => print("❌ Lỗi gửi tin nhắn: $e"));
        break;

      case "waiting_for_contact_phone":
        userBooking["contactPhone"] = input;
        String bookingId =
            FirebaseFirestore.instance.collection('booking').doc().id;
        QuerySnapshot<Map<String, dynamic>> userSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .where("email", isEqualTo: userBooking["mail"])
                .limit(1)
                .get();
        String userId = userSnapshot.docs.isNotEmpty
            ? userSnapshot.docs.first.id
            : "unknown_user";
        // // Lưu vào Firestore
        Map<String, dynamic> newBooking = {
          'bookingId': bookingId,
          'paymentIntentId': "paymentIntentId",
          'userId': userId,
          'hotelId': userBooking['hotelId'],
          'roomId': userBooking['roomId'],
          'bookingDate': Timestamp.fromDate(DateTime.now()),
          'checkInDate':
              Timestamp.fromDate(DateTime.parse(userBooking['checkInDate'])),
          'checkOutDate':
              Timestamp.fromDate(DateTime.parse(userBooking['checkInDate'])),
          'numberOfGuests': userBooking['guestCount'],
          'bookingStatus': 'success',
          'totalPrice': userBooking['roomPrice'],
          'paymentStatus': 'success',
          'fullname': userBooking['contactName']
        };
        FirebaseFirestore.instance.collection('booking').add(newBooking);
        // await _saveBookingToFirestore(userBooking);
        print("Đặt phòng: $userBooking");
        // // Gửi xác nhận
        teledart!.sendMessage(
            userId,
            "✅ Đặt phòng thành công!\n"
            "📍 Phòng ID: ${userBooking['roomId']}\n"
            "👥 Số khách: ${userBooking['guestCount']}\n"
            "📅 Nhận phòng: ${userBooking['checkInDate']}\n"
            "📅 Trả phòng: ${userBooking['checkOutDate']}\n"
            "📞 Liên hệ: ${userBooking['contactName']} - ${userBooking['contactPhone']}");

        // Xóa dữ liệu tạm
        bookingData.remove(userId);

        break;
    }
  }

  Future<List<Map<String, dynamic>>> _getRoomsByHotelId(String hotelId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('rooms')
          .where("hotelId", isEqualTo: hotelId)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Lỗi truy vấn phòng: $e");
      return [];
    }
  }

  Future<void> _saveBookingToFirestore(Map<String, dynamic> booking) async {
    try {
      FirebaseFirestore.instance
          .collection('bookings')
          .doc(booking['bookingId'])
          .set(booking);
      // await FirebaseFirestore.instance.collection('booking').add(booking);
      print("✅ Đã lưu đặt phòng vào Firestore: $booking");
    } catch (e) {
      print("❌ Lỗi khi lưu vào Firestore: $e");
    }
  }
}
