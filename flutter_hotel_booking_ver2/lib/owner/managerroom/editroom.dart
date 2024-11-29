import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel_repository/hotel_repository.dart';
import 'package:room_repository/room_repository.dart';

class EditRoomScreen extends StatefulWidget {
  final Room room;

  const EditRoomScreen({Key? key, required this.room}) : super(key: key);

  @override
  State<EditRoomScreen> createState() => _EditRoomScreenState();
}

class _EditRoomScreenState extends State<EditRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _roomNameController;
  late TextEditingController _roomTypeController;
  late TextEditingController _pricePerNightController;
  late TextEditingController _capacityController;
  late TextEditingController _maxPeopleController;
  late bool _roomStatus;

  @override
  void initState() {
    super.initState();

    _roomNameController = TextEditingController(text: widget.room.roomName);
    _roomTypeController = TextEditingController(text: widget.room.roomType);
    _pricePerNightController =
        TextEditingController(text: widget.room.pricePerNight);
    _capacityController =
        TextEditingController(text: widget.room.capacity.toString());
    _maxPeopleController =
        TextEditingController(text: widget.room.maxPeople.toString());
    _roomStatus = widget.room.roomStatus;
  }

  Future<void> _updateRoom() async {
    if (_formKey.currentState!.validate()) {
      try {
        final updatedRoom = Room(
          roomId: widget.room.roomId,
          roomName: _roomNameController.text,
          hotelId: widget.room.hotelId,
          imagePath: widget.room.imagePath,
          roomType: _roomTypeController.text,
          pricePerNight: _pricePerNightController.text,
          capacity: int.parse(_capacityController.text),
          roomStatus: _roomStatus,
          maxPeople: int.parse(_maxPeopleController.text),
          availableDates: widget.room.availableDates,
        );

        await FirebaseFirestore.instance
            .collection('rooms')
            .doc(updatedRoom.roomId)
            .update(updatedRoom.toFirestore());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật phòng thành công!')),
        );

        Navigator.pop(context); // Quay lại màn hình trước
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi cập nhật phòng: $e')),
        );
      }
    }
  }

  Future<void> _toggleRoomStatus() async {
    try {
      setState(() {
        _roomStatus = !_roomStatus;
      });

      await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.room.roomId)
          .update({'roomStatus': _roomStatus});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Trạng thái phòng đã được đổi thành ${_roomStatus ? 'Mở' : 'Đóng'}'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi đổi trạng thái phòng: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Room'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _roomNameController,
                decoration: const InputDecoration(labelText: 'Tên phòng'),
                validator: (value) =>
                    value!.isEmpty ? 'Tên phòng không được để trống' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roomTypeController,
                decoration: const InputDecoration(labelText: 'Loại phòng'),
                validator: (value) =>
                    value!.isEmpty ? 'Loại phòng không được để trống' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pricePerNightController,
                decoration: const InputDecoration(labelText: 'Giá mỗi đêm'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Giá không được để trống' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(labelText: 'Sức chứa'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Sức chứa không được để trống' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _maxPeopleController,
                decoration: const InputDecoration(labelText: 'Số người tối đa'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Số người không được để trống' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _updateRoom,
                child: const Text('Lưu thay đổi'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _toggleRoomStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _roomStatus ? Colors.green : Colors.red,
                ),
                child: Text(
                  _roomStatus ? 'Đóng phòng' : 'Mở phòng',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
