import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel_repository/hotel_repository.dart';

class EditHotelScreen extends StatefulWidget {
  final Hotel hotel;

  const EditHotelScreen({Key? key, required this.hotel}) : super(key: key);

  @override
  State<EditHotelScreen> createState() => _EditHotelScreenState();
}

class _EditHotelScreenState extends State<EditHotelScreen> {
  late TextEditingController _hotelNameController;
  late TextEditingController _hotelAddressController;
  late TextEditingController _descriptionController;
  late TextEditingController _perNightController;
  late TextEditingController _starRatingController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _distanceFromCenterController;
  late TextEditingController _imageURLController;

  bool _isSelected = false;

  @override
  void initState() {
    super.initState();

    // Khởi tạo giá trị ban đầu cho các controller
    _hotelNameController = TextEditingController(text: widget.hotel.hotelName);
    _hotelAddressController =
        TextEditingController(text: widget.hotel.hotelAddress);
    _descriptionController =
        TextEditingController(text: widget.hotel.description);
    _perNightController =
        TextEditingController(text: widget.hotel.perNight.toString());
    _starRatingController =
        TextEditingController(text: widget.hotel.starRating.toString());
    _latitudeController =
        TextEditingController(text: widget.hotel.location.latitude.toString());
    _longitudeController =
        TextEditingController(text: widget.hotel.location.longitude.toString());
    _distanceFromCenterController =
        TextEditingController(text: widget.hotel.distanceFromCenter.toString());
    _imageURLController =
        TextEditingController(text: widget.hotel.imagePath ?? '');
    _isSelected = widget.hotel.isSelected;
  }

  Future<void> _saveChanges() async {
    try {
      await FirebaseFirestore.instance
          .collection('hotels')
          .doc(widget.hotel.hotelId)
          .update({
        'hotelName': _hotelNameController.text,
        'hotelAddress': _hotelAddressController.text,
        'description': _descriptionController.text,
        'perNight': _perNightController.text,
        'starRating': double.parse(_starRatingController.text),
        'location': GeoPoint(double.parse(_latitudeController.text),
            double.parse(_longitudeController.text)),
        'distanceFromCenter': double.parse(_distanceFromCenterController.text),
        'imagePath': _imageURLController.text,
        'isSelected': _isSelected,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật khách sạn thành công!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật khách sạn: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa khách sạn'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _hotelNameController,
              decoration: const InputDecoration(labelText: 'Tên khách sạn'),
            ),
            TextField(
              controller: _hotelAddressController,
              decoration: const InputDecoration(labelText: 'Địa chỉ khách sạn'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Mô tả'),
              maxLines: 3,
            ),
            TextField(
              controller: _perNightController,
              decoration: const InputDecoration(labelText: 'Giá phòng / đêm'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _starRatingController,
              decoration: const InputDecoration(labelText: 'Số sao'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _latitudeController,
              decoration: const InputDecoration(labelText: 'Vĩ độ'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _longitudeController,
              decoration: const InputDecoration(labelText: 'Kinh độ'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _distanceFromCenterController,
              decoration: const InputDecoration(
                  labelText: 'Khoảng cách đến trung tâm (km)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _imageURLController,
              decoration: const InputDecoration(labelText: 'URL hình ảnh'),
            ),
            // SwitchListTile(
            //   title: const Text('Chọn làm khách sạn yêu thích'),
            //   value: _isSelected,
            //   onChanged: (value) {
            //     setState(() {
            //       _isSelected = value;
            //     });
            //   },
            // ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Lưu thay đổi'),
            ),
          ],
        ),
      ),
    );
  }
}
