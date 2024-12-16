import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:turf_arena/constants.dart';

class PaymentError extends StatelessWidget {
  const PaymentError({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      body: Container(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.red[400],
                      radius: 80.0,
                      child: Icon(
                        Icons.close_rounded,
                        size: 100.0,
                        color: whiteColor,
                      ),
                    ),
                    SizedBox(
                      height: 25.0,
                    ),
                    Text(
                      "Booking Failed!",
                      style: TextStyle(
                        color: whiteColor,
                        fontSize: 22.0,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "Please Try Again.",
                      style: TextStyle(
                        color: whiteColor,
                        fontSize: 22.0,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
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
      ),
    );
  }
}
