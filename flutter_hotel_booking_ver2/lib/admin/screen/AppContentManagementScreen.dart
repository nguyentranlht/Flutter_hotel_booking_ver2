import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppContentManagementScreen extends StatelessWidget {
  const AppContentManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý nội dung'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {},
          child: const Text('Thêm khách sạn mới'),
        ),
      ),
    );
  }
}
