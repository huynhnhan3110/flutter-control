import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:control_pad/control_pad.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testjoytick/setting_view.dart';
import 'package:testjoytick/widgets/buttons.dart';
import 'package:web_socket_channel/io.dart';

void main() {
  runApp(MyStateLess());
}

class MyStateLess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyStateLess1(),
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

class MyStateLess1 extends StatefulWidget {
  @override
  State<MyStateLess1> createState() => _MyStateLess1State();
}

class _MyStateLess1State extends State<MyStateLess1> {
  StreamController<List<double>> _controller = StreamController<List<double>>();

  GlobalKey<_MyStateFullState> statefulKey = new GlobalKey<_MyStateFullState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade200,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {},
            icon: Icon(
                Icons.signal_wifi_statusbar_connected_no_internet_4_outlined)),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.rightToLeftWithFade,
                        child: SettingView(callbackfun: (){
                          setState(() {
                            ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text("Đang cập nhật lại địa chỉ IP"),));
                          }); // reloads
                        },)));
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
                math.Point npoint =
                    math.Point(math.sin(degree) * temp, math.cos(degree) * temp);

                List<double> tempS = new List<double>();

                tempS.add(npoint.x.toDouble());
                tempS.add(npoint.y.toDouble());
                _controller.add(tempS);
              },
              interval: Duration(milliseconds: 150),
              size: 200,
            ),
            Spacer(),
            MyStateFull(stream: _controller.stream, key: statefulKey),
            Spacer(),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15), topRight: Radius.circular(15)),
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
  String _ipString = '';
  void channelConnect() {
    try {
      // ket noi den webscoket server ws://serverIP:81
      String wsUrl = "ws://"+_ipString+ ":81";
      print(wsUrl);
      ioWebSocketChannel = IOWebSocketChannel.connect(wsUrl);
      
      print("Khoi tao websocket thanh cong");
      // listen
      ioWebSocketChannel.stream.listen((event) {
        print(event);
        if (mounted)
          setState(() {
            if (event == "connected") {
              connected = true;
            }
          });
      }, onDone: () {
        // ket thuc websocket
        print("Websocket da dong");
        if (mounted)
          setState(() {
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
    getIPValuesSF(); 
    widget.stream.listen((event) async {
      if (mounted)
        setState(() {
          _xDirection = event[0];
          _yDirection = event[1];
        });
      await submitCmd('x' + _xDirection.toStringAsFixed(2));
      await submitCmd('y' + _yDirection.toStringAsFixed(2));
    });
    connected = false;
    Future.delayed(Duration.zero, () async {
      await getIPValuesSF();
      channelConnect();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          child: Text(
            "X: " + _xDirection.toStringAsFixed(1),
            style: Theme.of(context).textTheme.button,
          ),
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.green,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20),
        ),
        Container(
          child: Text("Y: " + _yDirection.toStringAsFixed(1),
              style: Theme.of(context).textTheme.button),
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.purple,
          ),
        ),
      ],
    ));
  }

  Future<void> submitCmd(String s) async {
    if (connected == true) {
      ioWebSocketChannel.sink.add(s); // gui trang thai den esp
    } else {
      channelConnect();
      print("Websocket is not connected");
    }
  }
  Future<void> getIPValuesSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
     
     setState(() {
      _ipString = (prefs.getString('ipAddress')) ?? 'Chua lay duoc';
    });
    
  }
}
