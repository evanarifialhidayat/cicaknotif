import 'package:flutter/material.dart';
import 'screens/mqtt_home_page.dart';

void main() {
  runApp(const CpmintsApp());
}

class CpmintsApp extends StatelessWidget {
  const CpmintsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CPMints MQTT',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1769FF),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
      ),
      home: const MqttHomePage(),
    );
  }
}