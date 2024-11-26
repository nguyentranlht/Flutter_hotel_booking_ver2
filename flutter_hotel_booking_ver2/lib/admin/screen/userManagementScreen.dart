import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý người dùng')),
      body: Column(
        children: [
          // Phần thông báo
          //_buildNotificationSection(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Không có người dùng nào.'));
                }

                final users = snapshot.data!.docs;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;
                      final isTablet = constraints.maxWidth >= 600 &&
                          constraints.maxWidth < 1024;
                      final crossAxisCount = isMobile
                          ? 1
                          : isTablet
                              ? 2
                              : 3;

                      final childAspectRatio = isMobile
                          ? 2 / 1
                          : isTablet
                              ? 4 / 3
                              : 5 / 3;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          final userData = user.data() as Map<String, dynamic>;

                          final status = userData.containsKey('status')
                              ? userData['status']
                              : 'unknown';
                          final role = userData['role'] ?? 'unknown';

                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.grey.shade300,
                                      child: Icon(Icons.person,
                                          color: Colors.grey.shade700),
                                    ),
                                    title: Text(
                                      userData['fullname'] ?? 'Không có tên',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      'Role: $role',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                              color: Colors.grey.shade600),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(user.id)
                                              .update({'status': 'suspended'});
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '${userData['fullname'] ?? 'Người dùng'} đã bị tạm ngưng.',
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.block, size: 16),
                                        label: const Text('Tạm ngưng'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      ),
                                      Switch(
                                        value: status == 'active',
                                        onChanged: (value) {
                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(user.id)
                                              .update({
                                            'status':
                                                value ? 'active' : 'suspended'
                                          });
                                        },
                                        activeColor: Colors.green,
                                        inactiveThumbColor: Colors.red,
                                        inactiveTrackColor: Colors.red.shade100,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  if (role == 'user')
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection('notifications')
                                            .add({
                                          'type':
                                              'confirm_owner_role', // Cập nhật type thành confirm_owner_role
                                          'message':
                                              '${userData['fullname']} đã được xác nhận làm Owner.',
                                          'timestamp':
                                              FieldValue.serverTimestamp(),
                                          'userId': user.id,
                                        });

                                        // Cập nhật vai trò của người dùng lên 'owner'
                                        FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(user.id)
                                            .update({
                                          'role': 'owner',
                                        });

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '${userData['fullname'] ?? 'Người dùng'} đã được nâng cấp lên Owner.',
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.check_circle,
                                          size: 16),
                                      label: const Text('Xác nhận làm Owner'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox(); // Không có thông báo
        }

        final notifications = snapshot.data!.docs;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          color: Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thông báo:',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final data =
                      notifications[index].data() as Map<String, dynamic>;
                  return ListTile(
                    leading: const Icon(Icons.notification_important,
                        color: Colors.blue),
                    title: Text(data['message'] ?? ''),
                    subtitle: Text(
                      data['timestamp'] != null
                          ? (data['timestamp'] as Timestamp).toDate().toString()
                          : 'Thời gian không xác định',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('notifications')
                            .doc(notifications[index].id)
                            .delete();
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
