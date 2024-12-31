import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:turf_arena/constants.dart';
import 'package:turf_arena/screens/LoginScreen.dart';
import 'package:turf_arena/screens/OtpScreen.dart';
import 'package:turf_arena/screens/SetProfile.dart';
import 'package:turf_arena/screens/VerifyPhone.dart';
import 'package:turf_arena/screens/app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Registerscreen extends StatefulWidget {
  const Registerscreen({super.key, required this.cameras, required this.alt});
  final List<CameraDescription> cameras;
  final String alt;
  @override
  State<Registerscreen> createState() => _RegisterscreenState();
}

class _RegisterscreenState extends State<Registerscreen> {
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  bool isError = false;
  bool loadGoogleSign = false;
  bool isLoaded = false;
  String? email;
  String? phoneNumber;
  String? password;
  String? displayName;

  late Map<String, dynamic> userData;

  List<String> scopes = <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ];

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

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Optional clientId
    // clientId: 'your-client_id.apps.googleusercontent.com',
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
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
      showCloseIcon: true,
      closeIconColor: whiteColor,
      content: Text(
        msg,
        style: TextStyle(
          fontSize: 17.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  var acs = ActionCodeSettings(
      // URL you want to redirect back to. The domain (www.example.com) for this
      // URL must be whitelisted in the Firebase Console.
      // dynamicLinkDomain: "example.com.link",
      url: 'https://www.example.com/finishSignUp?cartId=1234',
      // This must be true
      handleCodeInApp: true,
      iOSBundleId: 'com.example.ios',
      androidPackageName: 'com.example.turf_arena',
      // installIfNotAvailable
      androidInstallApp: true,
      // minimumVersion
      androidMinimumVersion: '12');

  Future<User?> registerWithEmail() async {
    try {
      // _auth.sendSignInLinkToEmail(email: email, actionCodeSettings: acs);

      if (email == null || password == null || phoneNumber == null) {}
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email!,
        password: password!,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Error in Email/Password Registration: $e');
      print(e.code);
      setState(() {
        showSpinner = false;
      });
      if (e.code == "email-already-in-use") {
        ScaffoldMessenger.of(context)
            .showSnackBar(snackBar("Email Already Used. Try Login!"));
      } else if (e.code == "weak-password") {
        ScaffoldMessenger.of(context)
            .showSnackBar(snackBar("Password Must Contain 8 Characters."));
      } else if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context)
            .showSnackBar(snackBar("Email Address is Invalid."));
        print('Error: The email address is invalid.');
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(snackBar("Error Occured. Try Again!"));
        print('Unhandled Error: ${e.message}');
      }
      return null;
    }
  }

  Future<void> addUserToFirestore(User user) async {
    try {
      // print(user.uid);
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      // print(userDoc.exists);
      if (!userDoc.exists) {
        if (user.displayName != null) {
          setState(() {
            userData = {
              'uid': user.uid,
              'email': user.email,
              'displayName': user.displayName,
              'photoURL': user.photoURL,
              'isAdmin': false,
              'liked': [],
              'moments': [],
            };
          });
        } else {
          setState(() {
            userData = {
              'uid': user.uid,
              'email': user.email,
              'isAdmin': false,
              'liked': [],
              'moments': [],
            };
          });
        }
        // print(userData);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(userData);
      } else {
        // print(userDoc.data());
        setState(() {
          userData = userDoc.data() as Map<String, dynamic>;
        });

        print("User Already Exixts");
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(snackBar("Error Occured. Try Again!"));
      print('Error adding user to Firestore: $e');
    }
  }

  void registerAndAddToFirestore() async {
    // if (_formKey.currentState!.validate()) {
    // String email = _emailController.text.trim();
    // String password = _passwordController.text.trim();
    if (email == null || password == null || phoneNumber == null) {
      setState(() {
        showSpinner = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(snackBar("Enter All Fields!"));
    } else {
      User? user = await registerWithEmail();
      if (user != null) {
        await addUserToFirestore(user);
        print('User registered and added to Firestore');
        _sendOtp();
      }
    }
  }

  // void signInAndCreateUser(String email, String password) async {
  //   User? user = await signInWithEmail(email, password);
  //   if (user != null) {
  //     await addUserToFirestore(user);
  //   }
  // }

  Future<void> addGoogleUserToFirestore(User user) async {
    try {
      // Check if user already exists in Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        // If the user doesn't exist, add them to Firestore
        setState(() {
          userData = {
            'uid': user.uid,
            'email': user.email,
            'displayName': user.displayName,
            'moments': [],
            'photoURL': user.photoURL,
          };
        });
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(userData);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(snackBar("Error Occured. Try Again!"));
      print('Error adding Google user: $e');
    }
  }

  Future signInWithGoogleAndAddToFirestore() async {
    User? user = await signInWithGoogle();
    if (user != null) {
      await addUserToFirestore(user);
      // print(user);
      // // print(userData);
      print('User signed in with Google and added to Firestore');

      Navigator.of(context).pushReplacement(_createRoute(
        App(userData, widget.cameras, widget.alt),
      ));
      return userData;
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(snackBar("Error Occured. Try Again!"));
    }
  }

  // Future<dynamic> signInWithGoogle() async {
  //   try {
  //     setState(() {
  //       loadGoogleSign = true;
  //     });
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  //     final GoogleSignInAuthentication? googleAuth =
  //         await googleUser?.authentication;

  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth?.accessToken,
  //       idToken: googleAuth?.idToken,
  //     );

  //     final UserCredential userCredential =
  //         await FirebaseAuth.instance.signInWithCredential(credential);

  //     // Get the Firebase User object from the UserCredential
  //     final User? user = userCredential.user;

  //     if (user != null) {
  //       // Access and print the user's display name (username) and email
  //       print('Username: ${user.displayName}');
  //       print('Email: ${user.email}');
  //       setState(() {
  //         loadGoogleSign = false;
  //       });
  //     }

  //     return user;
  //   } on Exception catch (e) {
  //     // TODO
  //     print('exception->$e');
  //   }
  // }

  void verifyPhoneNumber() {
    _auth.verifyPhoneNumber(
        phoneNumber: "+91 9384926154",
        timeout: Duration(seconds: 60),
        verificationCompleted: (phoneCredential) {
          print(phoneCredential);
        },
        verificationFailed: (error) {
          print(error.toString());
        },
        codeSent: (verificationId, forceResending) {
          print(verificationId);
          Navigator.of(context).push(_createRoute(
            Otpscreen(
              verificationId: verificationId,
              userData: userData,
              phoneNo: phoneController.text,
              cameras: widget.cameras,
              alt: widget.alt,
            ),
          ));
        },
        codeAutoRetrievalTimeout: (verificationId) {
          print("Auto Retrieval Timeout");
        });
  }

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  String? _verificationId;

  void _sendOtp() async {
    setState(() {
      showSpinner = true;
    });
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto sign-in if verification is successful
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print("Verification Failed: ${e.message}");
        setState(() {
          isError = true;
          showSpinner = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                30.0,
              ),
            ),
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
              "Error Occured. Try Again!",
              style: TextStyle(
                fontSize: 17.0,
              ),
            ),
          ),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          showSpinner = false;
        });
        print("Code sent to phone number.");
        Navigator.of(context).pushReplacement(_createRoute(
          Otpscreen(
            verificationId: verificationId,
            userData: userData,
            phoneNo: phoneNumber!,
            cameras: widget.cameras,
            alt: widget.alt,
            // url: downloadUrl,
          ),
        ));
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
          showSpinner = false;
        });
        print("Auto retrieval timeout.");
      },
    );
  }

  void _verifyOtp() async {
    String otp = otpController.text.trim();

    // Create PhoneAuthCredential with OTP
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp,
    );

    // Sign in the user
    try {
      await _auth.signInWithCredential(credential);
      print("Phone number verified and user signed in.");
    } catch (e) {
      print("Failed to sign in: ${e.toString()}");
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return null; // User canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Access and print the user's display name (username) and email
        print('Username: ${user.displayName}');
        print('Email: ${user.email}');
      }
      return user;
    } catch (e) {
      print('Error during Google Sign-In: $e');
      return null;
    }
  }

  bool _isEmailSent = false;

  // Method to send the email verification link
  Future<void> sendEmailVerificationLink(String email) async {
    // final String email = _emailController.text;

    // Configure ActionCodeSettings for web-based email verification
    ActionCodeSettings actionCodeSettings = ActionCodeSettings(
      url: 'https://dhanush-turf-262de.firebaseapp.com/finishSignUp',
      handleCodeInApp: true,
    );

    try {
      await _auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );
      setState(() {
        _isEmailSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification link sent to $email')),
      );
    } catch (e) {
      print("Failed to send verification link: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send verification link')),
      );
    }
  }

  // Method to set a password and complete sign-up
  Future<void> setPasswordAndSignUp(String email, String password) async {
    // final String email = _emailController.text;
    // final String password = _passwordController.text;

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          'Sign-up complete!',
        )),
      );
      Navigator.pop(
          context); // Navigate away from this screen or to home screen
    } catch (e) {
      print("Error signing up with email and password: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          'Error signing up',
        )),
      );
    }
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
            image: AssetImage("images/register_bg.png"),
          ),
        ),
        child: Column(
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
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 1.9,
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
                            "Register",
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 22.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                onChanged: (value) {
                                  setState(() {
                                    email = value;
                                  });
                                },
                                controller: phoneController,
                                // textInputAction: TextInputAction.search,
                                decoration: kLoginFieldDecoration.copyWith(
                                  hintText: 'Email',
                                ),
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              TextField(
                                keyboardType: TextInputType.number,
                                // controller: phoneController,
                                // textInputAction: TextInputAction.search,
                                decoration: kLoginFieldDecoration.copyWith(
                                  hintText: 'Phone No',
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    phoneNumber = value;
                                    isError = false;
                                  });
                                },
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              TextField(
                                obscureText: true,
                                onChanged: (value) {
                                  setState(() {
                                    password = value;
                                  });
                                },
                                controller: otpController,
                                // textInputAction: TextInputAction.,
                                decoration: kLoginFieldDecoration.copyWith(
                                  hintText: 'Password',
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              TextButton(
                                onPressed: () async {
                                  print(email);
                                  print(password);
                                  print(phoneNumber);

                                  setState(() {
                                    showSpinner = true;
                                  });
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  // verifyPhoneNumber();
                                  // sendEmailVerificationLink(username);
                                  registerAndAddToFirestore();
                                },
                                style: TextButton.styleFrom(
                                    fixedSize: Size(100.0, 50.0),
                                    // padding:
                                    // EdgeInsets.symmetric(vertical: 10.0),
                                    backgroundColor: greenColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    )
                                    // fixedSize: Size(double.infinity, 50.0),
                                    ),
                                child: showSpinner
                                    ? Transform.scale(
                                        scale: 0.7,
                                        child: CircularProgressIndicator(
                                          color: whiteColor,
                                        ),
                                      )
                                    : Text(
                                        "Register",
                                        style: TextStyle(
                                          color: whiteColor,
                                          fontSize: 17.0,
                                        ),
                                      ),
                              ),
                              SizedBox(
                                height: 15.0,
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
                                  setState(() {
                                    loadGoogleSign = true;
                                  });
                                  try {
                                    await signInWithGoogleAndAddToFirestore();
                                  } catch (e) {
                                    print(e);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        snackBar("Error Occured. Try Again!"));
                                  }
                                  setState(() {
                                    loadGoogleSign = false;
                                  });
                                },
                                style: TextButton.styleFrom(
                                    fixedSize: Size(100.0, 50.0),
                                    // padding:
                                    // EdgeInsets.symmetric(vertical: 10.0),
                                    backgroundColor: whiteColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    )
                                    // fixedSize: Size(double.infinity, 50.0),
                                    ),
                                child: loadGoogleSign
                                    ? Transform.scale(
                                        scale: 0.7,
                                        child: CircularProgressIndicator(
                                          color: whiteColor,
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
                                      LoginScreen(
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
                                  "Already have an Account?",
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
    double triangleHeight =
        size.height * 0.2; // Adjust this to control the height of the triangle

    // Start at top-left corner
    path.moveTo(0, triangleHeight);
    // Draw line to the top-center (forming the tip of the triangle)
    path.lineTo(size.width / 2, 0);
    // Draw line to the top-right corner
    path.lineTo(size.width, triangleHeight);
    // Continue drawing down the rectangle sides
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
