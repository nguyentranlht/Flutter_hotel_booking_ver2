// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'hotel_list_view_page.dart';
// import 'navigation_services.dart';
// import 'models/hotel.dart';
// import 'providers/hotel_provider.dart';

// class DealListViewWidget extends ConsumerStatefulWidget {
//   final AnimationController animationController;

//   const DealListViewWidget({Key? key, required this.animationController})
//       : super(key: key);

//   @override
//   _DealListViewWidgetState createState() => _DealListViewWidgetState();
// }

// class _DealListViewWidgetState extends ConsumerState<DealListViewWidget> {
//   Widget getDealListView(int index) {
//     final hotelListAsync = ref.watch(hotelProvider);

//     return hotelListAsync.when(
//       data: (hotelList) {
//         List<Widget> list = [];
//         var selectedHotels = hotelList.take(2); // Lấy 2 khách sạn đầu tiên

//         for (var f in selectedHotels) {
//           var animation = Tween(begin: 0.0, end: 1.0).animate(
//             CurvedAnimation(
//               parent: widget.animationController,
//               curve: const Interval(0, 1.0, curve: Curves.fastOutSlowIn),
//             ),
//           );

//           list.add(
//             HotelListViewPage(
//               callback: () {
//                 NavigationServices(context).gotoHotelDetailes(f);
//               },
//               hotelData: f,
//               animation: animation,
//               animationController: widget.animationController,
//             ),
//           );
//         }

//         return Padding(
//           padding: const EdgeInsets.only(top: 8),
//           child: Column(
//             children: list,
//           ),
//         );
//       },
//       loading: () => const Center(child: CircularProgressIndicator()),
//       error: (error, stack) => Center(child: Text('Error: $error')),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return getDealListView(0); // Gọi hàm để lấy danh sách khách sạn
//   }
// }
