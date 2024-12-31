import 'dart:ui';

import 'package:turf_arena/screens/LoginScreen.dart';
import 'package:turf_arena/screens/app.dart';
import 'package:flutter/material.dart';
import 'package:turf_arena/constants.dart';

import 'package:camera/camera.dart';

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key, required this.cameras, required this.alt});
  final List<CameraDescription> cameras;
  final String alt;

  Route _createRoute(Widget ScreenName) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => ScreenName,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(""),
      // ),

      body: Stack(
        children: [
          Container(
            height: double.infinity,
            // child: Image.asset("images/grass_bg.jpg"),
            decoration: BoxDecoration(
              // color: Colors.red,
              image: DecorationImage(
                // alignment: Alignment.center,
                fit: BoxFit.cover,
                // scale: 2,
                image: AssetImage("images/grass_bg.jpg"),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      // gradient: LinearGradient(
                      //   colors: [
                      //     Colors.black.withOpacity(0.4), // Bottom color
                      //     Colors.transparent.withOpacity(0.0), // Top fade-out
                      //   ],
                      //   begin: Alignment.bottomCenter,
                      //   end: Alignment.topCenter,
                      //   stops: [0.2, 1.0],
                      // ),
                      borderRadius: BorderRadius.circular(30.0),
                      border: Border.all(width: 2.0, color: Colors.grey[400]!),
                    ),
                    // height: double.infinity,
                    width: double.infinity,
                    height: 300.0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 12.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Welcome Chief',
                            softWrap: true,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            'Re-Play lets you easily book turfs and share your game moments. Play, book, and enjoy - all in one app!',
                            softWrap: true,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor: whiteColor,
                                elevation: 15.2,
                                overlayColor: greyColor,
                                fixedSize: Size(
                                  135.0,
                                  40.0,
                                )),
                            onPressed: () {
                              Navigator.of(context).push(
                                _createRoute(
                                  LoginScreen(cameras: cameras, alt: alt),
                                ),
                              );
                            },
                            child: Text(
                              "Get Started",
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 16.0,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TopSCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    // Start from top-left corner
    path.moveTo(0, 0);

    // First curve (S curve part)
    var firstControlPoint = Offset(size.width / 4, size.height / 6); //6
    var firstEndPoint = Offset(size.width / 2, size.height / 8); //8

    var secondControlPoint = Offset(size.width * 3 / 4, size.height / 12); //12
    var secondEndPoint = Offset(size.width, size.height / 6); //6

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    // Continue along the sides and bottom
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    int curveHeight = 40;
    Offset controlPoint = Offset(size.width / 2, size.height + curveHeight);
    Offset endPoint = Offset(size.width, size.height - curveHeight);

    Path path = Path()
      ..lineTo(0, size.height - curveHeight)
      ..quadraticBezierTo(
          controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy)
      ..lineTo(size.width, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class SCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(10, size.height * 10.2);

    // First curve
    var firstControlPoint1 = Offset(size.width * 5.25, size.height * 10.05);
    var firstControlPoint2 = Offset(size.width * 8.75, size.height * 8.35);
    var firstEndPoint = Offset(size.width, size.height * 5.2);
    path.cubicTo(
      firstControlPoint1.dx,
      firstControlPoint1.dy,
      firstControlPoint2.dx,
      firstControlPoint2.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    // Second curve
    var secondControlPoint1 = Offset(size.width * 0.25, size.height * 8.65);
    var secondControlPoint2 = Offset(size.width * 5.25, size.height * 10.95);
    var secondEndPoint = Offset(0, size.height * 5.8);
    path.cubicTo(
      secondControlPoint1.dx,
      secondControlPoint1.dy,
      secondControlPoint2.dx,
      secondControlPoint2.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 2);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
