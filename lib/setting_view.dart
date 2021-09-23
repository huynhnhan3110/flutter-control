import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingView extends StatefulWidget {
  Function callbackfun;

  SettingView({this.callbackfun});

  @override
  _SettingViewState createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  TextEditingController _ipAddressController = new TextEditingController();
  String _ipString;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getIPValuesSF();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              widget.callbackfun();
              Navigator.pop(context);
            },
          ),
          title: Text("Cấu hình thiết bị"),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ĐỊA CHỈ IP CỦA THIẾT BỊ",
                style: TextStyle(
                    color: Colors.purple,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Padding(padding: const EdgeInsets.symmetric(vertical: 5)),
              Row(
                children: [
                  Icon(
                    Icons.phonelink_ring,
                    color: Colors.blue,
                  ),
                  Text(_ipString != null ? _ipString : 'Chưa cập nhật',
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 19,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              TextField(
                controller: _ipAddressController,
                maxLength: 15,
                decoration: InputDecoration(hintText: "Địa chỉ IP mới"),
              ),
              Padding(padding: const EdgeInsets.symmetric(vertical: 5)),
              Center(
                child: ElevatedButton(
                    onPressed: () {
                      print("Cap nhat dia chi IP");
                      if (_ipAddressController.text.isNotEmpty) {
                        setState(() {
                          _ipString = _ipAddressController.text;
                          _ipAddressController.text = '';
                        });
                        addIpToSF(_ipString);
                        ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
                            content: Text("Đã lưu địa chỉ IP mới")));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
                            content: Text("Vui lòng nhập địa chỉ IP")));
                      }
                    },
                    child: Text("CẬP NHẬT",
                        style: TextStyle(color: Colors.white, fontSize: 16))),
              ),
              Divider(),
            ],
          ),
        ));
  }

  void addIpToSF(String ip) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('ipAddress', ip);
  }

  Future<void> getIPValuesSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ipValue = prefs.getString('ipAddress');
    if (ipValue != null) {
      setState(() {
        _ipString = ipValue;
      });
    }
  }
}
