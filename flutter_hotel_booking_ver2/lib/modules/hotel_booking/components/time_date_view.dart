import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ver2/constants/helper.dart';
import 'package:flutter_hotel_booking_ver2/constants/text_styles.dart';
import 'package:flutter_hotel_booking_ver2/constants/themes.dart';
import 'package:flutter_hotel_booking_ver2/language/app_localizations.dart';
import 'package:flutter_hotel_booking_ver2/models/room_data.dart';
import 'package:flutter_hotel_booking_ver2/modules/hotel_booking/components/calendar_pop_up_view.dart';
import 'package:flutter_hotel_booking_ver2/modules/hotel_booking/components/room_pop_up_view.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TimeDateView extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime> onEndDateChanged;

  const TimeDateView({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  }) : super(key: key);

  @override
  State<TimeDateView> createState() => _TimeDateViewState();
}

class _TimeDateViewState extends State<TimeDateView> {
  RoomData _roomData = RoomData(1, 2);
  final String languageCode = Get.find<Loc>().locale.languageCode;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.scaffoldBackgroundColor,
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 20, bottom: 20, right: 20, top: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _getDateRoomUi(
                  Loc.alized.choose_date,
                  "${DateFormat("dd, MM", languageCode).format(widget.startDate)} - ${DateFormat("dd, MMM", languageCode).format(widget.endDate)}",
                  () {
                    _showDemoDialog(context);
                  },
                ),
                Container(
                  width: 1,
                  height: 42,
                  color: Colors.grey.withOpacity(0.8),
                ),
                _getDateRoomUi(
                  Loc.alized.number_room,
                  Helper.getRoomText(_roomData),
                  () {
                    _showPopUp();
                  },
                ),
              ],
            ),
          ),
          // Bottom line
          Container(
            height: 1.5, // Thickness of the line
            color: Colors.grey.withOpacity(0.8), // Color of the line
          ),
        ],
      ),
    );
  }

  Widget _getDateRoomUi(String title, String subtitle, VoidCallback onTap) {
    return Expanded(
      child: Row(
        children: <Widget>[
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.all(
                Radius.circular(4.0),
              ),
              onTap: onTap,
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyles(context)
                          .getDescriptionStyle()
                          .copyWith(fontSize: 16),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      subtitle,
                      style: TextStyles(context).getRegularStyle(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDemoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CalendarPopupView(
        barrierDismissible: true,
        minimumDate: DateTime.now(),
        maximumDate: DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day + 10),
        initialEndDate: widget.endDate,
        initialStartDate: widget.startDate,
        onApplyClick: (DateTime startData, DateTime endData) {
          widget.onStartDateChanged(startData);
          widget.onEndDateChanged(endData);
        },
        onCancelClick: () {},
      ),
    );
  }

  void _showPopUp() {
    showDialog(
      context: context,
      builder: (BuildContext context) => RoomPopupView(
        roomData: _roomData,
        barrierDismissible: true,
        onChnage: (data) {
          setState(() {
            _roomData = data;
          });
        },
      ),
    );
  }
}
