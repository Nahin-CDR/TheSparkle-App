import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sparkle/sound/home.dart';
import 'package:sparkle/themeController.dart';
import 'screen1.dart';

void main() {
  runApp(const KaraokeApp());
}

class MyApp extends StatelessWidget {
  final ThemeController themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GetMaterialApp(
        title: 'Flutter GetX Theme Demo',
        themeMode: themeController.theme,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        home: Screen1(),
      );
    });
  }
}
