import 'package:flutter/material.dart';

class RoomManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Rooms'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Manage Rooms',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigate to Add Room Screen
            },
            child: Text('Add Room'),
          ),
          ListTile(
            title: Text('Deluxe Room'),
            subtitle: Text('Price: 1,500,000₫'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    // Edit room
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    // Delete room
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
