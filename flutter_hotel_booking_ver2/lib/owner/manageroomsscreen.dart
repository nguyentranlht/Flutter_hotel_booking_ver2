import 'package:flutter/material.dart';

import '../constants/themes.dart';

class ManageRoomsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Rooms"),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Center(
        child: const Text("Manage Rooms Functionality Here"),
      ),
    );
  }
}