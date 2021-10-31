import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:control_pad/models/gestures.dart';
import 'package:control_pad/views/joystick_view.dart';
import 'package:control_pad/views/pad_button_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import '../widgets/info_dialog.dart';
import '../widgets/configuration_dialog.dart';
import '../widgets/speed_slider.dart';
import '../widgets/box_ip.dart';
import '../widgets/pad_button_items.dart';

class ControlsScreen extends StatefulWidget {
  @override
  _ControlsScreenState createState() => _ControlsScreenState();
}

class _ControlsScreenState extends State<ControlsScreen> {
  IOWebSocketChannel _channel;
  String connectionText = "";
  String _ipAddress = '192.168.1.200'; // default ip

  @override
  void initState() {
    super.initState();
    _doConnect();
  }

  void _showDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return ConfigurationDialog();
        }).then((value) {
      if (value == 'Success') {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => ControlsScreen()));
        // });
      }
    });
  }

  Future<void> getIPValuesSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ipValue = prefs.getString('ipAddress');

    if (ipValue != null) {
      setState(() {
        _ipAddress = ipValue;
      });
    }
  }

  void onDirectionChanged(double degree, double distance) {
    degree *= math.pi / 180;
    double temp = distance * 127;
    math.Point npoint =
        math.Point(math.sin(degree) * temp, math.cos(degree) * temp);
    _writeData(npoint.x.toDouble(), npoint.y.toDouble());
  }

  void padButtonPressed(int buttonIndex, Gestures gesture) {
    // String data = 'Button Index :$buttonIndex';
    if (buttonIndex == 1) {
      // buzzer
      if (gesture == Gestures.TAPDOWN) {
        _channel.sink.add('buzzerOn'); // send digital high
      } else {
        _channel.sink.add('buzzerOff'); // send digital low
      }
    }
    if (buttonIndex == 0) {
      print("fire");
     
        _channel.sink.add('Fire');
    }
    if (buttonIndex == 2) {
        _channel.sink.add('AutoFire');
    }
  }

  @override
  Widget build(BuildContext context) {
    var body = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        JoystickView(
          opacity: 0.9,
          onDirectionChanged: onDirectionChanged,
          interval: Duration(milliseconds: 150),
          size: 200,
        ),
        PadButtonsView(
          backgroundPadButtonsColor: Color(0xffc1c1c1),
          buttonsPadding: 10,
          size: 200,
          padButtonPressedCallback: padButtonPressed,
          buttons: PAD_BUTTON_ITEMS,
        )
      ],
    );

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                return showDialog(
                    context: context, builder: (context) => InfoDialog());
              },
              icon: Icon(Icons.info_outline)),
          IconButton(
            onPressed: () {
              _showDialog(context);
            },
            icon: Icon(Icons.settings),
          )
        ],
        title: Text(
          connectionText,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
          child: Stack(
        children: [
          body,
          Positioned(
            child: Column(
              children: [
                Image.asset(
                  'assets/images/speedometer.png',
                  width: 27,
                ),
                SpeedSlider(writeSpeed: (newValue)  {
                  print("speed $newValue");
                   _channel.sink.add('s$newValue');
                }),
              ],
            ),
            left: 0,
            top: MediaQuery.of(context).size.height / 2 - 167,
          ),
          Positioned.fill(
            child: Align(
              child: BoxIp(
                ip: _ipAddress,
              ),
              alignment: Alignment.bottomCenter,
            ),
            bottom: 10,
          ),
          Positioned.fill(
            top: 20,
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                _ipAddress == '192.168.4.1'
                    ? 'Access Point Mode'
                    : 'Station Mode',
                style: TextStyle(fontSize: 19),
              ),
            ),
          ),
        ],
      )),
    );
  }

  void _writeData(double x, double y) async {
    String xPosition = 'x' + x.toStringAsFixed(2);
    String yPosition = 'y' + y.toStringAsFixed(2);
    print(xPosition);
    print(yPosition);
    await _channel.sink.add(xPosition); // gui trang thai den esp
    await _channel.sink.add(yPosition); // gui trang thai den esp
  }

  void _doConnect() async {
    setState(() {
      connectionText = "Start Scanning";
    });
    await getIPValuesSF();
    if (this._channel != null) {
      close();
    }

    this._channel = IOWebSocketChannel.connect(
      'ws://$_ipAddress:81',
      pingInterval: Duration(
        seconds: 1,
      ),
    );
    this._channel.stream.listen(onReceiveData,
        onDone: onClosed, onError: onError, cancelOnError: false);
  }

  void onReceiveData(data) {
    print("websocket receive data:$data");
    print(_ipAddress);
    setState(() {
      connectionText = "All Ready with ESP8266";
    });
  }

  void onClosed() {
    print("websocket closed");
    setState(() {
      connectionText = "Device can't connected";
    });
    new Future.delayed(Duration(seconds: 1), () {
      print("websocket reconnect...");
      _doConnect();
    });
  }

  onError(err, StackTrace stackTrace) {
    print("websocket error:" + err.toString());
    // if (stackTrace != null) {
    //   // print(stackTrace);
    // }
  }

  void close() {
    this._channel.sink.close();
  }
}
