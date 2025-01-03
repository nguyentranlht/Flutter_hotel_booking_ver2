import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ver2/modules/bottom_tab/bottom_tab_screen.dart';
import 'package:flutter_hotel_booking_ver2/modules/hotel_booking/filter_screen/filters_screen.dart';
import 'package:flutter_hotel_booking_ver2/modules/hotel_booking/hotel_home_screen.dart';
import 'package:flutter_hotel_booking_ver2/modules/hotel_detailes/hotel_detailes.dart';
import 'package:flutter_hotel_booking_ver2/modules/hotel_detailes/reviews_list_screen.dart';
import 'package:flutter_hotel_booking_ver2/modules/hotel_detailes/room_booking_screen.dart';
import 'package:flutter_hotel_booking_ver2/modules/hotel_detailes/search_screen.dart';
import 'package:flutter_hotel_booking_ver2/modules/login/change_password.dart';
import 'package:flutter_hotel_booking_ver2/modules/login/forgot_password.dart';
import 'package:flutter_hotel_booking_ver2/modules/login/login_screen.dart';
import 'package:flutter_hotel_booking_ver2/modules/login/sign_up_screen.dart';
import 'package:flutter_hotel_booking_ver2/modules/myTrips/finish_review.dart';
import 'package:flutter_hotel_booking_ver2/modules/payment/booking_confirmation_screen.dart';
import 'package:flutter_hotel_booking_ver2/modules/profile/country_screen.dart';
import 'package:flutter_hotel_booking_ver2/modules/profile/currency_screen.dart';
import 'package:flutter_hotel_booking_ver2/modules/profile/edit_profile.dart';
import 'package:flutter_hotel_booking_ver2/modules/profile/hepl_center_screen.dart';
import 'package:flutter_hotel_booking_ver2/modules/profile/how_do_screen.dart';
import 'package:flutter_hotel_booking_ver2/modules/profile/invite_screen.dart';
import 'package:flutter_hotel_booking_ver2/modules/profile/settings_screen.dart';
import 'package:flutter_hotel_booking_ver2/owner/managehotel/addhotel.dart';
import 'package:flutter_hotel_booking_ver2/routes/api_chat.dart';
import 'package:flutter_hotel_booking_ver2/routes/routes.dart';
import 'package:hotel_repository/hotel_repository.dart';
import 'package:kommunicate_flutter/kommunicate_flutter.dart';
import 'package:room_repository/room_repository.dart';
import 'package:user_repository/user_repository.dart';

import '../owner/managehotel/edithotel.dart';
import '../owner/managerroom/addroom.dart';

class NavigationServices {
  NavigationServices(this.context);

  final BuildContext context;

