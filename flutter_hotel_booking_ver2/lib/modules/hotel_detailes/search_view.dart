import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ver2/constants/helper.dart';
import 'package:flutter_hotel_booking_ver2/constants/text_styles.dart';
import 'package:flutter_hotel_booking_ver2/constants/themes.dart';
import 'package:flutter_hotel_booking_ver2/widgets/common_card.dart';
import 'package:flutter_hotel_booking_ver2/widgets/list_cell_animation_view.dart';
import 'package:hotel_repository/hotel_repository.dart';

class SerchView extends StatelessWidget {
  final Hotel hotelInfo;
  final AnimationController animationController;
  final Animation<double> animation;

  const SerchView(
      {Key? key,
      required this.hotelInfo,
      required this.animationController,
      required this.animation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListCellAnimationView(
      animation: animation,
      animationController: animationController,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AspectRatio(
          aspectRatio: 0.75,
          child: CommonCard(
            color: AppTheme.backgroundColor,
            radius: 16,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(16.0)),
              child: Column(
                children: <Widget>[
                  AspectRatio(
                      aspectRatio: 1.05,
                      child: hotelInfo.imagePath != null
                          ? Image.network(
                              hotelInfo.imagePath!,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'assets/images/placeholder.png',
                              fit: BoxFit.cover,
                            ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            hotelInfo.hotelName,
                            style: TextStyles(context).getBoldStyle(),
                          ),
                          
                            // Text(
                          //   Helper.getLastSearchDate(hotelInfo.date!),
                          //   // Helper.getRoomText(hotelInfo.roomData!),
                          //   style:
                          //       TextStyles(context).getRegularStyle().copyWith(
                          //             fontWeight: FontWeight.w100,
                          //             fontSize: 12,
                          //             color: Theme.of(context)
                          //                 .disabledColor
                          //                 .withOpacity(0.6),
                          //           ),
                          // ),
                          // Text(
                          //   Helper.getRoomText(hotelInfo),
                          //   // Helper.getRoomText(hotelInfo.roomData!),
                          //   style:
                          //       TextStyles(context).getRegularStyle().copyWith(
                          //             fontWeight: FontWeight.w100,
                          //             fontSize: 12,
                          //             color: Theme.of(context)
                          //                 .disabledColor
                          //                 .withOpacity(0.6),
                          //           ),
                          // ),
                          // Text(
                          //   Helper.getLastSearchDate(hotelInfo.date!),
                          //   // Helper.getRoomText(hotelInfo.roomData!),
                          //   style:
                          //       TextStyles(context).getRegularStyle().copyWith(
                          //             fontWeight: FontWeight.w100,
                          //             fontSize: 12,
                          //             color: Theme.of(context)
                          //                 .disabledColor
                          //                 .withOpacity(0.6),
                          //           ),
                          // ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
