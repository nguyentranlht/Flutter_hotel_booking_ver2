import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hotel_repository/hotel_repository.dart';
import '../../constants/themes.dart';
import '../../provider/hotel_filter_prodiver.dart';
import '../../provider/hotel_provider.dart';

class AddHotelScreen extends ConsumerStatefulWidget {
  const AddHotelScreen({Key? key}) : super(key: key);

  @override
  _AddHotelScreenState createState() => _AddHotelScreenState();
}

class _AddHotelScreenState extends ConsumerState<AddHotelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hotelNameController = TextEditingController();
  final _hotelAddressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _perNightController = TextEditingController();
  final _starRatingController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _distanceFromCenterController = TextEditingController();
  final _imageURLController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final addHotelState = ref.watch(addHotelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Hotel'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              TextFormField(
                controller: _hotelNameController,
                decoration: const InputDecoration(labelText: 'Hotel Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a name' : null,
              ),
              TextFormField(
                controller: _hotelAddressController,
                decoration: const InputDecoration(labelText: 'Hotel Address'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter an address' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a description' : null,
              ),
              TextFormField(
                controller: _perNightController,
                decoration: const InputDecoration(labelText: 'Per Night Cost'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter cost per night'
                    : null,
              ),
              TextFormField(
                controller: _starRatingController,
                decoration: const InputDecoration(labelText: 'Star Rating'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter star rating (e.g., 4.5)'
                    : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      decoration: const InputDecoration(
                          labelText: 'Latitude (Location)'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter latitude'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      decoration: const InputDecoration(
                          labelText: 'Longitude (Location)'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter longitude'
                          : null,
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _distanceFromCenterController,
                decoration:
                    const InputDecoration(labelText: 'Distance from Center'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter distance from city center'
                    : null,
              ),
              TextFormField(
                controller: _imageURLController,
                decoration: const InputDecoration(labelText: 'Hotel Image URL'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter image URL' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final hotel = Hotel(
                      hotelId: '', // Firestore will generate this
                      hotelName: _hotelNameController.text,
                      hotelAddress: _hotelAddressController.text,
                      description: _descriptionController.text,
                      perNight: _perNightController.text,
                      location: LatLng(
                        double.parse(_latitudeController.text),
                        double.parse(_longitudeController.text),
                      ),
                      starRating: double.parse(_starRatingController.text),
                      dist: double.parse(_distanceFromCenterController.text),
                      distanceFromCenter:
                          double.parse(_distanceFromCenterController.text),
                      userId: FirebaseAuth.instance.currentUser!.uid, // Replace with current user ID
                      imagePath: _imageURLController.text, 
                      isSelected: false,
                    );

                    await ref.read(addHotelProvider.notifier).addHotel(hotel);
                    ref.refresh(filteredHotelProvider);
                  }
                },
                child: const Text('Add Hotel'),
              ),
              if (addHotelState.isLoading)
                const Center(child: CircularProgressIndicator()),
              if (addHotelState.hasError)
                Text(
                  'Error: ${addHotelState.error}',
                  style: const TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }
}