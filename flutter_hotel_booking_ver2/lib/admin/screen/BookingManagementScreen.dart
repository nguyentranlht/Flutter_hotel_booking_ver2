import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingManagementScreen extends StatelessWidget {
  const BookingManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý đặt phòng'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Không có đặt phòng nào.'));
          }
          final bookings = snapshot.data!.docs;
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return ListTile(
                title: Text('ID: ${booking.id}'),
                subtitle: Text('User: ${booking['userId'] ?? 'Unknown'}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection('bookings')
                        .doc(booking.id)
                        .delete();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
