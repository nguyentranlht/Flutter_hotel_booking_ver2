import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hotel_booking_ver2/provider/hotel_provider.dart';

class AddHotelScreen extends StatefulWidget {
  const AddHotelScreen({Key? key}) : super(key: key);

  @override
  _AddHotelScreenState createState() => _AddHotelScreenState();
}

class _AddHotelScreenState extends State<AddHotelScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _ratingController = TextEditingController();
  final _imageUrlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm khách sạn')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tên khách sạn'),
            ),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Giá phòng'),
            ),
            TextField(
              controller: _ratingController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Đánh giá'),
            ),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: 'URL hình ảnh'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final hotelData = {
                  'name': _nameController.text,
                  'price': int.tryParse(_priceController.text) ?? 0,
                  'rating': double.tryParse(_ratingController.text) ?? 0.0,
                  'imageUrl': _imageUrlController.text,
                };

                await context.read().addHotel(hotelData);
                Navigator.pop(context);
              },
              child: const Text('Thêm'),
            ),
          ],
        ),
      ),
    );
  }
}