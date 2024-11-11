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

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _uploadImage();
    } else {
      print("No image selected");
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;
    try {
      final userId = widget.myUser.userId;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_images/$userId.jpg');
      await storageRef.putFile(_imageFile!);

      // Lấy URL của ảnh từ Firebase Storage
      final photoURL = await storageRef.getDownloadURL();

      // Cập nhật URL ảnh trong Firestore thông qua provider
      await ref.read(userServiceProvider).uploadPicture(photoURL, userId);

      // Cập nhật UI với ảnh mới
      setState(() {
        widget.myUser.picture = photoURL;
      });

      print("Image uploaded successfully");
    } catch (e) {
      print("Error uploading image: $e");
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
              child: ListView.builder(
                padding: EdgeInsets.only(
                    bottom: 16 + MediaQuery.of(context).padding.bottom),
                itemCount: userInfoList.length,
                itemBuilder: (context, index) {
                  return index == 0
                      ? getProfileUI()
                      : InkWell(
                          onTap: () {},
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 8, right: 16),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16.0, bottom: 16, top: 16),
                                        child: Text(
                                          userInfoList[index].titleTxt,
                                          style: TextStyles(context)
                                              .getDescriptionStyle()
                                              .copyWith(
                                                fontSize: 16,
                                              ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 16.0, bottom: 16, top: 16),
                                      child: Text(
                                        index == 1
                                            ? widget.myUser.fullname
                                            : index == 2
                                                ? widget.myUser.email
                                                : index == 3
                                                    ? widget.myUser.phonenumber
                                                    : index == 4
                                                        ? DateFormat('dd/MM/yyyy')
                                                            .format(widget.myUser.birthday)
                                                        : "Default Text",
                                        style: TextStyles(context)
                                            .getRegularStyle()
                                            .copyWith(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                            ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(left: 16, right: 16),
                                child: Divider(
                                  height: 1,
                                ),
                              )
                            ],
                          ),
                        );
                },
              ),
            )
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
                    child: (widget.myUser.picture != null &&
                            widget.myUser.picture!.isNotEmpty)
                        ? Image.network(
                            widget.myUser.picture!,
                            fit: BoxFit.cover,
                          )
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
}