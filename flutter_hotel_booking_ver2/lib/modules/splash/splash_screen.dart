import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hotel_booking_ver2/admin/AdminDashboard.dart';
import 'package:get/get.dart';
import 'package:flutter_hotel_booking_ver2/constants/localfiles.dart';
import 'package:flutter_hotel_booking_ver2/constants/text_styles.dart';
import 'package:flutter_hotel_booking_ver2/language/app_localizations.dart';
import 'package:flutter_hotel_booking_ver2/logic/controllers/theme_provider.dart';
import 'package:flutter_hotel_booking_ver2/routes/route_names.dart';
import 'package:flutter_hotel_booking_ver2/widgets/common_button.dart';

import '../../futures/authentication_bloc/authentication_bloc.dart';
import '../../owner/ownerdashboard.dart';
import '../bottom_tab/bottom_tab_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLoadText = false;

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _loadAppLocalizations());
    super.initState();
  }

  Future<void> _loadAppLocalizations() async {
    try {
      setState(() {
        isLoadText = true;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        if (state is AuthenticationStateAuthenticated) {
          final userId = state.user.uid;

          return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Scaffold(
                  body: Center(
                    child: Text('Lỗi: ${snapshot.error}'),
                  ),
                );
              }

              if (snapshot.hasData && snapshot.data?.data() != null) {
                final data = snapshot.data!.data()!;
                final role = data['role'] ?? 'user';
                final status = data['status'] ?? 'active';

                if (status != 'active') {
                  // Hiển thị thông báo trạng thái tài khoản không hợp lệ
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Tài khoản bị tạm ngưng'),
                          content: const Text(
                            'Tài khoản của bạn đã bị khóa hoặc tạm ngưng. Vui lòng liên hệ bộ phận hỗ trợ để biết thêm chi tiết.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                // Đăng xuất người dùng
                                context
                                    .read<AuthenticationBloc>()
                                    .add(SignOutRequired());
                                Navigator.of(context).pop(); // Đóng Dialog
                                NavigationServices(context).gotoLoginScreen();
                              },
                              child: const Text('Đăng xuất'),
                            ),
                          ],
                        );
                      },
                    );
                  });

                  // Ngăn các widget tiếp tục xây dựng khi tài khoản không hợp lệ
                  return const SizedBox();
                }

                // Điều hướng dựa trên vai trò
                if (role == 'admin') {
                  return AdminDashboard();
                } else if (role == 'owner') {
                  return OwnerDashboard();
                } else if (role == 'user') {
                  return BottomTabScreen();
                } else {
                  return Scaffold(
                    body: Center(
                      child: Text('Vai trò không hợp lệ: $role'),
                    ),
                  );
                }
              }

              return Scaffold(
                body: Center(
                  child: Text('Không tìm thấy dữ liệu người dùng.'),
                ),
              );
            },
          );
        } else {
          return Scaffold(
            body: Stack(
              children: <Widget>[
                Container(
                  foregroundDecoration: !Get.find<ThemeController>().isLightMode
                      ? BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .background
                              .withOpacity(0.4))
                      : null,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Image.asset(
                    Localfiles.introduction,
                    fit: BoxFit.cover,
                  ),
                ),
                Column(
                  children: <Widget>[
                    const Expanded(
                      flex: 1,
                      child: SizedBox(),
                    ),
                    Center(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Theme.of(context).dividerColor,
                              offset: const Offset(1.1, 1.1),
                              blurRadius: 10.0,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                          child: Image.asset(Localfiles.appIcon),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Text(
                      "Hotel",
                      textAlign: TextAlign.left,
                      style: TextStyles(context)
                          .getBoldStyle()
                          .copyWith(fontSize: 24, color: Colors.white),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    AnimatedOpacity(
                      opacity: isLoadText ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 420),
                      child: Text(
                        Loc.alized.best_hotel_deals,
                        textAlign: TextAlign.left,
                        style: TextStyles(context)
                            .getRegularStyle()
                            .copyWith(color: Colors.white),
                      ),
                    ),
                    const Expanded(
                      flex: 4,
                      child: SizedBox(),
                    ),
                    AnimatedOpacity(
                      opacity: isLoadText ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 680),
                      child: CommonButton(
                        padding: const EdgeInsets.only(
                            left: 48, right: 48, bottom: 8, top: 8),
                        buttonText: Loc.alized.get_started,
                        onTap: () {
                          NavigationServices(context).gotoIntroductionScreen();
                        },
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: isLoadText ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 1200),
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: 24.0 + MediaQuery.of(context).padding.bottom,
                          top: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
