import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';
import 'package:flutter_hotel_booking_ver2/routes/api_chat.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelegramBot {
  TeleDart? teledart;

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
      String searchQuery = message.text?.trim().toLowerCase() ?? "";
      if (searchQuery.isNotEmpty) {
        List<Map<String, dynamic>> foundHotels = await _searchHotelsByKeyword(searchQuery);

        if (foundHotels.isNotEmpty) {
          var inlineKeyboard = foundHotels.map((hotel) {
            return [
              InlineKeyboardButton(
                text: hotel['hotelName'],
                callbackData: "select_hotel_${hotel['hotelId']}"
              )
            ];
          }).toList();

          message.reply(
            "**Chọn khách sạn tại $searchQuery:**",
            replyMarkup: InlineKeyboardMarkup(inlineKeyboard: inlineKeyboard),
            parseMode: "Markdown"
          );
        } else {
          message.reply("Không tìm thấy khách sạn nào tại: $searchQuery.", parseMode: "Markdown");
        }
      } else {
        message.reply("⚠️ Hãy nhập khu vực bạn muốn tìm khách sạn.");
      }
    });

    teledart!.onCallbackQuery().listen((query) async {
      if (query.data!.startsWith("select_hotel_")) {
        String hotelId = query.data!.replaceFirst("select_hotel_", "");
        List<Map<String, dynamic>> rooms = await _getRoomsByHotelId(hotelId);

        if (rooms.isNotEmpty) {
          var inlineKeyboard = rooms.map((room) {
            return [
              InlineKeyboardButton(
                text: room['roomName'] + " - " + room['pricePerNight'] + " VND/đêm",
                callbackData: "select_room_${room['roomId']}"
              )
            ];
          }).toList();

          teledart!.editMessageReplyMarkup(
            chatId: query.message!.chat.id,
            messageId: query.message!.messageId,
            replyMarkup: InlineKeyboardMarkup(inlineKeyboard: inlineKeyboard)
          );
        } else {
          query.answer(text: "⚠️ Không có phòng nào sẵn sàng trong khách sạn này.");
        }
      }
    });
  }

  Future<List<Map<String, dynamic>>> _searchHotelsByKeyword(String keyword) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('hotels').get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .where((hotel) => hotel["hotelAddress"].toString().toLowerCase().contains(keyword))
          .toList();
    } catch (e) {
      print("Lỗi truy vấn Firebase: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getRoomsByHotelId(String hotelId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('rooms')
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
}
