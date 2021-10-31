import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

class SpeedSlider extends StatefulWidget {
  Function writeSpeed;
  SpeedSlider({this.writeSpeed});
  @override
  _SpeedSliderState createState() => _SpeedSliderState();
}

class _SpeedSliderState extends State<SpeedSlider> {
  double _value = 10;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SfSlider.vertical(
        value: _value,
        min: 10,
        max: 100,
        stepSize: 30,
        activeColor: Colors.blue.shade200,
        inactiveColor: Colors.grey,
        showLabels: true,
        showTicks: true,
        interval: 30,
        onChanged: (newValue) {
          if (_value != newValue) {
            setState(() {
              _value = newValue;
              widget.writeSpeed(newValue);
            });
          }
        },
      ),
    );
  }
}
