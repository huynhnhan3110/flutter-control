import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:control_pad/control_pad.dart';
import './setting_view.dart';
import '../widgets/buttons.dart';
import './dieukhien.dart';
void main() {
  runApp(MyStateLess());
}

class MyStateLess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage(),
      theme: ThemeData(
          primaryColor: Color(0xff2196f3),
          textTheme: ThemeData.light().textTheme.copyWith(
              button: TextStyle(
                color: Colors.white,
              ),
              bodyText1: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ))),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  StreamController<List<double>> _controller = StreamController<List<double>>();

  GlobalKey<DieuKhienState> statefulKey = new GlobalKey<DieuKhienState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {},
            icon: Icon(
                Icons.signal_wifi_statusbar_connected_no_internet_4_outlined)),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => SettingView()));
              },
              icon: Icon(Icons.settings)),
        ],
        title: Text(
          "CHƯƠNG TRÌNH ĐIỀU KHIỂN",
          style: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(color: Colors.white),
        ),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(padding: const EdgeInsets.only(top: 10)),
            Buttons(),
            Spacer(),
            JoystickView(
              opacity: 0.9,
              onDirectionChanged: (degree, direction) {
                degree *= math.pi / 180;
                double temp = direction * 127;
                math.Point npoint = math.Point(
                    math.sin(degree) * temp, math.cos(degree) * temp);

                List<double> tempS = new List<double>();

                tempS.add(npoint.x.toDouble());
                tempS.add(npoint.y.toDouble());
                _controller.add(tempS);
              },
              interval: Duration(milliseconds: 150),
              size: 200,
            ),
            Spacer(),
            DieuKhien(stream: _controller.stream, key: statefulKey),
            Spacer(),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)),
                color: Colors.white,
              ),
              width: double.infinity,
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "29.5°C",
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(fontSize: 30),
                      ),
                      Text("Nhiệt độ hiện tại"),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "78%",
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(fontSize: 30),
                      ),
                      Text("Độ ẩm hiện tại"),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
