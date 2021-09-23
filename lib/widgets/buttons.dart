import 'package:flutter/material.dart';

class Buttons extends StatefulWidget {
  @override
  State<Buttons> createState() => _ButtonsState();
}

class _ButtonsState extends State<Buttons> {
  bool _isTempPressed = false;
   bool _isLightPressed = false;
   bool _isBuzzerPressed = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
       
        Column(
          children: [
            Container(
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _isTempPressed = !_isTempPressed;
                  });
                },
                icon: Icon(
                  Icons.ac_unit,
                  color: _isTempPressed ? Colors.white : Colors.black,
                ),
              ),
              height: 60,
              width: 60,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                  color: _isTempPressed ? Colors.green : Colors.white,
                  borderRadius: BorderRadius.circular(30)),
            ),
            Text('Temp'),
          ],
        ),
        Column(
          children: [
            Container(
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _isLightPressed = !_isLightPressed;
                  });
                },
                icon: Icon(
                  Icons.light,
                  color: _isLightPressed ? Colors.white : Colors.black,
                ),
              ),
              height: 60,
              width: 60,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                  color: _isLightPressed ? Colors.green : Colors.white,
                  borderRadius: BorderRadius.circular(30)),
            ),
            Text('Light'),
          ],
        ),
       Column(
          children: [
            Container(
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _isBuzzerPressed = !_isBuzzerPressed;
                  });
                },
                icon: Icon(
                  Icons.notifications_outlined,
                  color: _isBuzzerPressed ? Colors.white : Colors.black,
                ),
              ),
              height: 60,
              width: 60,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                  color: _isBuzzerPressed ? Colors.purple : Colors.white,
                  borderRadius: BorderRadius.circular(30)),
            ),
            Text('Buzzer'),
          ],
        ),
       
            
      ],
    );
  }
  
}
