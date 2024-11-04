import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ver2/routes/route_names.dart';
import 'package:flutter_hotel_booking_ver2/widgets/app_constant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/intl.dart';
import 'package:room_repository/room_repository.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:http/http.dart' as http;
// Thêm Stripe nếu bạn đang dùng

class RoomeBookView extends ConsumerWidget {
  final Room roomData;
  final AnimationController animationController;
  final Animation<double> animation;
  final String hotelName;
  final String hotelId;
  final String startDate;
  final String endDate;

  const RoomeBookView({
    Key? key,
    required this.roomData,
    required this.animationController,
    required this.animation,
    required this.hotelName,
    required this.hotelId,
    required this.startDate,
    required this.endDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var pageController = PageController(initialPage: 0);
    final oCcy = NumberFormat("#,##0", "vi_VN");

    List<String> images = roomData.imagePath?.split(" ") ?? [];

    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 40 * (1.0 - animation.value), 0.0),
            child: Column(
              children: <Widget>[
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    AspectRatio(
                      aspectRatio: 1.5,
                      child: PageView(
                        controller: pageController,
                        pageSnapping: true,
                        scrollDirection: Axis.horizontal,
                        children: images.isNotEmpty
                            ? images.map((image) {
                                return Image.network(
                                  image,
                                  fit: BoxFit.cover,
                                );
                              }).toList()
                            : [Image.asset('assets/images/placeholder.png')],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SmoothPageIndicator(
                        controller: pageController,
                        count: images.length,
                        effect: WormEffect(
                          activeDotColor: Theme.of(context).primaryColor,
                          dotColor: Theme.of(context).colorScheme.background,
                          dotHeight: 10.0,
                          dotWidth: 10.0,
                          spacing: 5.0,
                        ),
                        onDotClicked: (index) {},
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            roomData.roomName,
                            maxLines: 2,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Expanded(child: SizedBox()),
                          SizedBox(
                            height: 38,
                            child: ElevatedButton(
                              onPressed: () {
                                // String perNight =
                                //     (roomData.pricePerNight * 100).toString();
                                // makePayment(context, perNight);
                                NavigationServices(context)
                                    .gotoRoomConfirmationScreen(
                                  hotelName,
                                  hotelId,
                                  startDate.toString(),
                                  endDate.toString(),
                                  roomData,
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                child: Text(
                                  "Book Now",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "\$${roomData.pricePerNight}",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 0),
                            child: Text(
                              "/ per night",
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Capacity: ${roomData.capacity} people",
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 14),
                          ),
                          InkWell(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4.0)),
                            onTap: () {},
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "More details",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String calculateAmount(String amount) {
    // Parse the amount as a double and then cast it to an integer
    final calculatedAmount = (double.parse(amount) * 100).toInt();
    return calculatedAmount.toString();
  }

  Future<Map<String, dynamic>?> createPaymentIntent(
      String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );

      if (response.statusCode == 200) {
        print('Payment Intent Body->>> ${response.body.toString()}');
        return jsonDecode(response.body);
      } else {
        print('Failed to create Payment Intent: ${response.body}');
        return null;
      }
    } catch (err) {
      print('Error charging user: ${err.toString()}');
      return null;
    }
  }

  Future<void> makePayment(BuildContext context, String amount) async {
    try {
      // Step 1: Create a payment intent
      var paymentIntent = await createPaymentIntent(amount, 'VND');
      if (paymentIntent == null) {
        throw Exception("Failed to create payment intent");
      }

      // Step 2: Initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          style: ThemeMode.dark,
          merchantDisplayName: 'Your Business Name',
        ),
      );

      // Step 3: Display the payment sheet after successful initialization
      await displayPaymentSheet(context, amount);
    } catch (e, s) {
      print('Exception: $e $s');
      // Display an error dialog
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Text("An error occurred: ${e.toString()}"),
        ),
      );
    }
  }

  Future<void> displayPaymentSheet(BuildContext context, String amount) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 16.0),
                        Center(
                          child: Text(
                            "Thanh toán thàn công",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.lightGreen.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    const Text(
                      "Cảm ơn",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 10.0),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 100,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF008080),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              "Đóng",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).onError((error, stackTrace) {
        print('Error presenting payment sheet: $error $stackTrace');
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: Text("Failed to present payment sheet. Please try again."),
          ),
        );
      });
    } on StripeException catch (e) {
      print('StripeException: $e');
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          content: Text("Payment was cancelled"),
        ),
      );
    } catch (e) {
      print('Exception: $e');
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Text("An unexpected error occurred: $e"),
        ),
      );
    }
  }
}
