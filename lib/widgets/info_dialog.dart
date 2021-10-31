import 'package:flutter/material.dart';

class InfoDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: const EdgeInsets.all(18),
      title: const Text("Information"),
      children: [
        const Text(
          'The default IP at Station mode (Internet WiFi):\n192.168.1.200\n\nIP AccessPoint (ESP8266 WiFi): \n192.168.4.1',
          style: TextStyle(color: Colors.white60),
        ),
      ],
    );
  }
}
