import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ver2/constants/themes.dart';
import 'package:flutter_hotel_booking_ver2/language/app_localizations.dart';
import 'package:flutter_hotel_booking_ver2/modules/hotel_booking/filter_screen/range_slider_view.dart';
import 'package:flutter_hotel_booking_ver2/modules/hotel_booking/filter_screen/slider_view.dart';
import 'package:flutter_hotel_booking_ver2/provider/hotel_filter_prodiver.dart';
import 'package:flutter_hotel_booking_ver2/widgets/common_appbar_view.dart';
import 'package:flutter_hotel_booking_ver2/widgets/common_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FiltersScreen extends ConsumerWidget {
  const FiltersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(hotelFilterProvider);
    final filterNotifier = ref.read(hotelFilterProvider.notifier);

    return Container(
      color: AppTheme.scaffoldBackgroundColor,
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CommonAppbarView(
              iconData: Icons.close,
              onBackClick: () {
                Navigator.pop(context);
              },
              titleText: Loc.alized.filtter,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: <Widget>[
                      // Price Filter
                      priceBarFilter(context, filterNotifier, filter),
                      const Divider(height: 1),

                      // Distance Filter
                      distanceViewUI(context, filterNotifier, filter),
                      const Divider(height: 1),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16 + MediaQuery.of(context).padding.bottom,
                top: 8,
              ),
              child: CommonButton(
                buttonText: Loc.alized.apply_text,
                onTap: () {
                  Navigator.pop(
                      context); // Close the screen when applying filter
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget priceBarFilter(BuildContext context,
      HotelFilterNotifier filterNotifier, HotelFilter filter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            Loc.alized.price_text,
            style: TextStyle(
              color: Colors.grey,
              fontSize: MediaQuery.of(context).size.width > 360 ? 18 : 16,
            ),
          ),
        ),
        RangeSliderView(
          values: RangeValues(filter.minPrice, filter.maxPrice),
          onChangeRangeValues: (RangeValues values) {
            filterNotifier.updatePriceRange(values.start, values.end);
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget distanceViewUI(BuildContext context,
      HotelFilterNotifier filterNotifier, HotelFilter filter) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
          child: Text(
            Loc.alized.distance_from_city,
            style: TextStyle(
              color: Colors.grey,
              fontSize: MediaQuery.of(context).size.width > 360 ? 18 : 16,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        SliderView(
          initialDistanceValue:
              filter.maxDistance, // Pass maxDistance as initial value
          onChangedDistanceValue: (value) {
            filterNotifier
                .setMaxDistance(value); // Update maxDistance in filterNotifier
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // Widget allAccommodationUI() {
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: <Widget>[
  //       Padding(
  //         padding:
  //             const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
  //         child: Text(
  //           Loc.alized.type_of_accommodation,
  //           textAlign: TextAlign.left,
  //           style: TextStyle(
  //               color: Colors.grey,
  //               fontSize: MediaQuery.of(context).size.width > 360 ? 18 : 16,
  //               fontWeight: FontWeight.normal),
  //         ),
  //       ),
  //       Padding(
  //         padding: const EdgeInsets.only(right: 16, left: 16),
  //         child: Column(
  //           children: getAccomodationListUI(),
  //         ),
  //       ),
  //       const SizedBox(
  //         height: 8,
  //       ),
  //     ],
  //   );
  // }

  // List<Widget> getAccomodationListUI() {
  //   List<Widget> noList = [];
  //   for (var i = 0; i < accomodationListData.length; i++) {
  //     final date = accomodationListData[i];
  //     noList.add(
  //       Material(
  //         color: Colors.transparent,
  //         child: InkWell(
  //           borderRadius: const BorderRadius.all(Radius.circular(4.0)),
  //           onTap: () {
  //             setState(() {
  //               checkAppPosition(i);
  //             });
  //           },
  //           child: Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Row(
  //               children: <Widget>[
  //                 Expanded(
  //                   child: Text(
  //                     date.titleTxt,
  //                   ),
  //                 ),
  //                 CupertinoSwitch(
  //                   activeColor: date.isSelected
  //                       ? Theme.of(context).primaryColor
  //                       : Colors.grey.withOpacity(0.6),
  //                   onChanged: (value) {
  //                     setState(() {
  //                       checkAppPosition(i);
  //                     });
  //                   },
  //                   value: date.isSelected,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     );
  //     if (i == 0) {
  //       noList.add(const Divider(
  //         height: 1,
  //       ));
  //     }
  //   }
  //   return noList;
  // }

  // void checkAppPosition(int index) {
  //   if (index == 0) {
  //     if (accomodationListData[0].isSelected) {
  //       for (var d in accomodationListData) {
  //         d.isSelected = false;
  //       }
  //     } else {
  //       for (var d in accomodationListData) {
  //         d.isSelected = true;
  //       }
  //     }
  //   } else {
  //     accomodationListData[index].isSelected =
  //         !accomodationListData[index].isSelected;

  //     var count = 0;
  //     for (var i = 0; i < accomodationListData.length; i++) {
  //       if (i != 0) {
  //         var data = accomodationListData[i];
  //         if (data.isSelected) {
  //           count += 1;
  //         }
  //       }
  //     }

  //     if (count == accomodationListData.length - 1) {
  //       accomodationListData[0].isSelected = true;
  //     } else {
  //       accomodationListData[0].isSelected = false;
  //     }
  //   }
  // }

  // Widget popularFilter() {
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: <Widget>[
  //       Padding(
  //         padding:
  //             const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
  //         child: Text(
  //           Loc.alized.popular_filter,
  //           textAlign: TextAlign.left,
  //           style: TextStyle(
  //               color: Colors.grey,
  //               fontSize: MediaQuery.of(context).size.width > 360 ? 18 : 16,
  //               fontWeight: FontWeight.normal),
  //         ),
  //       ),
  //       Padding(
  //         padding: const EdgeInsets.only(right: 16, left: 16),
  //         child: Column(
  //           children: getPList(),
  //         ),
  //       ),
  //       const SizedBox(
  //         height: 8,
  //       )
  //     ],
  //   );
  // }

  // List<Widget> getPList() {
  //   List<Widget> noList = [];
  //   var cout = 0;
  //   const columCount = 2;
  //   for (var i = 0; i < popularFilterListData.length / columCount; i++) {
  //     List<Widget> listUI = [];
  //     for (var i = 0; i < columCount; i++) {
  //       try {
  //         final date = popularFilterListData[cout];
  //         listUI.add(
  //           Expanded(
  //             child: Row(
  //               children: <Widget>[
  //                 Material(
  //                   color: Colors.transparent,
  //                   child: InkWell(
  //                     borderRadius:
  //                         const BorderRadius.all(Radius.circular(4.0)),
  //                     onTap: () {
  //                       setState(() {
  //                         date.isSelected = !date.isSelected;
  //                       });
  //                     },
  //                     child: Padding(
  //                       padding: const EdgeInsets.only(
  //                           left: 8.0, top: 8, bottom: 8, right: 0),
  //                       child: Row(
  //                         children: <Widget>[
  //                           Icon(
  //                             date.isSelected
  //                                 ? Icons.check_box
  //                                 : Icons.check_box_outline_blank,
  //                             color: date.isSelected
  //                                 ? Theme.of(context).primaryColor
  //                                 : Colors.grey.withOpacity(0.6),
  //                           ),
  //                           const SizedBox(
  //                             width: 4,
  //                           ),
  //                           FittedBox(
  //                             fit: BoxFit.cover,
  //                             child: Text(
  //                               date.titleTxt,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //         cout += 1;
  //       } catch (_) {}
  //     }
  //     noList.add(Row(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       mainAxisSize: MainAxisSize.min,
  //       children: listUI,
  //     ));
  //   }
  //   return noList;
  // }
}
