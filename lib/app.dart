import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'state/savings_controller.dart';
import 'theme/app_theme.dart';

class AresApp extends StatelessWidget {
  const AresApp({required this.controller, super.key});

  final SavingsController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AresCare',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: HomeScreen(controller: controller),
    );
  }
}
