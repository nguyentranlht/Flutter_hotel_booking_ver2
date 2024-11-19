import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Text(
              'Admin Dashboard',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          _buildSidebarItem(context, 'Quản lý người dùng', Icons.people,
              '/admin/user-management'),
          _buildSidebarItem(context, 'Quản lý đặt phòng', Icons.hotel,
              '/admin/booking-management'),
          _buildSidebarItem(
              context, 'Báo cáo', Icons.analytics, '/admin/reports'),
          _buildSidebarItem(context, 'Quản lý nội dung',
              Icons.dashboard_customize, '/admin/app-content'),
          _buildSidebarItem(context, 'Quản lý tài chính', Icons.attach_money,
              '/admin/finance-management'),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
      BuildContext context, String title, IconData icon, String route) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    );
  }
}
