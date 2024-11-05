import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ver2/constants/themes.dart';
import 'package:flutter_hotel_booking_ver2/widgets/app_constant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hotel_booking_ver2/provider/room_provider.dart';
import 'package:flutter_hotel_booking_ver2/provider/user_provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/intl.dart';
import 'package:room_repository/room_repository.dart';
import 'package:http/http.dart' as http;

class BookingConfirmationScreen extends ConsumerWidget {
  final Room roomData;
  final String hotelName;
  final String hotelId;
  final String hotelAddress;
  final String perNight;
  final String startDate;
  final String endDate;

  const BookingConfirmationScreen({
    Key? key,
    required this.roomData,
    required this.hotelName,
    required this.hotelId,
    required this.hotelAddress,
    required this.perNight,
    required this.startDate,
    required this.endDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final String userId = auth.currentUser?.uid ?? '';
    final oCcy = NumberFormat("#,##0", "vi_VN");
    // Fetch room data using the hotelId
    final roomsAsync = ref.watch(roomsProvider(hotelId));
    // Fetch user data using the userId
    final userAsync = ref.watch(userProvider(userId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Xác nhận và thanh toán",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel details section with real data
            roomsAsync.when(
              data: (rooms) {
                final selectedRoom = rooms.firstWhere(
                    (room) => room.roomId == roomData.roomId,
                    orElse: () => roomData);

                return Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppTheme.getThemeData.focusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Image.network(
                        selectedRoom.imagePath ??
                            'default_image_url', // Real room image
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hotelName, // Hotel name
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              hotelAddress,
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                              ),
                            ),
                            Text(selectedRoom.roomType), // Room type
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
            const SizedBox(height: 16),

            // Check-in and Check-out details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Nhận phòng"),
                    Text("14:00 · $startDate"),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Trả phòng"),
                    Text("12:00 · $endDate"),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // User Information Section with real data
            const Text("Người đặt phòng",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            userAsync.when(
              data: (user) => user != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${user.firstname} ${user.lastname}"),
                        Text(user.phonenumber),
                      ],
                    )
                  : const Text("Không tìm thấy thông tin người dùng"),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
            const SizedBox(height: 16),

            // Discount Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.whiteColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Ưu đãi"),
                  Text("Bạn đang có 0 GoG Xu"),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Payment details with real room price
            const Text("Chi tiết thanh toán",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tiền phòng"),
                Text(
                  "${(oCcy.format(num.parse(perNight)))}₫",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Terms and Conditions
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).primaryColor, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.blueGrey, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "Có thể huỷ miễn phí trong vòng 5 phút kể từ thời điểm đặt phòng thành công.",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle confirmation logic

                  makePayment(context, perNight);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: Text(
                  "Thanh toán",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String calculateAmount(String amount) {
    // Parse the amount as a double and then cast it to an integer
    final calculatedAmount = (double.parse(amount)).toInt();
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