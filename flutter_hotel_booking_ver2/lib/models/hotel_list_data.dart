import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_hotel_booking_ver2/constants/localfiles.dart';
import 'package:flutter_hotel_booking_ver2/models/room_data.dart';

class HotelListData {
  String imagePath;
  String titleTxt;
  String subTxt;
  DateText? date;
  String dateTxt;
  String roomSizeTxt;
  RoomData? roomData;
  double dist;
  double rating;
  int reviews;
  int perNight;
  bool isSelected;
  PeopleSleeps? peopleSleeps;
  LatLng? location;
  Offset? screenMapPin; // we used this screen Offset for adding on Map layer

  HotelListData({
    this.imagePath = '',
    this.titleTxt = '',
    this.subTxt = "",
    this.dateTxt = "",
    this.roomSizeTxt = "",
    this.roomData,
    this.dist = 1.8,
    this.reviews = 80,
    this.rating = 4.5,
    this.perNight = 180,
    this.isSelected = false,
    this.date,
    this.peopleSleeps,
    this.location,
    this.screenMapPin,
  });

  // we need location in this hotelList bcz we using that in map
  static List<HotelListData> hotelList = [
    HotelListData(
      imagePath: Localfiles.hotel_1,
      titleTxt: 'Grand Royal Hotel',
      subTxt: 'Wembley, London',
      dist: 2.0,
      reviews: 80,
      rating: 4.4,
      perNight: 180,
      roomData: RoomData(1, 2),
      isSelected: true,
      date: DateText(1, 5),
      location: const LatLng(10.8390529, 106.7824432),
    ),
    HotelListData(
      imagePath: Localfiles.hotel_2,
      titleTxt: 'Queen Hotel',
      subTxt: 'Wembley, London',
      dist: 4.0,
      reviews: 74,
      rating: 4.5,
      perNight: 200,
      roomData: RoomData(1, 3),
      isSelected: false,
      date: DateText(2, 6),
      location: const LatLng(51.505799, -0.137904),
    ),
    HotelListData(
      imagePath: Localfiles.hotel_3,
      titleTxt: 'Grand Royal Hotel',
      subTxt: 'Wembley, London',
      dist: 3.0,
      reviews: 62,
      rating: 4.0,
      perNight: 60,
      roomData: RoomData(2, 3),
      isSelected: false,
      date: DateText(5, 9),
      location: const LatLng(51.499162, -0.119788),
    ),
    HotelListData(
      imagePath: Localfiles.hotel_4,
      titleTxt: 'Queen Hotel',
      subTxt: 'Wembley, London',
      dist: 7.0,
      reviews: 90,
      rating: 4.4,
      perNight: 170,
      isSelected: false,
      roomData: RoomData(2, 2),
      date: DateText(1, 5),
      location: const LatLng(51.519541, -0.114503),
    ),
    HotelListData(
      imagePath: Localfiles.hotel_5,
      titleTxt: 'Grand Royal Hotel',
      subTxt: 'Wembley, London',
      dist: 2.0,
      reviews: 240,
      rating: 4.5,
      isSelected: false,
      perNight: 200,
      roomData: RoomData(1, 7),
      date: DateText(1, 4),
      location: const LatLng(51.508383, -0.109502),
    ),
  ];

  static List<HotelListData> popularList = [
    HotelListData(
      imagePath: Localfiles.popular_1,
      titleTxt: 'Quận 1',
    ),
    HotelListData(
      imagePath: Localfiles.popular_2,
      titleTxt: 'Quận 7',
    ),
    HotelListData(
      imagePath: Localfiles.popular_3,
      titleTxt: 'Thủ Đức',
    ),
    HotelListData(
      imagePath: Localfiles.popular_4,
      titleTxt: 'Quận 10',
    ),
    HotelListData(
      imagePath: Localfiles.popular_5,
      titleTxt: 'Quận Bình Thạnh',
    ),
    HotelListData(
      imagePath: Localfiles.popular_6,
      titleTxt: 'Quận 5',
    ),
  ];

  static List<HotelListData> hotelTypeList = [
    HotelListData(
      imagePath: Localfiles.hotelType_1,
      titleTxt: 'hotel_data',
      isSelected: false,
    ),
    HotelListData(
      imagePath: Localfiles.hotelType_2,
      titleTxt: 'Backpacker_data',
      isSelected: false,
    ),
    HotelListData(
      imagePath: Localfiles.hotelType_3,
      titleTxt: 'Resort_data',
      isSelected: false,
    ),
    HotelListData(
      imagePath: Localfiles.hotelType_4,
      titleTxt: 'villa_data',
      isSelected: false,
    ),
    HotelListData(
      imagePath: Localfiles.hotelType_5,
      titleTxt: 'apartment',
      isSelected: false,
    ),
    HotelListData(
      imagePath: Localfiles.hotelType_6,
      titleTxt: 'guest_house',
      isSelected: false,
    ),
    HotelListData(
      imagePath: Localfiles.hotelType_7,
      titleTxt: 'motel',
      isSelected: false,
    ),
    HotelListData(
      imagePath: Localfiles.hotelType_8,
      titleTxt: 'accommodation',
      isSelected: false,
    ),
    HotelListData(
      imagePath: Localfiles.hotelType_9,
      titleTxt: 'Bed_breakfast',
      isSelected: false,
    ),
  ];
  static List<HotelListData> lastsSearchesList = [
    HotelListData(
      imagePath: Localfiles.popular_4,
      titleTxt: 'London',
      roomData: RoomData(1, 3),
      date: DateText(12, 22),
      dateTxt: '12 - 22 Dec',
    ),
    HotelListData(
      imagePath: Localfiles.popular_1,
      titleTxt: 'Paris',
      roomData: RoomData(1, 3),
      date: DateText(12, 24),
      dateTxt: '12 - 24 Sep',
    ),
    HotelListData(
      imagePath: Localfiles.city_3,
      titleTxt: 'New York',
      roomData: RoomData(1, 3),
      date: DateText(20, 22),
      dateTxt: '20 - 22 Sep',
    ),
    HotelListData(
      imagePath: Localfiles.city_4,
      titleTxt: 'Tokyo',
      roomData: RoomData(12, 22),
      date: DateText(12, 22),
      dateTxt: '12 - 22 Nov',
    ),
    HotelListData(
      imagePath: Localfiles.city_5,
      titleTxt: 'Shanghai',
      roomData: RoomData(10, 15),
      date: DateText(10, 15),
      dateTxt: '10 - 15 Dec',
    ),
    HotelListData(
      imagePath: Localfiles.city_6,
      titleTxt: 'Moscow',
      roomData: RoomData(12, 14),
      date: DateText(12, 14),
      dateTxt: '12 - 14 Dec',
    ),
  ];
}
