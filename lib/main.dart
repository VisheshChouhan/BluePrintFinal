import 'package:blue_print/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:blue_print/pages/splash_screen.dart';
import 'package:permission_handler/permission_handler.dart';

import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  await _getPermission();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,

  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home:  SplashScreen(),
      // home: LoginPage(),
    );
  }
}

Future<void> _getPermission() async {
  if (defaultTargetPlatform == TargetPlatform.android) {
    // await Permission.locationWhenInUse.request();
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
//iOS specific code
  } else {
//web or desktop specific code
  }
}


