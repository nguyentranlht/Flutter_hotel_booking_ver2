import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/themes.dart';
import '../../provider/room_provider.dart';
import '../../routes/route_names.dart';

class RoomListScreen extends StatelessWidget {
  final String hotelId;

  const RoomListScreen({Key? key, required this.hotelId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Rooms'),
        backgroundColor: AppTheme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Consumer(
        builder: (context, ref, _) {
          final roomListAsync = ref.watch(roomsProvider(hotelId));

          return roomListAsync.when(
            data: (roomList) {
              if (roomList.isEmpty) {
                return const Center(
                  child: Text('No rooms available.'),
                );
              }
              return ListView.builder(
                itemCount: roomList.length,
                itemBuilder: (context, index) {
                  final room = roomList[index];
                  return ListTile(
                    title: Text(room.roomName),
                    subtitle: Text('Price: ${room.pricePerNight}₫'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Navigate to edit room
                      },
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error loading rooms: $error'),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          NavigationServices(context).gotoAddRoom(hotelId);
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}