import 'dart:convert';
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:turf_arena/constants.dart';
import 'package:turf_arena/screens/AdminDashBoard.dart';
import 'package:turf_arena/screens/RegisterScreen.dart';
import 'package:turf_arena/screens/app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:camera/camera.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.cameras, required this.alt});
  final List<CameraDescription> cameras;
  final String alt;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  bool loadGoogleSign = false;
  bool isLoaded = false;
  String? username;
  String? password;
  late Map userDetails;

  late SharedPreferences prefs;

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  SnackBar snackBar(String msg) {
    return SnackBar(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
        30.0,
      )),
      margin: EdgeInsets.symmetric(
        horizontal: 5.0,
        vertical: 5.0,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 30.0,
        vertical: 5.0,
      ),
      elevation: 50.0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.red[400],
      content: Text(
        msg,
        style: TextStyle(
          fontSize: 15.0,
        ),
      ),
      showCloseIcon: true,
      closeIconColor: whiteColor,
    );
  }

  List<String> scopes = <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ];

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Optional clientId
    // clientId: 'your-client_id.apps.googleusercontent.com',
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  Future<dynamic> signInWithGoogle() async {
    try {
      setState(() {
        loadGoogleSign = true;
      });
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Get the Firebase User object from the UserCredential
      final User? user = userCredential.user;

      if (user != null) {
        // Access and print the user's display name (username) and email
        // print('Username: ${user.displayName}');
        // print('Email: ${user.email}');
        setState(() {
          loadGoogleSign = false;
          isLoaded = true;
        });
        await fetchUser(user);
        print(user.displayName);
        String strJsonString = "";
        if (userDetails['moments'].length != 0) {
          strJsonString = json.encode(userDetails['moments']);
        }
        print(strJsonString);
        prefs.setString('email', userDetails['email']);
        prefs.setBool('isAdmin', userDetails['isAdmin']);
        prefs.setStringList(
            'liked', List<String>.from(userDetails['liked'] as List));
        prefs.setString('moments', strJsonString);
        prefs.setString('displayName', userDetails['displayName']);
        prefs.setString('photoURL', userDetails['photoURL']);
        prefs.setString('uid', userDetails['uid']);

        print("Stored");

        print(prefs.getString('email'));
        if (userDetails['isAdmin']) {
          Navigator.of(context).push(
            _createRoute(
              Admindashboard(userDetails, widget.cameras, widget.alt),
            ),
          );
        } else {
          Navigator.of(context).pushReplacement(
            _createRoute(
              App(userDetails, widget.cameras, widget.alt),
            ),
          );

          print("Navigated");
        }
      } else {
        setState(() {
          loadGoogleSign = false;
          isLoaded = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(snackBar("Try Register and then Sign In."));
      }

      return user;
    } catch (e) {
      // TODO
      // print(e.code);
      setState(() {
        loadGoogleSign = false;
        isLoaded = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(snackBar("Error Occured. Try Again!"));
      print(e);
    }
  }

  Future<void> fetchUser(User user) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    Query query = users.where('uid', isEqualTo: user.uid);

    try {
      QuerySnapshot snapshot = await query.get();

      // setState(() {
      // loadingData = false;
      // _isLoading = false;
      // print(snapshot.docs);
      if (snapshot.docs.isEmpty) {
        setState(() {
          isLoaded = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(snackBar("Please Try Again!"));
      } else {
        snapshot.docs.forEach((doc) {
          // print(doc.data());
          setState(() {
            userDetails = doc.data() as Map<String, dynamic>;
          });
          // turfList.add(doc.data() as Map<String, dynamic>);
        });
        // });
      }
    } catch (error) {
      print("Error getting documents: $error");
      setState(() {
        loadGoogleSign = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoaded = false;
    loadGoogleSign = false;
    showSpinner = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(""),
      // ),
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            alignment: Alignment.topCenter,
            fit: BoxFit.cover,
            image: AssetImage("images/login_bg.png"),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                // height: 150.0,

                decoration: BoxDecoration(),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: SizedBox(),
                      ),
                      Container(
                        width: 150.0,
                        decoration: BoxDecoration(
                          color: greenColor,
                          borderRadius: BorderRadius.circular(
                            8.0,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Re Play",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 23.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      Text(
                        "Experience the Turf Again.",
                        style: TextStyle(
                          color: primaryColor.withOpacity(0.4),
                          fontSize: 20.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: SizedBox(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0),
                        bottomLeft: Radius.circular(30.0),
                        bottomRight: Radius.circular(30.0),
                      ),
                      color: primaryColor.withOpacity(
                        0.25,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Sign in",
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                onChanged: (value) {
                                  username = value;
                                },
                                textInputAction: TextInputAction.search,
                                decoration: kLoginFieldDecoration.copyWith(
                                  hintText: 'Email',
                                ),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              TextField(
                                obscureText: true,
                                onChanged: (value) {
                                  password = value;
                                },
                                // textInputAction: TextInputAction.search,
                                decoration: kLoginFieldDecoration.copyWith(
                                  hintText: 'Password',
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              TextButton(
                                onPressed: () async {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  if (username == null || password == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                          30.0,
                                        )),
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 5.0,
                                          vertical: 5.0,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 30.0,
                                          vertical: 5.0,
                                        ),
                                        elevation: 50.0,
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Colors.red[400],
                                        showCloseIcon: true,
                                        closeIconColor: whiteColor,
                                        content: Text(
                                          "Enter all Fields!",
                                          style: TextStyle(
                                            fontSize: 17.0,
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    setState(() {
                                      showSpinner = true;
                                    });

                                    try {
                                      final loggedInUser = await _auth
                                          .signInWithEmailAndPassword(
                                              email: username!,
                                              password: password!);

                                      if (loggedInUser != null) {
                                        print("Logged");
                                        await fetchUser(loggedInUser.user!);

                                        String strJsonString = "";
                                        if (userDetails['moments'].length !=
                                            0) {
                                          strJsonString = json
                                              .encode(userDetails['moments']);
                                        }
                                        print(strJsonString);
                                        prefs.setString(
                                            'email', userDetails['email']);
                                        prefs.setBool(
                                            'isAdmin', userDetails['isAdmin']);
                                        prefs.setStringList(
                                            'liked',
                                            List<String>.from(
                                                userDetails['liked'] as List));
                                        prefs.setString(
                                            'moments', strJsonString);
                                        prefs.setString('phone',
                                            userDetails['phone'] ?? "");
                                        prefs.setString('photoURL',
                                            userDetails['photoURL']);
                                        prefs.setString(
                                            'uid', userDetails['uid']);
                                        print("Stored");
                                        setState(() {
                                          showSpinner = false;
                                        });
                                        if (userDetails['isAdmin']) {
                                          Navigator.of(context).push(
                                            _createRoute(
                                              Admindashboard(userDetails,
                                                  widget.cameras, widget.alt),
                                            ),
                                          );
                                        } else {
                                          Navigator.of(context).pushReplacement(
                                            _createRoute(
                                              App(userDetails, widget.cameras,
                                                  widget.alt),
                                            ),
                                          );
                                        }
                                      } else {
                                        print("No user Found");
                                      }
                                    } on FirebaseAuthException catch (e) {
                                      setState(() {
                                        loadGoogleSign = false;
                                      });
                                      switch (e.code) {
                                        case 'invalid-email':
                                          // print("The email address is invalid.");
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            snackBar(
                                                "Email Address is Invalid."),
                                          );
                                          break;
                                        case 'user-disabled':
                                          // print(
                                          // "The user account has been disabled.");
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            snackBar(
                                                "User Account has been Disabled."),
                                          );
                                          break;
                                        case 'user-not-found':
                                          // print("No user found with this email.");
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            snackBar(
                                                "No User Found with this Email."),
                                          );
                                          break;
                                        case 'wrong-password':
                                          // print("Incorrect password.");
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            snackBar(
                                                "Incorrect Password. Try Again!"),
                                          );
                                          break;
                                        case 'too-many-requests':
                                          // print(
                                          // "Too many login attempts. Please try again later.");
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            snackBar(
                                                "Too Many Attemps. Try Later!"),
                                          );
                                          break;
                                        case 'network-request-failed':
                                          // print(
                                          // "Network error occurred. Check your connection.");
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            snackBar(
                                                "Network error occurred. Check your connection."),
                                          );
                                          break;
                                        case 'operation-not-allowed':
                                          print(
                                              "Email/password sign-in is not enabled.");
                                          break;
                                        default:
                                          // print(
                                          // "Unhandled FirebaseAuthException: ${e.code}");
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            snackBar("Please Try Again!"),
                                          );
                                          break;
                                      }
                                    } catch (e) {
                                      // print(e);
                                      print(e.toString());
                                      setState(() {
                                        showSpinner = false;
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        snackBar("Please Try Again!"),
                                      );
                                    }
                                  }
                                },
                                style: TextButton.styleFrom(
                                    fixedSize: Size(100.0, 50.0),
                                    // padding:
                                    // EdgeInsets.symmetric(vertical: 10.0),

                                    backgroundColor: showSpinner
                                        ? greenColor.withOpacity(0.8)
                                        : greenColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    )
                                    // fixedSize: Size(double.infinity, 50.0),
                                    ),
                                child: showSpinner
                                    ? Transform.scale(
                                        scale: 0.7,
                                        child: CircularProgressIndicator(
                                          // value: 0.5,
                                          color: whiteColor.withOpacity(0.7),
                                        ),
                                      )
                                    : Text(
                                        "Sign in",
                                        style: TextStyle(
                                          color: whiteColor,
                                          fontSize: 17.0,
                                        ),
                                      ),
                              ),
                              SizedBox(
                                height: 30.0,
                              ),
                              Center(
                                child: Text(
                                  "Or Continue With",
                                  style: TextStyle(
                                    color: Colors.grey[200],
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              TextButton(
                                onPressed: () async {
                                  try {
                                    await signInWithGoogle();
                                  } catch (e) {
                                    print(e);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      snackBar("Please Try Again!"),
                                    );
                                  }
                                },
                                style: TextButton.styleFrom(
                                    fixedSize: Size(100.0, 50.0),
                                    // padding:
                                    // EdgeInsets.symmetric(vertical: 10.0),

                                    backgroundColor: loadGoogleSign
                                        ? whiteColor.withOpacity(0.8)
                                        : whiteColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    )
                                    // fixedSize: Size(double.infinity, 50.0),
                                    ),
                                child: loadGoogleSign
                                    ? Transform.scale(
                                        scale: 0.7,
                                        child: CircularProgressIndicator(
                                          color: greyColor,
                                        ),
                                      )
                                    : isLoaded
                                        ? Text(
                                            "Logging In..",
                                            style: TextStyle(
                                              color: primaryColor,
                                              fontSize: 17.0,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                "images/google.png",
                                                height: 18.0,
                                              ),
                                              SizedBox(
                                                width: 10.0,
                                              ),
                                              Text(
                                                "Google",
                                                style: TextStyle(
                                                  color: primaryColor,
                                                  fontSize: 17.0,
                                                ),
                                              ),
                                            ],
                                          ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                    _createRoute(
                                      Registerscreen(
                                        cameras: widget.cameras,
                                        alt: widget.alt,
                                      ),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 15.0),
                                    // backgroundColor: secondaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    )
                                    // fixedSize: Size(double.infinity, 50.0),
                                    ),
                                child: Text(
                                  "Don't have an Account?",
                                  style: TextStyle(
                                    color: whiteColor,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Define the TriangleClipper for the top triangle
class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    double triangleHeight = size.height * 0.2; // Height of the triangle
    double radius = 15.0; // Radius to round the tip of the triangle

    // Start at top-left corner
    path.moveTo(0, triangleHeight);

    // Draw line towards the top-center but add a smooth curve using quadraticBezierTo
    path.quadraticBezierTo(
      size.width / 2, radius, // Control point (smooth curve towards the tip)
      size.width / 2, radius, // Tip of the triangle
    );
// path.arcToPoint(
    // Offset(size.width / 2 + curveRadius, triangleHeight),
    // radius: Radius.circular(curveRadius),
    // clockwise: false, // This ensures the arc is convex (rounded outward)
    // );
    // Draw line to the top-right corner with a curve
    path.quadraticBezierTo(
      size.width / 2,
      radius, // Control point for the smooth curve on the right side
      size.width, triangleHeight, // Top-right corner
    );

    // Draw the rest of the rectangle
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    // Close the path
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