  Future<dynamic> _pushMaterialPageRoute(Widget widget,
      {bool fullscreenDialog = false}) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => widget, fullscreenDialog: fullscreenDialog),
    );
  }

  Future gotoSplashScreen() async {
    await Navigator.pushNamedAndRemoveUntil(
        context, RoutesName.splash, (Route<dynamic> route) => false);
  }

  void gotoIntroductionScreen() {
    Navigator.pushNamedAndRemoveUntil(context, RoutesName.introductionScreen,
        (Route<dynamic> route) => false);
  }

  Future<dynamic> gotoLoginScreen() async {
    return await _pushMaterialPageRoute(const LoginScreen());
  }

  Future<dynamic> gotoTabScreen() async {
    return await _pushMaterialPageRoute(const BottomTabScreen());
  }

  Future<dynamic> gotoTabScreenAndClearStack() async {
    return Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const BottomTabScreen()),
      (route) => false, // Xóa toàn bộ ngăn xếp
    );
  }

  Future<dynamic> gotoSignScreen() async {
    return await _pushMaterialPageRoute(const SignUpScreen());
  }

  Future<dynamic> gotoForgotPassword() async {
    return await _pushMaterialPageRoute(const ForgotPasswordScreen());
  }

  Future<dynamic> gotoHotelDetailes(Hotel hotelData) async {
    return await _pushMaterialPageRoute(HotelDetailes(
      hotelData: hotelData,
    ));
  }

  Future<dynamic> gotoSearchScreen() async {
    return await _pushMaterialPageRoute(const SearchScreen());
  }

  Future<dynamic> gotoHotelHomeScreen() async {
    return await _pushMaterialPageRoute(const HotelHomeScreen());
  }

  Future<dynamic> gotoFiltersScreen() async {
    return await _pushMaterialPageRoute(const FiltersScreen());
  }

  Future<dynamic> gotoRoomBookingScreen(
    String hotelname,
    String hotelId,
    String hotelAddress,
    String startDate,
    String endDate,
  ) async {
    return await _pushMaterialPageRoute(RoomBookingScreen(
        hotelName: hotelname,
        hotelId: hotelId,
        hotelAddress: hotelAddress,
        startDate: startDate,
        endDate: endDate));
  }

  Future<dynamic> gotoRoomConfirmationScreen(
    String hotelname,
    String hotelId,
    String hotelAddress,
    String perNight,
    String startDate,
    String endDate,
    Room roomData,
  ) async {
    return await _pushMaterialPageRoute(BookingConfirmationScreen(
      hotelName: hotelname,
      hotelId: hotelId,
      hotelAddress: hotelAddress,
      perNight: perNight,
      startDate: startDate,
      endDate: endDate,
      roomData: roomData,
    ));
  }

  Future<dynamic> gotoReviewsScreen(
    Hotel hotel,
    String hotelId,
    String userId,
    String fullname,
  ) async {
    return await _pushMaterialPageRoute(ReviewScreen(
        hotel: hotel, hotelId: hotelId, userId: userId, fullname: fullname));
  }

  Future<dynamic> gotoReviewsListScreen(String hotelId) async {
    return await _pushMaterialPageRoute(ReviewsListScreen(
      hotelId: hotelId,
    ));
  }

  Future<dynamic> gotoAddHotel() async {
    return await _pushMaterialPageRoute(AddHotelScreen());
  }

  Future<dynamic> gotoAddRoom(String hotelId) async {
    return await _pushMaterialPageRoute(AddRoomScreen(
      hotelId: hotelId,
    ));
  }

  Future<dynamic> gotoEditHotel(Hotel hotel) async {
    return await _pushMaterialPageRoute(EditHotelScreen(
      hotel: hotel,
    ));
  }

  Future<dynamic> gotoEditProfile(MyUser myUser) async {
    return await _pushMaterialPageRoute(EditProfile(myUser: myUser));
  }

  Future<dynamic> gotoSettingsScreen() async {
    return await _pushMaterialPageRoute(const SettingsScreen());
  }

  Future<dynamic> gotoHeplCenterScreen() async {
    try {
              var conversationObject = {
                'appId': ApiChat.appKey,
              };

              dynamic result = await KommunicateFlutterPlugin.buildConversation(
                conversationObject,
              );

              print("Chatbot mở thành công: $result");
            } catch (e) {
              print("Lỗi khi mở chatbot: $e");
            }
    // return await _pushMaterialPageRoute(const HeplCenterScreen());
  }

  Future<dynamic> gotoChangepasswordScreen() async {
    return await _pushMaterialPageRoute(const ChangepasswordScreen());
  }

  Future<dynamic> gotoInviteFriend() async {
    return await _pushMaterialPageRoute(const InviteFriend());
  }

  Future<dynamic> gotoCurrencyScreen() async {
    return await _pushMaterialPageRoute(const CurrencyScreen(),
        fullscreenDialog: true);
  }

  Future<dynamic> gotoCountryScreen() async {
    return await _pushMaterialPageRoute(const CountryScreen(),
        fullscreenDialog: true);
  }

  Future<dynamic> gotoHowDoScreen() async {
    return await _pushMaterialPageRoute(const HowDoScreen());
  }

//   void gotoHotelDetailesPage(String hotelname) async {
//     await _pushMaterialPageRoute(HotelDetailes(hotelName: hotelname));
//   }
}
