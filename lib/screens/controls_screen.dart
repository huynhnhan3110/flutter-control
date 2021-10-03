import 'package:control_pad/models/gestures.dart';
import 'package:control_pad/models/pad_button_item.dart';
import 'package:control_pad/views/joystick_view.dart';
import 'package:control_pad/views/pad_button_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:math' as math;
import '../widgets/configuration_dialog.dart';

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

  @override
  Widget build(BuildContext context) {
    JoystickDirectionCallback onDirectionChanged(
        double degree, double distance) {
      degree *= math.pi / 180;
      double temp = distance * 127;
      math.Point npoint =
          math.Point(math.sin(degree) * temp, math.cos(degree) * temp);
      _writeData(npoint.x.toDouble(), npoint.y.toDouble());
    }

    PadButtonPressedCallback padButtonPressed(
        int buttonIndex, Gestures gesture) {
      String data = 'Button Index :$buttonIndex';
      print(data);
    }

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
          buttons: [
            PadButtonItem(
                index: 0,
                buttonIcon: Icon(Icons.gps_fixed),
                backgroundColor: Color(0xfff44336),
                pressedColor: Color(0xff1a237e)),
            PadButtonItem(
                index: 1,
                buttonIcon: Icon(Icons.notifications_active),
                backgroundColor: Color(0xff40c4ff),
                pressedColor: Color(0xff1a237e)),
            PadButtonItem(
                index: 2,
                buttonText: 'AutoFire',
                backgroundColor: Color(0xff4caf50),
                pressedColor: Color(0xff1a237e)),
          ],
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
            right: MediaQuery.of(context).size.width / 2 - 100,
            child: Container(
              alignment: Alignment.center,
              width: 200,
              decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey)),
              height: 30,
              child: Text(
                _ipAddress,
              ),
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
