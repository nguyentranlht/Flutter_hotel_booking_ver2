import 'package:flutter/material.dart';

import '../constants/themes.dart';

class RevenueReportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Revenue Report"),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Center(
        child: const Text("Revenue Report Functionality Here"),
      ),
    );
  }
}