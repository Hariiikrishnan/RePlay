import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fui_kit/fui_kit.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:turf_arena/constants.dart';
import 'package:turf_arena/screens/EditProfile.dart';
import 'package:turf_arena/screens/LoginScreen.dart';
import 'package:turf_arena/screens/MomentScreen.dart';
import 'package:turf_arena/screens/MyBookings.dart';
import 'package:turf_arena/screens/OtpScreen.dart';
import 'package:turf_arena/screens/PaymentError.dart';
import 'package:turf_arena/screens/SetProfile.dart';
import 'package:turf_arena/screens/SuccessBook.dart';
import 'package:turf_arena/screens/VerifyPhone.dart';
import 'package:turf_arena/screens/booking_success.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Profilescreen extends StatefulWidget {
  Profilescreen(this.details, this.cameras, this.alt);
  Map details;
  List<CameraDescription> cameras;
  String alt;
  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

Route _createRoute(Widget ScreenName) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ScreenName,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

class _ProfilescreenState extends State<Profilescreen> {
  bool isLoading = true;
  Future<bool> signOutFromGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  String capitalize(String? text) {
    if (text == null || text.isEmpty) {
      return text!; // Return as is if the string is null or empty
    }
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  late SharedPreferences prefs;

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.details['moments']);
    print(widget.details['moments'].runtimeType);
    if (widget.details['moments'] is String) {
      print("Coming");
      // Decode the string into a List<dynamic>, even if it's empty
      widget.details['moments'] = widget.details['moments'].isEmpty
          ? [] // If it's an empty string, assign an empty list
          : json.decode(
              widget.details['moments']); // Otherwise, decode the string
    } else {
      print(widget.details['moments']);
    }
    print(widget.details['moments'].runtimeType);
    // print(widget.details['moments'][0]['time']);
    // print(widget.details['moments'][0]['url']);
    initSharedPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: primaryColor,
        ),
        child: Column(
          children: [
            Expanded(
                child: Container(
              decoration: BoxDecoration(
                color: primaryColor,
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 30.0,
                  left: 20.0,
                  right: 20.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image(
                          image: CachedNetworkImageProvider(
                            "https://firebasestorage.googleapis.com/v0/b/turf-arena.firebasestorage.app/o/assets%2Fapp_icon.png?alt=media&token=e90a7941-7676-4273-9dcf-b5f24b0482c5",
                          ),
                          height: 35.0,
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 74.0,
                      backgroundColor: whiteColor,
                      child: CircleAvatar(
                        radius: 70.0,
                        backgroundImage: CachedNetworkImageProvider(
                            widget.details['photoURL']),
                      ),
                    ),
                    Row(
                      spacing: 15.0,
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                                backgroundColor: whiteColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    8.0,
                                  ),
                                )),
                            onPressed: () {
                              Navigator.of(context).push(
                                _createRoute(
                                  // SetProfile(widget.details),
                                  Editprofile(widget.details),
                                ),
                              );
                            },
                            icon: FUI(
                              RegularRounded.EDIT_ALT,
                              height: 20.0,
                              color: primaryColor,
                            ),
                            iconAlignment: IconAlignment.end,
                            label: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Text(
                                "Edit Profile",
                                style: TextStyle(
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.red[400],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    8.0,
                                  ),
                                )),
                            onPressed: () {
                              prefs.remove('email');
                              prefs.remove('isAdmin');
                              prefs.remove('liked');
                              prefs.remove('moments');
                              prefs.remove('displayName');
                              prefs.remove('photoURL');
                              prefs.remove('uid');

                              signOutFromGoogle();

                              Navigator.of(context).push(
                                _createRoute(
                                  LoginScreen(
                                    cameras: widget.cameras,
                                    alt: widget.alt,
                                  ),
                                ),
                              );
                            },
                            icon: FUI(
                              RegularRounded.SIGN_OUT,
                              height: 20.0,
                              color: whiteColor,
                            ),
                            iconAlignment: IconAlignment.end,
                            label: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Text(
                                "Logout",
                                style: TextStyle(
                                  color: whiteColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50.0),
                      topRight: Radius.circular(50.0),
                    )),
                child: Column(
                  children: [
                    Container(
                      height: 50.0,
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(50.0),
                            topRight: Radius.circular(50.0),
                          )),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            // "hello",
                            "Howdy, " +
                                capitalize(widget.details['displayName'] ??
                                    widget.details['email'] ??
                                    ""),
                            style: TextStyle(
                              color: secondaryColor,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          // Text("Saved"),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        // height: 300.0,
                        height: 300.0,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 5.0,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    // border: Border.all(
                                    //   width: 1.5,
                                    //   color: primaryColor.withOpacity(0.2),
                                    // ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryColor.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 3,
                                        offset: Offset(
                                            0, 1), // changes position of shadow
                                      ),
                                    ],
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0XFFc1fcd3),
                                        Color(0XFF0ccda3),
                                        Color(0XFFc1fcd3),
                                      ],
                                      begin: Alignment.bottomLeft,
                                      end: Alignment.topRight,
                                      stops: [0.1, 0.5, 0.9],
                                      tileMode: TileMode.repeated,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 5.0,
                                      horizontal: 10.0,
                                    ),
                                    child: Text(
                                      "#RePlayMoments",
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: widget.details['moments'].length == 0
                                    ? NoBookings()
                                    : ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        padding: EdgeInsets.zero,
                                        itemCount:
                                            widget.details['moments'].length,
                                        itemBuilder: (context, index) {
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                _createRoute(
                                                  MomentScreen(
                                                      widget.details['moments']
                                                          [index],
                                                      widget.details),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                left: 8.0,
                                                right: 8.0,
                                                top: 15.0,
                                                bottom: 50.0,
                                              ),
                                              // height: 250.0,
                                              width: 160.0,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                                color: Colors.grey[100],
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: primaryColor
                                                        .withOpacity(0.3),
                                                    spreadRadius: 1,
                                                    blurRadius: 3,
                                                    offset: Offset(0,
                                                        1), // changes position of shadow
                                                  ),
                                                ],
                                              ),
                                              alignment: Alignment.center,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 17.0,
                                                  vertical: 17.0,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  spacing: 10.0,
                                                  children: [
                                                    Expanded(
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(0.0),
                                                        child: Image.network(
                                                          widget.details[
                                                                  'moments']
                                                              [index]['url'],
                                                          loadingBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  Widget child,
                                                                  ImageChunkEvent?
                                                                      loadingProgress) {
                                                            if (loadingProgress ==
                                                                null) {
                                                              return child; // Image is fully loaded
                                                            }
                                                            return Skeletonizer(
                                                              enabled: true,
                                                              enableSwitchAnimation:
                                                                  true,
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16.0),
                                                                child:
                                                                    Container(
                                                                  height: double
                                                                      .maxFinite,
                                                                  width: 160.0,
                                                                  color:
                                                                      greyColor,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          errorBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  Object error,
                                                                  StackTrace?
                                                                      stackTrace) {
                                                            return Icon(
                                                                Icons.error,
                                                                color:
                                                                    Colors.red,
                                                                size: 50);
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      "On " +
                                                          DateFormat('d - MMM ')
                                                              .format(
                                                            DateTime.parse(widget
                                                                        .details[
                                                                    'moments'][
                                                                index]['time']),
                                                          ),
                                                      style: TextStyle(
                                                        color: primaryColor,
                                                        fontSize: 15.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NoBookings extends StatelessWidget {
  const NoBookings({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_dissatisfied_rounded,
              color: Colors.grey[400],
              size: 120.0,
            ),
            //  FUI(
            //   RegularRounded.SAD,
            //   color: primaryColor,
            //   height: 150.0,
            //   width: 150.0,
            // ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              'No moments, no memories.',
              style: TextStyle(
                color: primaryColor,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
