import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Không có dữ liệu.'));
          }
          final bookings = snapshot.data!.docs;

          // Tính tổng doanh thu, xử lý khi totalPrice là String
          final totalRevenue = bookings.fold<double>(
            0.0,
            (sum, booking) {
              final totalPrice = booking['totalPrice'];
              final doublePrice = (totalPrice is String)
                  ? double.tryParse(totalPrice) ?? 0.0
                  : (totalPrice as double? ?? 0.0);
              return sum + doublePrice;
            },
          );

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Tổng doanh thu:',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  '${totalRevenue.toStringAsFixed(2)}₫',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
