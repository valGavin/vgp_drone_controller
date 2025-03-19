import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'splash.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,])
      .then((_) { runApp(VGP()); });
}

class VGP extends StatelessWidget {
  const VGP({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'vGP Drone Controller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: const Color(0xFF05fc05),
        fontFamily: 'Roboto',
      ),
      home: const Splash(),
    );
  }
}
