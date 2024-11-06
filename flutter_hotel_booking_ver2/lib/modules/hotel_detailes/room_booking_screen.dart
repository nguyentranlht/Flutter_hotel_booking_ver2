import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ver2/constants/text_styles.dart';
import 'package:flutter_hotel_booking_ver2/modules/hotel_detailes/room_book_view.dart';
import 'package:flutter_hotel_booking_ver2/provider/room_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoomBookingScreen extends ConsumerStatefulWidget {
  final String hotelName;
  final String hotelId;
  final String hotelAddress;
  final String startDate;
  final String endDate;

  const RoomBookingScreen({
    Key? key,
    required this.hotelName,
    required this.hotelId,
    required this.hotelAddress,
    required this.startDate,
    required this.endDate,
  }) : super(key: key);

  @override
  _RoomBookingScreenState createState() => _RoomBookingScreenState();
}

class _RoomBookingScreenState extends ConsumerState<RoomBookingScreen>
    with TickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 0), vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          getAppBarUI(),
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final roomsAsync = ref.watch(roomsProvider(widget.hotelId));
                return roomsAsync.when(
                  data: (rooms) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(0.0),
                      itemCount: rooms.length,
                      itemBuilder: (context, index) {
                        var count = rooms.length > 10 ? 10 : rooms.length;
                        var animation = Tween(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: animationController,
                            curve: Interval((1 / count) * index, 1.0,
                                curve: Curves.fastOutSlowIn),
                          ),
                        );
                        animationController.forward();

                        return RoomeBookView(
                          hotelName: widget.hotelName,
                          hotelId: widget.hotelId,
                          hotelAddress: widget.hotelAddress,
                          startDate: widget.startDate,
                          endDate: widget.endDate,
                          roomData: rooms[index],
                          animation: animation,
                          animationController: animationController,
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget getAppBarUI() {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
      ),
      child: SizedBox(
        height: AppBar().preferredSize.height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: const BorderRadius.all(
                  Radius.circular(32.0),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.arrow_back),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  widget.hotelName,
                  style: TextStyles(context).getTitleStyle(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: const BorderRadius.all(
                  Radius.circular(32.0),
                ),
                onTap: () {},
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.favorite_border),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
