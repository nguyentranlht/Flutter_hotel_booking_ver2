import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_hotel_booking_ver2/constants/themes.dart';
import 'package:flutter_hotel_booking_ver2/logic/controllers/google_map_pin_controller.dart';
import 'package:hotel_repository/hotel_repository.dart';
import 'package:intl/intl.dart';

class GoogleMapUIView extends StatefulWidget {
  final List<Hotel> hotelList; // Thay đổi kiểu thành List<Hotel>
  const GoogleMapUIView({Key? key, required this.hotelList}) : super(key: key);

  @override
  State<GoogleMapUIView> createState() => _GoogleMapUIViewState();
}

class _GoogleMapUIViewState extends State<GoogleMapUIView> {
  GoogleMapController? _mapController;
  late GoogleMapPinController _googleMapPinController;
  final oCcy = NumberFormat("#,##0", "vi_VN");

  @override
  void initState() {
    _googleMapPinController = Get.find<GoogleMapPinController>();
    _googleMapPinController.updateHotelList(
        widget.hotelList.cast<Hotel>()); // Cập nhật danh sách khách sạn
    super.initState();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _googleMapPinController.updateScreenVisibleArea(
            Size(constraints.maxWidth, constraints.maxHeight));
        return GetBuilder<GoogleMapPinController>(builder: (provider) {
          return Stack(
            children: [
              Container(),
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(10.769444, 106.681944),
                  zoom: 13,
                ),
                mapType: MapType.normal,
                onCameraMove: (CameraPosition position) {
                  if (_mapController != null) {
                    _googleMapPinController
                        .updateGoogleMapController(_mapController!);
                  }
                },
                mapToolbarEnabled: false,
                compassEnabled: false,
                myLocationButtonEnabled: false,
                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,
                myLocationEnabled: true,
                zoomControlsEnabled: false,
                onMapCreated: (GoogleMapController controller) async {
                  _mapController = controller;
                  // await _mapController?.setMapStyle(
                  //   await DefaultAssetBundle.of(context).loadString(
                  //     AppTheme.isLightMode
                  //         ? "assets/json/mapstyle_light.json"
                  //         : "assets/json/mapstyle_dark.json",
                  //   ),
                  // );
                  _googleMapPinController.updateGoogleMapController(controller);
                },
              ),
              for (var item in provider.hotelList)
                (item.screenMapPin != null && item.isSelected)
                    ? AnimatedPositioned(
                        duration: const Duration(milliseconds: 1),
                        top: item.screenMapPin!.dy - 48,
                        left: item.screenMapPin!.dx - 40,
                        child: SizedBox(
                          height: 48,
                          width: 150,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  color: provider.hotelList.indexOf(item) ==
                                          _googleMapPinController.selectedIndex
                                      ? AppTheme.primaryColor
                                      : AppTheme.backgroundColor,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(24.0)),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: AppTheme.secondaryTextColor,
                                      blurRadius: 16,
                                      offset: const Offset(4, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      _googleMapPinController
                                          .updateSelectedIndex(
                                              provider.hotelList.indexOf(item));
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, right: 8, top: 4, bottom: 4),
                                      child: Text(
                                        "${(oCcy.format(num.parse(item.perNight)))}₫",
                                        style: TextStyle(
                                          color: provider.hotelList
                                                      .indexOf(item) ==
                                                  _googleMapPinController
                                                      .selectedIndex
                                              ? AppTheme.backgroundColor
                                              : AppTheme.primaryColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              IgnorePointer(
                                child: Container(
                                  width: 1,
                                  color: provider.hotelList.indexOf(item) ==
                                          _googleMapPinController.selectedIndex
                                      ? AppTheme.primaryColor
                                      : AppTheme.backgroundColor,
                                  height: 13,
                                ),
                              ),
                              IgnorePointer(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                  width: 4,
                                  height: 4,
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    : const SizedBox(),
            ],
          );
        });
      },
    );
  }
}
