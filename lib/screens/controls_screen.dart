import 'package:control_pad/models/gestures.dart';
import 'package:control_pad/views/joystick_view.dart';
import 'package:control_pad/views/pad_button_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testjoytick/widgets/pad_button_items.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:math' as math;
import '../widgets/configuration_dialog.dart';
import '../widgets/speed_slider.dart';
import '../widgets/box_ip.dart';

class ControlsScreen extends StatefulWidget {
  @override
  _ControlsScreenState createState() => _ControlsScreenState();
}

class _ControlsScreenState extends State<ControlsScreen> {
  IOWebSocketChannel _channel;
  String connectionText = "";
  String _ipAddress = '192.168.1.56'; // default ip
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
        setState(() {
          connectionText = 'Update success';
        });
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
  void onDirectionChanged(
        double degree, double distance) {
      degree *= math.pi / 180;
      double temp = distance * 127;
      math.Point npoint =
          math.Point(math.sin(degree) * temp, math.cos(degree) * temp);
      _writeData(npoint.x.toDouble(), npoint.y.toDouble());
    }

    void padButtonPressed(
        int buttonIndex, Gestures gesture) {
      // String data = 'Button Index :$buttonIndex';
      if (buttonIndex == 1) {
        // buzzer
        if (gesture == Gestures.TAPDOWN) {
          _channel.sink.add('buzzerOn'); // send digital high
        } else {
          _channel.sink.add('buzzerOff'); // send digital low
        }
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
              _showDialog(context);
            },
            icon: Icon(Icons.settings),
          )
        ],
        title: Text(connectionText),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
          child: Stack(
        children: [
          body,
          Positioned(
            child: SpeedSlider(writeSpeed: (newValue) {
              print('Gui di toc do.....');
              print("speed $newValue");
              _channel.sink.add('speed:$newValue');
            }),
            left: 0,
            top: MediaQuery.of(context).size.height / 2 - 140,
          ),
          Positioned(
            right: MediaQuery.of(context).size.width / 2 - 100,
            child: BoxIp(
              ip: _ipAddress,
            ),
            bottom: 10,
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

  void _doConnect() {
    setState(() {
      connectionText = "Start Scanning";
    });
    getIPValuesSF();
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
    // Protocol protocol = Protocol(data);
    // ProtocolManager().dispatch(protocol);
    print("websocket receive data:$data");
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
    if (stackTrace != null) {
      // print(stackTrace);
    }
  }

  void close() {
    this._channel.sink.close();
  }
}
