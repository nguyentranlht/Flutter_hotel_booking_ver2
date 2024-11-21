import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ver2/admin/AdminCard.dart';
import 'package:flutter_hotel_booking_ver2/admin/Sidebar.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth < 600;
        final isTablet = screenWidth >= 600 && screenWidth < 1024;
        final isDesktop = screenWidth >= 1024;

        int crossAxisCount = isDesktop
            ? 4
            : isTablet
                ? 3
                : 2;

        return Scaffold(
          drawer: isMobile ? const Sidebar() : null,
          appBar: AppBar(
            automaticallyImplyLeading: false, // Loại bỏ nút back mặc định
            title: const Text('Admin Dashboard'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout), // Biểu tượng đăng xuất
                onPressed: () {
                  // Thực hiện đăng xuất
                  _logout(context);
                },
              ),
            ],
          ),
          body: Row(
            children: [
              if (isDesktop) const Sidebar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 4 / 3,
                    ),
                    itemCount: _adminCards.length,
                    itemBuilder: (context, index) {
                      final card = _adminCards[index];
                      return AdminCard(
                        title: card['title'] as String,
                        icon: card['icon'] as IconData,
                        route: card['route'] as String,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Hàm xử lý đăng xuất
  void _logout(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(
        context, '/login', (Route<dynamic> route) => false);
  }

  List<Map<String, dynamic>> get _adminCards => [
        {
          'title': 'Quản lý\n người dùng',
          'icon': Icons.people,
          'route': '/admin/user-management',
        },
        {
          'title': 'Quản lý\n đặt phòng',
          'icon': Icons.hotel,
          'route': '/admin/booking-management',
        },
        {
          'title': 'Báo cáo',
          'icon': Icons.analytics,
          'route': '/admin/reports',
        },
        {
          'title': 'Quản lý\n nội dung',
          'icon': Icons.dashboard_customize,
          'route': '/admin/app-content',
        },
        {
          'title': 'Quản lý\n tài chính',
          'icon': Icons.attach_money,
          'route': '/admin/finance-management',
        },
      ];
}
