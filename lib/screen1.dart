import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screen2.dart';

class Screen1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Screen 1')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Get.to(Screen2());
          },
          child: Text('Go to Screen 2'),
        ),
      ),
    );
  }
}
