import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ver2/language/app_localizations.dart';

class SliderView extends StatefulWidget {
  final Function(double) onChangedDistanceValue;
  final double initialDistanceValue;

  const SliderView({
    Key? key,
    required this.onChangedDistanceValue,
    required this.initialDistanceValue,
  }) : super(key: key);

  @override
  State<SliderView> createState() => _SliderViewState();
}

class _SliderViewState extends State<SliderView> {
  late double distanceValue;

  @override
  void initState() {
    distanceValue = widget.initialDistanceValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              Loc.alized.less_than,
              style: TextStyle(fontSize: 16),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                "${distanceValue.toStringAsFixed(1)}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              Loc.alized.km_text,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        Slider(
          value: distanceValue,
          min: 1,
          max: 50,
          divisions: 49,
          label: "${distanceValue.toStringAsFixed(1)} km",
          activeColor: Theme.of(context).primaryColor,
          inactiveColor: Colors.grey.withOpacity(0.4),
          onChanged: (value) {
            setState(() {
              distanceValue = value;
            });
            widget.onChangedDistanceValue(distanceValue);
          },
        ),
      ],
    );
  }
}
