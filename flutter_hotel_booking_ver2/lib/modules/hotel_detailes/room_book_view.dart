import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_hotel_booking_ver2/constants/helper.dart';
import 'package:flutter_hotel_booking_ver2/constants/text_styles.dart';
import 'package:flutter_hotel_booking_ver2/language/app_localizations.dart';
import 'package:flutter_hotel_booking_ver2/models/hotel_list_data.dart';
import 'package:flutter_hotel_booking_ver2/widgets/app_constant.dart';
import 'package:flutter_hotel_booking_ver2/widgets/common_button.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class RoomeBookView extends StatefulWidget {
  final HotelListData roomData;
  final AnimationController animationController;
  final Animation<double> animation;

  const RoomeBookView(
      {Key? key,
      required this.roomData,
      required this.animationController,
      required this.animation})
      : super(key: key);

  @override
  State<RoomeBookView> createState() => _RoomeBookViewState();
}

class _RoomeBookViewState extends State<RoomeBookView> {
  var pageController = PageController(initialPage: 0);
  Map<String, dynamic>? paymentIntent;
  final oCcy = NumberFormat("#,##0", "vi_VN");

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> images = widget.roomData.imagePath.split(" ");
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.animation,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 40 * (1.0 - widget.animation.value), 0.0),
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
                        children: <Widget>[
                          for (var image in images)
                            Image.asset(
                              image,
                              fit: BoxFit.cover,
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SmoothPageIndicator(
                        controller: pageController, // PageController
                        count: 3,
                        effect: WormEffect(
                            activeDotColor: Theme.of(context).primaryColor,
                            dotColor: Theme.of(context).colorScheme.background,
                            dotHeight: 10.0,
                            dotWidth: 10.0,
                            spacing: 5.0), // your preferred effect
                        onDotClicked: (index) {},
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, bottom: 16, top: 16),
                  child: Column(
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.roomData.titleTxt,
                            maxLines: 2,
                            textAlign: TextAlign.left,
                            style: TextStyles(context)
                                .getBoldStyle()
                                .copyWith(fontSize: 24),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Expanded(child: SizedBox()),
                          SizedBox(
                            height: 38,
                            child: CommonButton(
                              onTap: () {
                                String perNight =
                                    (widget.roomData.perNight * 1000)
                                        .toString();
                                makePayment(perNight);
                              },
                              buttonTextWidget: Padding(
                                padding: const EdgeInsets.only(
                                    left: 16.0, right: 16.0, top: 4, bottom: 4),
                                child: Text(
                                  Loc.alized.book_now,
                                  textAlign: TextAlign.center,
                                  style: TextStyles(context).getRegularStyle(),
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
                            "\$${widget.roomData.perNight}",
                            textAlign: TextAlign.left,
                            style: TextStyles(context)
                                .getBoldStyle()
                                .copyWith(fontSize: 22),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 0),
                            child: Text(
                              Loc.alized.per_night,
                              style: TextStyles(context)
                                  .getRegularStyle()
                                  .copyWith(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            Helper.getPeopleandChildren(
                                widget.roomData.roomData!),
                            // "${widget.roomData.dateTxt}",
                            textAlign: TextAlign.left,
                            style: TextStyles(context).getDescriptionStyle(),
                          ),
                          InkWell(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4.0)),
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    Loc.alized.more_details,
                                    style: TextStyles(context).getBoldStyle(),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Icon(
                                      Icons.keyboard_arrow_down,
                                      // color: Theme.of(context).backgroundColor,
                                      size: 24,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 1,
                )
              ],
            ),
          ),
        );
      },
    );
  }

  //  Future<Map<String, dynamic>>
  createPaymentIntent(String amount, String currency) async {
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
      // ignore: avoid_print
      print('Payment Intent Body->>> ${response.body.toString()}');
      return jsonDecode(response.body);
    } catch (err) {
      // ignore: avoid_print
      print('err charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final calculatedAmout = (int.parse(amount));

    return calculatedAmout.toString();
  }

  Future<void> makePayment(String amount) async {
    try {
      paymentIntent = await createPaymentIntent(amount, 'VND');
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent!['client_secret'],
                  style: ThemeMode.dark,
                  merchantDisplayName: 'Adnan'))
          .then((value) {});

      //now finally display payment sheeet
      displayPaymentSheet(amount);
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  displayPaymentSheet(String amount) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          barrierDismissible:
              false, // Ngăn người dùng tắt dialog bằng cách nhấn bên ngoài
          builder: (context) => WillPopScope(
            onWillPop: () async =>
                false, // Ngăn người dùng tắt dialog bằng nút back
            child: AlertDialog(
              content: SingleChildScrollView(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(
                            width: 16.0,
                          ),
                          Center(
                            child: Text(
                              "Nạp tiền thành công",
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
                      const SizedBox(
                        height: 20.0,
                      ),
                      const Text(
                        "Cảm ơn",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            // Điều hướng về trang chủ
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
          ),
        );
      }).onError((error, stackTrace) {
        print('Error is:--->$error $stackTrace');
      });
    } on StripeException catch (e) {
      print('Error is:---> $e');
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                content: Text("Cancelled "),
              ));
    } catch (e) {
      print('$e');
    }
  }
}
