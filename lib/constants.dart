import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const Color secondaryColor = Color(0xFF1E293B);
const Color whiteColor = Color(0XFFFFFFFF);

const Color primaryColor = Color(0xFF05141A);
const Color greyColor = Color(0XFFb3b5b5);
const Color greenColor = Color(0XFF20B08E);
// const Color greenColor = Color(0XFF1fc07d);

Color color1 = Color(0xFFFFCB79);
Color color2 = Color(0xFFFFCB79);

const Color newGrey = Color.fromRGBO(245, 245, 245, 1);

const kTextFieldDecoration = InputDecoration(
  hintText: 'Turf Name',
  hintStyle: TextStyle(
    color: whiteColor,
  ),
  suffixIcon: Icon(
    Icons.search,
    fill: 1.0,
  ),

  suffixIconColor: whiteColor,
  // suffixIcon: CircleAvatar(
  //   backgroundColor: whiteColor,
  //   child: Icon(Icons.menu),
  // ),
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(30.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: greyColor, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(30.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: whiteColor, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(30.0)),
  ),
  fillColor: Colors.black26,
  focusColor: whiteColor,

  filled: true,
);
const kLoginFieldDecoration = InputDecoration(
  hintText: '',
  hintStyle: TextStyle(
    color: Color.fromRGBO(117, 117, 117, 1),
  ),
  contentPadding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(16.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: greyColor, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(16.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color.fromARGB(93, 5, 20, 26), width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(16.0)),
  ),
  fillColor: newGrey,
  filled: true,
);

const kOtpDecoration = InputDecoration(
  hintStyle: TextStyle(
    color: primaryColor,
  ),

  // hintText: "0",
  // prefixIcon: Icon(Icons.search),
  // prefixIconColor: greyColor,
  // suffixIcon: CircleAvatar(
  //   backgroundColor: whiteColor,
  //   child: Icon(Icons.menu),
  // ),
  // contentPadding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 5.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(2.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: primaryColor, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(5.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: primaryColor, width: 4.0),
    borderRadius: BorderRadius.all(Radius.circular(5.0)),
  ),
  fillColor: greyColor,
  filled: true,
);
