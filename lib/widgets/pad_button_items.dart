import 'package:control_pad/models/gestures.dart';
import 'package:control_pad/models/pad_button_item.dart';
import 'package:flutter/material.dart';
const PAD_BUTTON_ITEMS = [
  PadButtonItem(
      index: 0,
      buttonIcon: Icon(Icons.gps_fixed),
      backgroundColor: Color(0xfff44336),
      pressedColor: Color(0xff1a237e)),
  PadButtonItem(
      supportedGestures: [
        Gestures.TAPDOWN,
        Gestures.TAPUP,
        Gestures.LONGPRESSUP
      ],
      index: 1,
      buttonIcon: Icon(Icons.notifications_active),
      backgroundColor: Color(0xff40c4ff),
      pressedColor: Color(0xff1a237e)),
  PadButtonItem(
      index: 2,
      buttonText: 'AutoFire',
      backgroundColor: Color(0xff4caf50),
      pressedColor: Color(0xff1a237e)),
];
