import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ver2/constants/themes.dart';
import 'package:flutter_hotel_booking_ver2/owner/managerbooking/bookingschedulescreen.dart';
import 'package:flutter_hotel_booking_ver2/owner/managehotel/managehotelsscreen.dart';
import 'package:flutter_hotel_booking_ver2/owner/managerroom/manageroomsscreen.dart';
import 'package:flutter_hotel_booking_ver2/owner/revenuereport/revenuereportscreen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OwnerDashboard extends ConsumerWidget {
  const OwnerDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final userId = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Owner Dashboard"),
        backgroundColor: AppTheme.primaryColor,
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome, Owner!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardCard(
                    context,
                    title: "Manage Hotels",
                    icon: Icons.hotel,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => HotelListScreen()),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    title: "Manage Rooms",
                    icon: Icons.bed,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RoomManagementScreen()),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    title: "Booking Schedule",
                    icon: Icons.schedule,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => BookingScheduleScreen()),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    title: "Revenue Report",
                    icon: Icons.bar_chart,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => RevenueReportScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: AppTheme.primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    // Ví dụ: Xử lý đăng xuất với Firebase Auth
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(
        context, '/login'); // Điều hướng đến trang đăng nhập
  }
}
