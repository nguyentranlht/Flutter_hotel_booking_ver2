import 'package:flutter/material.dart';

import '../constants/themes.dart';

class ManageHotelsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Hotels"),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Center(
        child: const Text("Manage Hotels Functionality Here"),
      ),
    );
  }
}