import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RangeSliderView extends StatelessWidget {
  final RangeValues values;
  final Function(RangeValues) onChangeRangeValues;
  final NumberFormat oCcy = NumberFormat("#,##0", "vi_VN");

  RangeSliderView({
    Key? key,
    required this.values,
    required this.onChangeRangeValues,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${oCcy.format(values.start)}₫"),
              Text("${oCcy.format(values.end)}₫"),
            ],
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Theme.of(context).primaryColor,
            inactiveTrackColor: Colors.grey.withOpacity(0.4),
          ),
          child: RangeSlider(
            values: values,
            min: 100000.0,
            max: 2000000.0,
            divisions: 100,
            labels: RangeLabels(
              "${oCcy.format(values.start)}₫",
              "${oCcy.format(values.end)}₫",
            ),
            onChanged: (newValues) {
              onChangeRangeValues(newValues);
            },
          ),
        ),
      ],
    );
  }
}
