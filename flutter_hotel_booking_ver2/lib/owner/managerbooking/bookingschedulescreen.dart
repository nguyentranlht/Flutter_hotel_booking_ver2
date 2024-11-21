import 'package:flutter/material.dart';

class BookingScheduleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Schedule'),
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
            'Booking Schedule',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          ListTile(
            title: Text('Customer: John Doe'),
            subtitle: Text(
                'Room: Deluxe Room\nCheck-in: 2024-11-01\nCheck-out: 2024-11-05'),
            trailing: Text('Confirmed'),
          ),
        ],
      ),
    );
  }
}
