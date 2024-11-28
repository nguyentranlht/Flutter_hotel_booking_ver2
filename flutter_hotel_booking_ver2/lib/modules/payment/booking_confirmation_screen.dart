import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ver2/constants/themes.dart';
import 'package:flutter_hotel_booking_ver2/modules/profile/edit_profile.dart';
import 'package:flutter_hotel_booking_ver2/routes/route_names.dart';
import 'package:flutter_hotel_booking_ver2/widgets/app_constant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hotel_booking_ver2/provider/room_provider.dart';
import 'package:flutter_hotel_booking_ver2/provider/user_provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/intl.dart';
import 'package:room_repository/room_repository.dart';
import 'package:http/http.dart' as http;
import 'package:user_repository/user_repository.dart';

class BookingConfirmationScreen extends ConsumerStatefulWidget {
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
  _BookingConfirmationScreenState createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState
    extends ConsumerState<BookingConfirmationScreen> {
  int editCount = 0; // Track the number of edits

  void _editUserInfo(BuildContext context, MyUser user, WidgetRef ref) {
    if (editCount >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bạn chỉ có thể chỉnh sửa thông tin 2 lần."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfile(myUser: user),
      ),
    ).then((_) {
      // Increment edit count when returning from EditProfile
      setState(() {
        editCount++;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final String userId = auth.currentUser?.uid ?? '';
    final oCcy = NumberFormat("#,##0", "vi_VN");

    // Fetch room data using the hotelId
    final roomsAsync = ref.watch(roomsProvider(widget.hotelId));
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
                  (room) => room.roomId == widget.roomData.roomId,
                  orElse: () => widget.roomData,
                );

                return Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppTheme.getThemeData.focusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Image.network(
                        selectedRoom.imagePath ?? 'default_image_url',
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
                              widget.hotelName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              widget.hotelAddress,
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                              ),
                            ),
                            Text(selectedRoom.roomType),
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
                    Text("14:00 · ${widget.startDate}"),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Trả phòng"),
                    Text("12:00 · ${widget.endDate}"),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // User Information Section with Edit Button
            const Text(
              "Người đặt phòng",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            userAsync.when(
              data: (user) => user != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${user.fullname}"),
                                Text(user.phonenumber),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _editUserInfo(context, user, ref);
                              },
                            ),
                          ],
                        ),
                        // Display edit count message
                        if (editCount < 2)
                          Text(
                            "Bạn có thể chỉnh sửa thông tin ${2 - editCount} lần nữa.",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                            ),
                          )
                        else
                          const Text(
                            "Bạn đã hết số lần chỉnh sửa.",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
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
                  "${(oCcy.format(num.parse(widget.perNight)))}₫",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Confirm Button
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: ref.watch(isLoadingProvider)
                    ? null
                    : () async {
                        final userAsync = ref.read(userProvider(userId));
                        final user = userAsync.maybeWhen(
                          data: (user) => user?.fullname ?? '',
                          orElse: () => '',
                        );

                        String bookingId = FirebaseFirestore.instance
                            .collection('bookings')
                            .doc()
                            .id;
                        String paymentId = FirebaseFirestore.instance
                            .collection('payments')
                            .doc()
                            .id;

                        await makePayment(
                          context,
                          ref,
                          widget.perNight,
                          bookingId,
                          paymentId,
                          userId,
                          widget.hotelId,
                          widget.roomData.roomId,
                          widget.startDate,
                          widget.endDate,
                          widget.roomData.capacity,
                          user,
                        );
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: ref.watch(isLoadingProvider)
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
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

  final isLoadingProvider = StateProvider<bool>((ref) => false);
  String? paymentIntentId;
// Trong hàm makePayment
  Future<void> makePayment(
    BuildContext context,
    WidgetRef ref, // Thêm ref để có thể truy cập StateProvider
    String amount,
    String bookingId,
    String paymentId,
    String userId,
    String selectedHotelId,
    String selectedRoomId,
    String startDate,
    String endDate,
    int numberOfGuests,
    String fullname,
  ) async {
    // Cập nhật isLoading thành true
    ref.read(isLoadingProvider.notifier).state = true;

    try {
      // Bước 1: Tạo Payment Intent
      var paymentIntent = await createPaymentIntent(amount, 'VND');
      paymentIntentId = paymentIntent!['id'];
      print('paymentIntentId: $paymentIntentId');
      // Bước 2: Khởi tạo Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          style: ThemeMode.dark,
          merchantDisplayName: 'Your Business Name',
        ),
      );

      // Bước 3: Hiển thị Payment Sheet sau khi khởi tạo thành công
      await displayPaymentSheet(
        context,
        amount,
        bookingId,
        paymentId,
        userId,
        selectedHotelId,
        selectedRoomId,
        startDate,
        endDate,
        numberOfGuests,
        fullname,
      );
    } catch (e, s) {
      print('Lỗi: $e $s');
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Text("Đã xảy ra lỗi: ${e.toString()}"),
        ),
      );
    } finally {
      // Đảm bảo đặt lại isLoading về false sau khi hoàn thành
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  Future<void> createBookingAndPayment(
    String bookingId,
    String userId,
    Map<String, dynamic> bookingData,
    Map<String, dynamic> paymentData,
  ) async {
    // Khởi tạo batch trong Firestore để thực hiện cập nhật đồng bộ
    WriteBatch batch = FirebaseFirestore.instance.batch();

    // Tham chiếu đến tài liệu
    DocumentReference bookingRef =
        FirebaseFirestore.instance.collection('bookings').doc(bookingId);
    DocumentReference paymentRef =
        FirebaseFirestore.instance.collection('payments').doc();

    // Thêm dữ liệu đặt phòng và thanh toán vào batch
    batch.set(bookingRef, bookingData);
    batch.set(paymentRef, paymentData);

    // Cập nhật trạng thái thanh toán trong cả hai collection
    batch.update(bookingRef, {'paymentStatus': 'paid'});
    batch.update(paymentRef, {'status': 'completed'});

    // Thực hiện commit batch
    try {
      await batch.commit();
      print("Đặt phòng và thanh toán đã được ghi thành công");
    } catch (e) {
      print("Lỗi khi tạo đặt phòng và thanh toán: $e");
    }
  }

  Future<void> displayPaymentSheet(
    BuildContext context,
    String amount,
    String bookingId,
    String paymentId,
    String userId,
    String selectedHotelId,
    String selectedRoomId,
    String startDate,
    String endDate,
    int numberOfGuests,
    String fullname,
  ) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((_) async {
        // Chuẩn bị dữ liệu bookingData và paymentData cho cập nhật sau khi thanh toán thành công
        Map<String, dynamic> bookingData = {
          'bookingId': bookingId,
          'paymentIntentId': paymentIntentId,
          'userId': userId,
          'hotelId': selectedHotelId,
          'roomId': selectedRoomId,
          'bookingDate': Timestamp.fromDate(DateTime.now()),
          'checkInDate': Timestamp.fromDate(DateTime.parse(startDate)),
          'checkOutDate': Timestamp.fromDate(DateTime.parse(endDate)),
          'numberOfGuests': numberOfGuests,
          'bookingStatus': 'success',
          'totalPrice': amount,
          'paymentStatus': 'success',
          'fullname': fullname
        };

        Map<String, dynamic> paymentData = {
          'paymentId': paymentId, // Hoặc một ID tùy chỉnh
          'bookingId': bookingId,
          'userId': userId,
          'amount': amount,
          'currency': 'VND',
          'status': 'success',
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        };

        // Sau khi thanh toán thành công, thực hiện lưu dữ liệu vào Firestore
        await createBookingAndPayment(
          bookingId,
          userId,
          bookingData,
          paymentData,
        );
        // await RoomService()
        //     .updateAvailableDates(roomData.roomId, startDate, endDate);

        // Hiển thị thông báo thanh toán thành công
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
                        const SizedBox(width: 5.0),
                        Center(
                          child: Text(
                            "Thanh toán thành công",
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
                          NavigationServices(context).gotoTabScreen();
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
          builder: (_) => const AlertDialog(
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
}
