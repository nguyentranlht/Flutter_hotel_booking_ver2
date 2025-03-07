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
      print("Lỗi: Bot chưa được khởi tạo.");
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
        message.reply("Hãy nhập khu vực bạn muốn tìm khách sạn.");
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
              text: "Không có phòng nào sẵn sàng trong khách sạn này.");
        }
      } else if (query.data!.startsWith("select_room_")) {
        List<String> parts = query.data!.split("_");
        String roomId = parts[2]; // Lấy roomId từ callbackData
        int roomPrice = parts.length > 3 ? int.parse(parts[3]) : 0;
        // Lưu dữ liệu đặt phòng và yêu cầu nhập số lượng khách
        if (!bookingData.containsKey(userId) || bookingData[userId] == null) {
          print("Lỗi: Dữ liệu khách sạn bị mất khi chọn phòng.");
          return;
        }

        bookingData[userId]!["roomPrice"] = roomPrice;
        bookingData[userId]!["roomId"] = roomId;
        bookingData[userId]!["step"] = "waiting_for_guest_count";

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

  Future<String?> createStripePrice(int amount, String currency) async {
    final url = Uri.parse('https://api.stripe.com/v1/prices');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $secretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'unit_amount': amount.toString(), // Giá tiền
        'currency': currency,
        'product_data[name]':
            'Thanh toán sản phẩm tùy chỉnh', // Tạo sản phẩm mới
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      print("✅ Price ID được tạo: ${jsonResponse['id']}");
      return jsonResponse['id'];
    } else {
      print("❌ Lỗi tạo Price ID: ${response.statusCode} - ${response.body}");
      return null;
    }
  }

  Future<String?> createStripePaymentLink(int amount, String currency) async {
    String? priceId =
        await createStripePrice(amount, currency); // 🔹 Tạo Price ID trước

    if (priceId == null) {
      print("❌ Lỗi: Không thể tạo Price ID!");
      return null;
    }

    final url = Uri.parse('https://api.stripe.com/v1/payment_links');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $secretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'line_items[0][price]': priceId, // ✅ Dùng Price ID mới tạo
        'line_items[0][quantity]': '1',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      print("✅ Payment Link tạo thành công: ${jsonResponse['url']}");
      return jsonResponse['url'];
    } else {
      print(
          "❌ Lỗi tạo Payment Link: ${response.statusCode} - ${response.body}");
      return null;
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
        print("Nhận email từ user: $input"); // Xác nhận bot có nhận email

        userBooking["mail"] = input;

        print("Email hợp lệ được lưu: ${userBooking["mail"]}");
        QuerySnapshot<Map<String, dynamic>> userSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .where("email", isEqualTo: "${userBooking["mail"]}@gmail.com")
                .limit(1)
                .get();
        String UserId = userSnapshot.docs.isNotEmpty
            ? userSnapshot.docs.first.id
            : "unknown_user";
        DateTime start = DateTime.parse(userBooking['checkInDate']);
        DateTime end = DateTime.parse(userBooking['checkOutDate']);

        int differenceInDays = end.difference(start).inDays;

        var perNight = userBooking['roomPrice'] * differenceInDays;
        print(perNight);
        // // Lưu vào Firestore
        Map<String, dynamic> newBooking = {
          'paymentIntentId': "paymentIntentId",
          'userId': UserId,
          'hotelId': userBooking['hotelId'],
          'roomId': userBooking['roomId'],
          'bookingDate': Timestamp.fromDate(DateTime.now()),
          'checkInDate':
              Timestamp.fromDate(DateTime.parse(userBooking['checkInDate'])),
          'checkOutDate':
              Timestamp.fromDate(DateTime.parse(userBooking['checkOutDate'])),
          'numberOfGuests': userBooking['guestCount'],
          'bookingStatus': 'success',
          'totalPrice': perNight.toString(),
          'paymentStatus': 'success',
          'fullname': userBooking['contactName']
        };
        // FirebaseFirestore.instance.collection('booking').add(newBooking);
        await _saveBookingToFirestore(newBooking);
        print("Đặt phòng: $newBooking");
        // // Gửi xác nhận
        // teledart!.sendMessage(
        //     userId,
        //     "Xác nhận thông tin trước khi thanh toán!\n"
        //     "Số khách: ${userBooking['guestCount']}\n"
        //     "Nhận phòng: ${userBooking['checkInDate']}\n"
        //     "Trả phòng: ${userBooking['checkOutDate']}\n"
        //     "Liên hệ: ${userBooking['contactName']} - ${userBooking['mail']}@gmail.com\n"
        //     "Tổng cộng: $perNight VND");

        // Xóa dữ liệu tạm

        userBooking["step"] = "waiting_for_contact_payment";
        int amount = perNight; // Giá trị thanh toán (100,000 VND)

        String? paymentLink = await createStripePaymentLink(amount, 'VND');

        if (paymentLink != null) {
          var paymentKeyboard = InlineKeyboardMarkup(
            inlineKeyboard: [
              [
                InlineKeyboardButton(
                  text: "Thanh toán ngay",
                  url: paymentLink,
                ),
              ],
            ],
          );

          teledart!.sendMessage(
            userId,
            "Xác nhận thông tin trước khi thanh toán!\n"
            "Số khách: ${userBooking['guestCount']}\n"
            "Nhận phòng: ${userBooking['checkInDate']}\n"
            "Trả phòng: ${userBooking['checkOutDate']}\n"
            "Liên hệ: ${userBooking['contactName']} - ${userBooking['mail']}@gmail.com\n"
            "Tổng cộng: $perNight VND",
            replyMarkup: paymentKeyboard,
          );
        } else {
          teledart!.sendMessage(
            message.chat.id,
            "❌ Lỗi khi tạo thanh toán, vui lòng thử lại sau!",
          );
        }
        bookingData.remove(userId);
        break;
      // case "waiting_for_contact_name":
      //   userBooking["contactName"] = input;
      //   userBooking["step"] = "waiting_for_contact_mail";
      //   teledart!.sendMessage(userId, "Nhập số email liên hệ:");
      //   break;
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
      String bookingId =
          FirebaseFirestore.instance.collection('bookings').doc().id; // Tạo ID

      booking['bookingId'] = bookingId; // Gán ID vào booking trước khi lưu

      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId) // Sử dụng ID do Firebase tạo
          .set(booking);

      print("✅ Đã lưu đặt phòng vào Firestore với ID: $bookingId");
    } catch (e) {
      print("❌ Lỗi khi lưu vào Firestore: $e");
    }
  }
}
