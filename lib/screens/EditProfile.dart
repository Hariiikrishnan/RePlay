import 'package:turf_arena/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Editprofile extends StatefulWidget {
  Editprofile(this.details);
  Map details;
  @override
  State<Editprofile> createState() => _EditprofileState();
}

class _EditprofileState extends State<Editprofile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      body: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(),
              // EditableText(

              // ),
            ],
          ),
        ),
      ),
    );
  }
}
