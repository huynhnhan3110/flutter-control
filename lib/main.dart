import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import './screens/controls_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft])
      .then((_) {
    runApp(MainScreen());
  });
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      theme: ThemeData(brightness: Brightness.dark,fontFamily: 'OpenSans'),
      debugShowCheckedModeBanner: false,
      home: ControlsScreen(),
      title: 'WIFIESP8266',
    );
  }
}
