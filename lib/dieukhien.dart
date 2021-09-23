import 'package:web_socket_channel/io.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DieuKhien extends StatefulWidget {
  final Stream<List<double>> stream;
  DieuKhien({Key key, @required this.stream}) : super(key: key);

  @override
  DieuKhienState createState() => DieuKhienState();
}

class DieuKhienState extends State<DieuKhien> {
  double _xDirection = 0.0;
  double _yDirection = 0.0;
  IOWebSocketChannel ioWebSocketChannel;
  bool connected;
  String _ipString = '';
  void channelConnect() {
    try {
      // ket noi den webscoket server ws://serverIP:81
      String wsUrl = "ws://" + _ipString + ":81";
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
