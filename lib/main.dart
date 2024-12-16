import 'package:turf_arena/constants.dart';
import 'package:turf_arena/screens/SuccessBook.dart';
import 'package:flutter/material.dart';
import 'package:turf_arena/screens/HomeScreen.dart';
import 'package:turf_arena/screens/InitialScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:camera/camera.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  await Firebase.initializeApp(
    name: "Turf Arena",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp(cameras: cameras));
}

// void main() {
//   runApp(const MyApp());
// }

class MyApp extends StatelessWidget {
  MyApp({super.key, required this.cameras});
  final List<CameraDescription> cameras;

  // This widget is the root of application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Turf Arena',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: greenColor),
        useMaterial3: true,
      ),
      home: InitialScreen(cameras: cameras),
    );
  }
}
