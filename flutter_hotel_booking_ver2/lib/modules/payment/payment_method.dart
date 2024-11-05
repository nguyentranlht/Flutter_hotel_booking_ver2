import 'package:flutter/material.dart';

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Phương thức thanh toán"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          PaymentMethodTile(
            icon: "assets/momo_icon.png", // Local image asset
            title: "Ví MoMo",
          ),
          PaymentMethodTile(
            icon: "assets/zalopay_icon.png", // Local image asset
            title: "Ví ZaloPay",
          ),
          PaymentMethodTile(
            icon: "assets/shopeepay_icon.png", // Local image asset
            title: "Ví ShopeePay",
          ),
          PaymentMethodTile(
            icon: "assets/credit_card_icon.png", // Local image asset
            title: "Thẻ Credit",
          ),
          PaymentMethodTile(
            icon: "assets/atm_icon.png", // Local image asset
            title: "Thẻ ATM",
          ),
          PaymentMethodTile(
            icon: "assets/hotel_icon.png", // Local image asset
            title: "Trả tại khách sạn",
            subtitle: "Khách sạn có thể huỷ phòng tuỳ theo tình trạng phòng",
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            backgroundColor: Colors.grey,
          ),
          child: const Text("Xác nhận"),
        ),
      ),
    );
  }
}

class PaymentMethodTile extends StatelessWidget {
  final String icon;
  final String title;
  final String? subtitle;

  const PaymentMethodTile({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.asset(icon, width: 30, height: 30),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(subtitle!, style: TextStyle(fontSize: 12))
          : null,
      trailing: const Icon(Icons.radio_button_off),
    );
  }
}
