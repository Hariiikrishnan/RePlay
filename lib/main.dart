import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turf_arena/constants.dart';
import 'package:turf_arena/screens/AdminDashBoard.dart';
import 'package:turf_arena/screens/SuccessBook.dart';
import 'package:flutter/material.dart';
import 'package:turf_arena/screens/HomeScreen.dart';
import 'package:turf_arena/screens/InitialScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:turf_arena/screens/app.dart';
import 'firebase_options.dart';
import 'package:camera/camera.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  print("Splashing");

  await Firebase.initializeApp(
    name: "Turf Arena",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SharedPreferences prefs = await SharedPreferences.getInstance();
  print(prefs.getString('email'));

  // await FirebaseAppCheck.instance.activate(
  //   androidProvider: AndroidProvider.debug,
  //   // appleProvider: AppleProvider,
  // );
  String alt = await getLocation();
  FlutterNativeSplash.remove();
  runApp(MyApp(cameras: cameras, alt: alt, userDetails: {
    'email': prefs.getString('email'),
    'uid': prefs.getString('uid'),
    'photoURL': prefs.getString('photoURL'),
    'liked': prefs.getStringList('liked'),
    'isAdmin': prefs.getBool('isAdmin'),
    'moments': prefs.getString('moments'),
    'displayName': prefs.getString('displayName'),
  }));
}

Future<String> getLocation() async {
  late double latitude;
  late double longitude;
  try {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    print(permission);

    Position position = await Geolocator.getCurrentPosition(
        // forceAndroidLocationManager: Platform.isAndroid,
        desiredAccuracy: LocationAccuracy.best);

    latitude = position.latitude;
    longitude = position.longitude;

    // getNearby();
  } catch (e) {
    print(e);
  }
  return latitude.toString() + ',' + longitude.toString();
}

// void main() {
//   runApp(const MyApp());
// }

class MyApp extends StatelessWidget {
  MyApp(
      {super.key,
      required this.cameras,
      required this.alt,
      required this.userDetails});
  final List<CameraDescription> cameras;
  String alt;
  Map userDetails;

  // This widget is the root of application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Turf Arena',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: greenColor),
        useMaterial3: true,
        fontFamily: "Astonpoliz",
      ),
      home: userDetails['uid'] != null
          ? userDetails['isAdmin']
              ? Admindashboard(userDetails, cameras, alt)
              : App(userDetails, cameras, alt)
          : InitialScreen(cameras: cameras, alt: alt),
    );
  }
}
