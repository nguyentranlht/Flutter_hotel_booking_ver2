import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý người dùng')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Không có người dùng nào.'));
          }
          final users = snapshot.data!.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user['fullname']),
                subtitle: Text('Role: ${user['role']}'),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'Suspend') {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.id)
                          .update({'status': 'suspended'});
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'Suspend', child: Text('Tạm ngưng')),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
