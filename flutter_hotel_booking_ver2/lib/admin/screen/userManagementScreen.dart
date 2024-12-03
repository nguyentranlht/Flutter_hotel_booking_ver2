import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý người dùng')),
      body: Column(
        children: [
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

                      final mainAxisExtent = isMobile
                          ? 250 // Chiều cao cố định cho Mobile
                          : isTablet
                              ? 300 // Chiều cao cố định cho Tablet
                              : 350; // Chiều cao cố định cho Desktop

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 26,
                          mainAxisExtent: 250,
                        ),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          final userData = user.data() as Map<String, dynamic>;

                          final status = userData['status'] ?? 'unknown';
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
                                  const SizedBox(height: 10),
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
                                        label: const Text('Tạm ngưng',style: TextStyle(color: Colors.white)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent, iconColor: Colors.white
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
                                        inactiveTrackColor: const Color.fromARGB(255, 255, 255, 255),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  if (role == 'user')
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection('notifications')
                                            .add({
                                          'type': 'confirm_owner_role',
                                          'message':
                                              '${userData['fullname']} đã được xác nhận làm Owner.',
                                          'timestamp':
                                              FieldValue.serverTimestamp(),
                                          'userId': user.id,
                                        });

                                        FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(user.id)
                                            .update({'role': 'owner'});

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
                                      label: const Text('Xác nhận làm Owner',style: TextStyle(color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green, iconColor: Colors.white
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
}