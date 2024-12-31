import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fui_kit/fui_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turf_arena/constants.dart';
import 'package:turf_arena/screens/AdminBookings.dart';
import 'package:turf_arena/screens/BookingSearch.dart';
import 'package:turf_arena/screens/LoginScreen.dart';
import 'package:turf_arena/screens/components/ProfileHeader.dart';

class Admindashboard extends StatefulWidget {
  Admindashboard(this.userDetails, this.cameras, this.alt);
  Map userDetails;
  List<CameraDescription> cameras;
  String alt;

  @override
  State<Admindashboard> createState() => _AdmindashboardState();
}

class _AdmindashboardState extends State<Admindashboard> {
  late String? bookingId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // print(widget.details['moments'][0]['time']);
    // print(widget.details['moments'][0]['url']);
    initSharedPref();
  }

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

  void showBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        padding:
        MediaQuery.of(context).viewInsets;
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AnimatedPadding(
            duration: Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50.0),
                  topRight: Radius.circular(50.0),
                ),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 30.0,
                  horizontal: 30.0,
                ),
                child: Column(
                  spacing: 15.0,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Search Booking",
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 22.0,
                          ),
                        ),
                      ],
                    ),
                    TextField(
                      decoration: kLoginFieldDecoration.copyWith(
                        hintText: "Enter Booking ID",
                        hintStyle: TextStyle(
                          color: primaryColor.withOpacity(0.6),
                        ),
                        fillColor: Colors.grey[200],
                        suffixIconColor: primaryColor,
                      ),
                      onChanged: (value) {
                        setState(() {
                          bookingId = value;
                        });
                      },
                    ),
                    TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              12.0,
                            ),
                          ),
                        ),
                        onPressed: () {
                          if (bookingId != null) {
                            Navigator.of(context).push(
                              _createRoute(
                                BookingSearch(widget.userDetails, bookingId!),
                              ),
                            );
                          } else {
                            print("Null value");
                          }
                        },
                        child: Text(
                          "Search",
                          style: TextStyle(
                            color: whiteColor,
                            fontSize: 18.0,
                          ),
                        ))
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  late SharedPreferences prefs;

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<bool> signOutFromGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 30.0,
          ),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 15.0,
            children: [
              ProfileHeader(widget.userDetails, primaryColor),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Dashboard",
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 22.0,
                    ),
                  ),
                  IconButton(
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
                      BoldRounded.SIGN_OUT,
                      height: 20.0,
                      color: Colors.red,
                    ),
                  )
                ],
              ),
              Row(
                spacing: 10.0,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        print("Tapping");
                        Navigator.of(context).push(
                          _createRoute(
                            AdminBookings(widget.userDetails),
                          ),
                        );
                      },
                      child: Container(
                        height: 150.0,
                        // width: 200.0,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.confirmation_number_outlined,
                              color: whiteColor,
                              size: 60.0,
                            ),
                            Text(
                              "All Bookings",
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 18.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        print("Tapping");
                        showBottomSheet();
                      },
                      child: Container(
                        height: 150.0,
                        // width: 200.0,
                        decoration: BoxDecoration(
                          color: Colors.pinkAccent,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              color: whiteColor,
                              size: 60.0,
                            ),
                            Text(
                              "Search Booking",
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 18.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
