import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotel_repository/hotel_repository.dart';

import '../../constants/themes.dart';
import '../../modules/myTrips/hotel_list_view.dart';
import '../../provider/hotel_filter_prodiver.dart';

class HotelListScreen extends StatefulWidget {
  const HotelListScreen({Key? key}) : super(key: key);

  @override
  State<HotelListScreen> createState() => _HotelListScreenState();
}

class _HotelListScreenState extends State<HotelListScreen>
    with TickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Hotels'),
        backgroundColor: AppTheme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: <Widget>[
          Consumer(
            builder: (context, ref, _) {
              final hotelListAsync = ref.watch(filteredHotelProvider);

              return hotelListAsync.when(
                data: (hotelList) {
                  // Lọc danh sách các khách sạn có isSelected == true
                  final selectedHotels =
                      hotelList.where((hotel) => hotel.isSelected).toList();

                  return Container(
                    color: AppTheme.scaffoldBackgroundColor,
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: selectedHotels.length,
                      padding: const EdgeInsets.only(
                        top: 16.0,
                      ),
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        var count = selectedHotels.length > 10
                            ? 10
                            : selectedHotels.length;
                        var animation = Tween(
                          begin: 0.0,
                          end: 1.0,
                        ).animate(
                          CurvedAnimation(
                            parent: animationController,
                            curve: Interval(
                              (1 / count) * index,
                              1.0,
                              curve: Curves.fastOutSlowIn,
                            ),
                          ),
                        );
                        animationController.forward();
                        return HotelListView(
                          callback: () {},
                          hotelData: selectedHotels[index],
                          animation: animation,
                          animationController: animationController,
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => Center(
                  child: Text('Error loading hotels: $error'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}