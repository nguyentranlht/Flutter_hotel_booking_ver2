import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hotel_booking_ver2/constants/UserCache.dart';
import 'package:flutter_hotel_booking_ver2/language/app_localizations.dart';
import 'package:flutter_hotel_booking_ver2/modules/login/facebook_google_button_view.dart';
import 'package:flutter_hotel_booking_ver2/routes/route_names.dart';
import 'package:flutter_hotel_booking_ver2/utils/validator.dart';
import 'package:flutter_hotel_booking_ver2/widgets/common_appbar_view.dart';
import 'package:flutter_hotel_booking_ver2/widgets/common_button.dart';
import 'package:flutter_hotel_booking_ver2/widgets/common_text_field_view.dart';
import 'package:flutter_hotel_booking_ver2/widgets/remove_focuse.dart';
<<<<<<< Updated upstream
import 'package:flutter_hotel_booking_ver2/widgets/dialog_widget.dart';
=======
import 'package:user_repository/user_repository.dart';
>>>>>>> Stashed changes
import '../../futures/authentication_bloc/authentication_bloc.dart';

import '../../routes/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _errorEmail = '';
  final TextEditingController _emailController = TextEditingController();
  String _errorPassword = '';
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) async {
<<<<<<< Updated upstream
          if (state is SignInFailure) {
<<<<<<< Updated upstream
            ErrorDialog.show(context, state.error);
=======
            // Hiển thị lỗi khi đăng nhập thất bại
            // ErrorDialog.show(context, state.error);
>>>>>>> Stashed changes
          } else if (state is AuthenticationStateAuthenticated) {
            // Lấy user hiện tại từ Firebase
=======
          if (state is AuthenticationStateAuthenticated) {
>>>>>>> Stashed changes
            final user = FirebaseAuth.instance.currentUser;

            if (user != null) {
              try {
                // Lấy dữ liệu người dùng từ Firestore
                final userDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .get();

                if (userDoc.exists) {
                  final userData = userDoc.data()!;
                  final myUser = MyUser(
                    userId: user.uid,
                    email: userData['email'],
                    fullname: userData['fullname'],
                    picture: userData['picture'],
                    phonenumber: userData['phonenumber'],
                    birthday: (userData['birthday'] as Timestamp)
                        .toDate(), // Chuyển đổi từ Timestamp sang DateTime
                    role: userData['role'],
                    status: userData['status'],
                  );

<<<<<<< Updated upstream
                  if (status == 'suspended') {
                    // Thông báo nếu tài khoản bị tạm ngưng
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Tài khoản của bạn đã bị khóa hoặc tạm ngưng.'),
                      ),
                    );
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushNamed(context, RoutesName.login);
                  } else if (role == 'admin') {
                    // Điều hướng đến trang Admin nếu role là admin
                    Navigator.pushNamed(context, '/admin/dashboard');
                  } else if (role == 'user') {
                    // Điều hướng đến trang chủ nếu role là user
                    Navigator.pushNamed(context, RoutesName.home);
                  } else {
                    // Trường hợp không xác định vai trò
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Vai trò của bạn không hợp lệ')),
                    );
                  }
=======
                  // Lưu vào bộ nhớ đệm
                  await UserCache.saveUserData(myUser);
                  _navigateBasedOnRole(myUser.role, myUser.status, context);
>>>>>>> Stashed changes
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Không tìm thấy dữ liệu người dùng.')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi khi truy cập dữ liệu: $e')),
                );
              }
            } else {
              Navigator.pushNamed(context, RoutesName.login);
            }
          }
        },
        child: RemoveFocuse(
          onClick: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CommonAppbarView(
                iconData: Icons.arrow_back,
                titleText: Loc.alized.login,
                onBackClick: () {
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.only(top: 32),
                        child: FacebookGoogleButtonView(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          Loc.alized.log_with_mail,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                      ),
                      CommonTextFieldView(
                        controller: _emailController,
                        errorText: _errorEmail,
                        titleText: Loc.alized.your_mail,
                        padding: const EdgeInsets.only(
                            left: 24, right: 24, bottom: 16),
                        hintText: Loc.alized.enter_your_email,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (String txt) {},
                      ),
                      CommonTextFieldView(
                        titleText: Loc.alized.password,
                        padding: const EdgeInsets.only(left: 24, right: 24),
                        hintText: Loc.alized.enter_password,
                        isObscureText: true,
                        onChanged: (String txt) {},
                        errorText: _errorPassword,
                        controller: _passwordController,
                      ),
                      _forgotYourPasswordUI(),
                      CommonButton(
                        padding: const EdgeInsets.only(
                            left: 24, right: 24, bottom: 16),
                        buttonText: Loc.alized.login,
                        onTap: () {
                          if (_allValidation()) {
                            // Phát sự kiện đăng nhập khi form hợp lệ
                            context.read<AuthenticationBloc>().add(
                                  SignInRequired(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                  ),
                                );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _forgotYourPasswordUI() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, right: 16, bottom: 8, left: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            onTap: () {
              NavigationServices(context).gotoForgotPassword();
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                Loc.alized.forgot_your_password,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).disabledColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateBasedOnRole(String role, String status, BuildContext context) {
    if (status == 'suspended') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tài khoản của bạn đã bị tạm ngưng.')),
      );
      FirebaseAuth.instance.signOut();
      Navigator.pushNamed(context, RoutesName.login);
    } else if (role == 'admin') {
      Navigator.pushNamed(context, '/admin/dashboard');
    } else if (role == 'owner') {
      Navigator.pushNamed(context, RoutesName.owner);
    } else {
      Navigator.pushNamed(context, RoutesName.home);
    }
  }

  bool _allValidation() {
    bool isValid = true;
    if (_emailController.text.trim().isEmpty) {
      _errorEmail = Loc.alized.email_cannot_empty;
      isValid = false;
    } else if (!Validator.validateEmail(_emailController.text.trim())) {
      _errorEmail = Loc.alized.enter_valid_email;
      isValid = false;
    } else {
      _errorEmail = '';
    }

    if (_passwordController.text.trim().isEmpty) {
      _errorPassword = Loc.alized.password_cannot_empty;
      isValid = false;
    } else if (_passwordController.text.trim().length < 6) {
      _errorPassword = Loc.alized.valid_password;
      isValid = false;
    } else {
      _errorPassword = '';
    }
    setState(() {});
    return isValid;
  }
}
