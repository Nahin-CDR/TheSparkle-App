import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sparkle/screen3.dart';
import 'package:sparkle/themeController.dart';


class Screen2 extends StatelessWidget {
  final ThemeController themeController = Get.find();

   Screen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Screen 2')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                themeController.toggleTheme();
              },
              child: Text('Toggle Theme'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.to(Screen3());
              },
              child: Text('Go to Screen 3'),
            ),
          ],
        ),
      ),
    );
  }
}
