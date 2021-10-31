import 'package:flutter/material.dart';

class BoxIp extends StatelessWidget {
  String ip;
  BoxIp({this.ip});
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: 130,
      decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey)),
      height: 30,
      child:
          Text(ip),
      
      
    );
  }
}
