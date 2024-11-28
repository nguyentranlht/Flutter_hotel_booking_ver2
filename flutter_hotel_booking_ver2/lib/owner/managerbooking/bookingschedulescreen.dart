import 'package:booking_repository/booking_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ver2/provider/booking_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotel_repository/hotel_repository.dart';

import '../../constants/themes.dart';

class AllLinkedBookingsScreen extends ConsumerWidget {
  const AllLinkedBookingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linkedBookingsAsync = ref.watch(linkedBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Linked Bookings'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: linkedBookingsAsync.when(
        data: (linkedBookings) {
          if (linkedBookings.isEmpty) {
            return const Center(child: Text('No bookings found.'));
          }

          return ListView.builder(
            itemCount: linkedBookings.length,
            itemBuilder: (context, index) {
              final booking = linkedBookings[index]['booking'] as Booking;
              final hotel = linkedBookings[index]['hotel'] as Hotel;

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      hotel.imagePath ?? '',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image),
                        );
                      },
                    ),
                  ),
                  title: Text('Booking by: ${booking.fullname}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hotel: ${hotel.hotelName}'),
                      Text('Address: ${hotel.hotelAddress}'),
                      Text(
                          'Check-in: ${booking.checkInDate.toLocal().toString().substring(0, 10)}'),
                      Text(
                          'Check-out: ${booking.checkOutDate.toLocal().toString().substring(0, 10)}'),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'delete') {
                        final bookingService =
                            ref.read(bookingServiceProvider);
                        await bookingService.deleteBooking(booking.bookingId);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}