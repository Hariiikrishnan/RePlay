import 'dart:math';

import 'package:turf_arena/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BookingSuccess extends StatelessWidget {
  const BookingSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: whiteColor,
                    radius: 100.0,
                    child: ClipPath(
                      clipper: ThornyBadgeClipper(),
                      child: Container(
                        width: 180,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.green,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.check_rounded,
                            size: 120.0,
                            color: whiteColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  Text(
                    "Successfully Booked!",
                    style: TextStyle(
                      color: whiteColor,
                      fontSize: 25.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: whiteColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                    10.0,
                  ))),
              child: Text(
                "Back",
                style: TextStyle(
                  color: secondaryColor,
                  fontSize: 18.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThornyBadgeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    final double radius = size.width / 3;
    final int thornCount = 15; // Number of thorns
    final double thornLength = 10.0; // Length of each thorn
    final double angleIncrement = 2 * 3.141592653589793 / thornCount;

    path.moveTo(size.width / 2 + radius, size.height / 2);

    for (int i = 0; i <= thornCount; i++) {
      double angle = i * angleIncrement;
      double thornAngle = angle + angleIncrement / 2;

      // Outer thorn point
      double thornX = size.width / 2 + (radius + thornLength) * cos(thornAngle);
      double thornY =
          size.height / 2 + (radius + thornLength) * sin(thornAngle);

      // Circle point
      double circleX = size.width / 2 + radius * cos(angle);
      double circleY = size.height / 2 + radius * sin(angle);

      path.lineTo(circleX, circleY);
      path.lineTo(thornX, thornY);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
