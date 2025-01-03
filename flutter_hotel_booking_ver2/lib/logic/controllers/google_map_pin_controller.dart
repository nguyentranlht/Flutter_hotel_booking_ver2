import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_hotel_booking_ver2/models/hotel_list_data.dart';
import 'package:hotel_repository/hotel_repository.dart';

class GoogleMapPinController extends GetxController {
  LatLngBounds? _visibleRegion;
  Size? _visibleScreenSize;
  int? selectedIndex; // Lưu trữ chỉ số của item được chọn
  GoogleMapController? _mapController;
  List<Hotel> _hotelList = [];

  List<Hotel> get hotelList => _hotelList;

  void updateGoogleMapController(GoogleMapController mapController) async {
    _mapController = mapController;
    await _setPositionOnScreen();
    update();
  }
  
  void updateSelectedIndex(int index) {
    selectedIndex = index;
    update(); // Thông báo UI cập nhật
  }
  
  void updateScreenVisibleArea(Size size) {
    _visibleScreenSize = size;
    update();
  }

  void updateHotelList(List<Hotel> list) {
    _hotelList = list;
    update();
  }

  void updateUI() {
    update();
  }

  Future _setPositionOnScreen() async {
    if (_mapController != null && _visibleScreenSize != null) {
      _visibleRegion = await _mapController?.getVisibleRegion();
      if (_visibleRegion != null) {
        var sSize = _visibleScreenSize;
        var sdl = _visibleRegion!.northeast.latitude -
            _visibleRegion!.southwest.latitude;
        var sdlg = _visibleRegion!.southwest.longitude -
            _visibleRegion!.northeast.longitude;
        if (_mapController != null) {
          for (var item in _hotelList) {
            if (item.location != null) {
              var fdl =
                  _visibleRegion!.northeast.latitude - item.location.latitude;
              var fdlg = _visibleRegion!.southwest.longitude -
                  item.location.longitude;
              item.screenMapPin = Offset(
                  (fdlg * sSize!.width) / sdlg, (fdl * sSize.height) / sdl);
            }
          }
        }
      }
    }
  }
}
