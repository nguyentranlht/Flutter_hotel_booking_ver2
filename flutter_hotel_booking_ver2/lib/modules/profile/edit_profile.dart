import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ver2/constants/localfiles.dart';
import 'package:flutter_hotel_booking_ver2/constants/text_styles.dart';
import 'package:flutter_hotel_booking_ver2/constants/themes.dart';
import 'package:flutter_hotel_booking_ver2/language/app_localizations.dart';
import 'package:flutter_hotel_booking_ver2/widgets/common_appbar_view.dart';
import 'package:flutter_hotel_booking_ver2/widgets/common_card.dart';
import 'package:flutter_hotel_booking_ver2/widgets/remove_focuse.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_repository/user_repository.dart';
import '../../models/setting_list_data.dart';
import '../../provider/user_provider.dart';

class EditProfile extends ConsumerStatefulWidget {
  final MyUser myUser;
  const EditProfile({Key? key, required this.myUser}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends ConsumerState<EditProfile> {
  List<SettingsListData> userInfoList = SettingsListData.userInfoList;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Các bộ điều khiển cho các trường thông tin người dùng
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.myUser.fullname);
    _emailController = TextEditingController(text: widget.myUser.email);
    _phoneController = TextEditingController(text: widget.myUser.phonenumber);
  }

  // Hàm chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    } else {
      print("Chưa chọn ảnh nào");
    }
  }

  // Hàm lưu thay đổi (bao gồm tải lên ảnh nếu có và cập nhật thông tin người dùng)
  Future<void> _saveChanges() async {
    try {
      String? photoURL;

      // Kiểm tra nếu có ảnh mới thì tải ảnh lên và lấy URL
      if (_imageFile != null) {
        final userId = widget.myUser.userId;
        final storageRef =
            FirebaseStorage.instance.ref().child('user_images/$userId.jpg');
        await storageRef.putFile(_imageFile!);
        photoURL = await storageRef.getDownloadURL();
      }

      // Cập nhật thông tin người dùng với dữ liệu mới
      final updatedUser = widget.myUser.copyWith(
        fullname: _nameController.text,
        phonenumber: _phoneController.text,
        picture: photoURL ?? widget.myUser.picture,
      );

      // Sử dụng provider để cập nhật Firestore
      await ref.read(userServiceProvider).updateUser(updatedUser);

      setState(() {
        // Cập nhật đối tượng người dùng trong UI để phản ánh ngay lập tức
        widget.myUser.fullname = _nameController.text;
        widget.myUser.phonenumber = _phoneController.text;
        widget.myUser.picture = photoURL ?? widget.myUser.picture;
      });
      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Loc.alized.update_user_successfully),
          backgroundColor: Colors.green,
        ),
      );
      print("Đã cập nhật thông tin người dùng thành công");
    } catch (e) {
      print("Lỗi khi cập nhật thông tin người dùng: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      body: RemoveFocuse(
        onClick: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CommonAppbarView(
              iconData: Icons.arrow_back,
              titleText: Loc.alized.edit_profile,
              onBackClick: () {
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(
                    bottom: 16 + MediaQuery.of(context).padding.bottom),
                children: [
                  getProfileUI(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEditableField(
                            Loc.alized.full_name, _nameController),
                        _buildEditableField("Email", _emailController,
                            enabled: false),
                        _buildEditableField(Loc.alized.phone, _phoneController),
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: ElevatedButton(
                            onPressed: _saveChanges,
                            child: Text(Loc.alized.update),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getProfileUI() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 130,
            height: 130,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Theme.of(context).dividerColor,
                        blurRadius: 8,
                        offset: const Offset(4, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(60.0)),
                    child: (_imageFile != null)
                        ? Image.file(_imageFile!, fit: BoxFit.cover)
                        : (widget.myUser.picture != null &&
                                widget.myUser.picture!.isNotEmpty)
                            ? Image.network(widget.myUser.picture!,
                                fit: BoxFit.cover)
                            : Icon(Icons.person,
                                size: 70.0,
                                color: const Color.fromARGB(179, 41, 40, 40)),
                  ),
                ),
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: CommonCard(
                    color: AppTheme.primaryColor,
                    radius: 36,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(24.0)),
                        onTap: _pickImage,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.camera_alt,
                            color: Theme.of(context).colorScheme.background,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller,
      {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
