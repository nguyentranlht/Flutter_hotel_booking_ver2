import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:flutter_hotel_booking_ver2/constants/localfiles.dart';
import 'package:flutter_hotel_booking_ver2/constants/text_styles.dart';
import 'package:flutter_hotel_booking_ver2/language/app_localizations.dart';
import 'package:flutter_hotel_booking_ver2/logic/controllers/theme_provider.dart';
import 'package:flutter_hotel_booking_ver2/routes/route_names.dart';
import 'package:flutter_hotel_booking_ver2/widgets/common_button.dart';

import '../../futures/authentication_bloc/authentication_bloc.dart';
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
          // Nếu người dùng đã đăng nhập, hiển thị màn hình chính
          return BottomTabScreen();
        } else {
          // Nếu người dùng chưa đăng nhập, hiển thị SplashScreen
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
