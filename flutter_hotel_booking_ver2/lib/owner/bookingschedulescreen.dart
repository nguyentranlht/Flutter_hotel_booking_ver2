import 'package:flutter/material.dart';

import '../constants/themes.dart';

class BookingScheduleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Schedule"),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Center(
        child: const Text("Booking Schedule Functionality Here"),
      ),
    );
  }
}