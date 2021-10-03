import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigurationDialog extends StatefulWidget {
  @override
  State<ConfigurationDialog> createState() => _ConfigurationDialogState();
}

class _ConfigurationDialogState extends State<ConfigurationDialog> {
  TextEditingController _ipAddressController = new TextEditingController();
  String _ipString;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getIPValuesSF();
  }

  Future<void> getIPValuesSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ipValue = prefs.getString('ipAddress');
    if (ipValue != null) {
      setState(() {
        _ipString = ipValue;
        _ipAddressController.text = _ipString;
      });
    }
  }

  void addIpToSF(String ip) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('ipAddress', ip);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AlertDialog(
        title: Text(
          'Configuration',
          textAlign: TextAlign.center,
        ),
        titlePadding: const EdgeInsets.only(top: 20),
        contentPadding: const EdgeInsets.only(top: 10, bottom: 0),
        actionsPadding: const EdgeInsets.only(bottom: 0, top: 0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Text(
                'IP Address',
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 15),
              width: 160,
              child: TextField(
                autofocus: true,
                keyboardType: TextInputType.number,
                controller: _ipAddressController,
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(0),
                    hintText: '192.168.1.56',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25))),
              ),
            ),
            Divider(),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop('Close');
              },
              child: Text(
                'Close',
                style: TextStyle(fontSize: 20),
              )),
          TextButton(
              onPressed: () {
                if (_ipAddressController.text.isNotEmpty) {
                  setState(() {
                    _ipString = _ipAddressController.text;
                    _ipAddressController.text = _ipString;
                  });
                  addIpToSF(_ipString);
                  setState(() {});
                  Navigator.of(context).pop('Success');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      new SnackBar(content: Text("Vui lòng nhập địa chỉ IP")));
                }
              },
              child: Text('Done', style: TextStyle(fontSize: 20))),
        ],
        actionsAlignment: MainAxisAlignment.spaceAround,
      ),
    );
  }
}
