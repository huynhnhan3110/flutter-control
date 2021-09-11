import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:control_pad/control_pad.dart';
import 'package:web_socket_channel/io.dart';

void main() {
  runApp(MyStateLess());
}
class MyStateLess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyStateLess1(),
      
    );
  }
}
class MyStateLess1 extends StatelessWidget {
  StreamController<List<double>> _controller = StreamController<List<double>>();

  GlobalKey<_MyStateFullState> statefulKey = new GlobalKey<_MyStateFullState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("CT"),),
      body: Column(children: <Widget>[
          Padding(padding: const EdgeInsets.only(top: 20)),
          JoystickView(
            onDirectionChanged: (degree, direction) {
              degree *= math.pi / 180;
              double temp = direction * 127;
              math.Point npoint = math.Point(
                math.sin(degree) * temp, math.cos(degree) * temp
              );

              List<double> tempS = new List<double>();

              tempS.add(npoint.x.toDouble());
              tempS.add(npoint.y.toDouble());
              _controller.add(tempS);
            },
            interval: Duration(milliseconds: 150),
            showArrows: false,
            size:300,
          ),
          MyStateFull(stream: _controller.stream, key: statefulKey),
        ],
      ),
    );
  }
}

class MyStateFull extends StatefulWidget {
  final Stream<List<double>> stream;
  MyStateFull({Key key, @required this.stream}) : super(key: key);

  @override
  _MyStateFullState createState() => _MyStateFullState();
}

class _MyStateFullState extends State<MyStateFull> {
  double _xDirection = 0.0;
  double _yDirection = 0.0;
  IOWebSocketChannel ioWebSocketChannel;
   bool connected;
  void channelConnect() {
    try {
      // create socket server
      ioWebSocketChannel = IOWebSocketChannel.connect('ws://192.168.0.1:81');
      print("Khoi tao websocket thanh cong");
      // listen
      ioWebSocketChannel.stream.listen((event) {
        print(event);
        if(mounted)setState(() {
          if(event == "connected") {
              connected = true;
          }
        });
      }, onDone: () {
        // ket thuc websocket
        print("Websocket da dong");
        if(mounted)setState(() {
          connected = false;
        });
      }, onError: (error) {
        print(error.toString());
      });
    } catch (_) {
      print("Co loi khi tao websocket");
    }
  }
  @override
  void initState() {
    super.initState();
    widget.stream.listen((event) async{
      if(mounted)setState(() {
        _xDirection = event[0];
        _yDirection = event[1];
      });
      await _submitCmd('x'+_xDirection.toStringAsFixed(2));
      await _submitCmd('y'+_yDirection.toStringAsFixed(2));
    });
    connected = false;
    Future.delayed(Duration.zero, () async {
      channelConnect();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(padding: EdgeInsets.only(top: 200),),
          Container(
            child: Text("X position: "+_xDirection.toStringAsFixed(1), style: TextStyle(color: Colors.white,fontSize: 30)),
            padding: const EdgeInsets.only(left: 20,right: 20,top: 5,bottom: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.green,
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: 20),),
          Container(
            child: Text("Y position: "+_xDirection.toStringAsFixed(1), style: TextStyle(color: Colors.white,fontSize: 30)),
            padding: const EdgeInsets.only(left: 20,right: 20,top: 5,bottom: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.purple,
            ),
          )
        ],
      )
    );
  }
  Future<void> _submitCmd(String s) async{
    if(connected == true) {
      ioWebSocketChannel.sink.add(s); // gui trang thai den esp
    } else {
      channelConnect();
      print("Websocket is not connected");
    }
  }
}