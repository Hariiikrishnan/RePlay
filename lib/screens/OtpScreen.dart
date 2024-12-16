import 'package:camera/camera.dart';
import 'package:turf_arena/constants.dart';
import 'package:turf_arena/screens/SetProfile.dart';
import 'package:turf_arena/screens/app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Otpscreen extends StatefulWidget {
  Otpscreen({
    required this.verificationId,
    required this.userData,
    required this.phoneNo,
    required this.cameras,
  });

  Map<dynamic, dynamic> userData;
  final String verificationId;
  String phoneNo;
  final List<CameraDescription> cameras;
  // String url;
  @override
  State<Otpscreen> createState() => _OtpscreenState();
}

class _OtpscreenState extends State<Otpscreen> {
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  bool loadGoogleSign = false;
  late String username;
  late String password;

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

  void registerAndAddToFirestore(String email, String password) async {
    // if (_formKey.currentState!.validate()) {
    // String email = _emailController.text.trim();
    // String password = _passwordController.text.trim();

    User? user = await registerWithEmail(email, password);
    if (user != null) {
      await addUserToFirestore(user);
      print('User registered and added to Firestore');
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return App({
          'u_id': user.uid,
          'username': user.displayName,
          'email': user.email,
        }, widget.cameras);
      }));
    }
  }

  Future<User?> registerWithEmail(String email, String password) async {
    try {
      // _auth.sendSignInLinkToEmail(email: email, actionCodeSettings: acs);
      // UserCredential userCredential =
      //     await _auth.createUserWithEmailAndPassword(
      //   email: email,
      //   password: password,
      // );
      // return userCredential.user;
    } catch (e) {
      print('Error in Email/Password Registration: $e');
      return null;
    }
  }

  Future<void> updateUserToFirestore() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userData['uid'])
          .get();
      if (userDoc.exists) {
        setState(() {
          widget.userData['phone'] = widget.phoneNo;
          // widget.userData['phototURL'] = widget.url;
        });

        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userData['uid'])
            .set(widget.userData.cast<String, dynamic>());
        Navigator.of(context).push(_createRoute(
          App(
            widget.userData,
            widget.cameras,
          ),
        ));
      }
    } catch (e) {
      print('Error adding user to Firestore: $e');
    }
  }

  Future<void> addUserToFirestore(User user) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!userDoc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName ?? '',
          'photoURL': user.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error adding user to Firestore: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.verificationId);
  }

  // Define controllers for each TextField
  final TextEditingController controller1 = TextEditingController();
  final TextEditingController controller2 = TextEditingController();
  final TextEditingController controller3 = TextEditingController();
  final TextEditingController controller4 = TextEditingController();
  final TextEditingController controller5 = TextEditingController();
  final TextEditingController controller6 = TextEditingController();

  // Function to get combined string
  String getCombinedOtp() {
    return controller1.text +
        controller2.text +
        controller3.text +
        controller4.text +
        controller5.text +
        controller6.text;
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    controller1.dispose();
    controller2.dispose();
    controller3.dispose();
    controller4.dispose();
    controller5.dispose();
    controller6.dispose();
    super.dispose();
  }

  // void _verifyOtp(otp) async {
  //   // String otp = otpController.text.trim();

  //   // Create PhoneAuthCredential with OTP
  //   PhoneAuthCredential credential = PhoneAuthProvider.credential(
  //     verificationId: widget.verificationId!,
  //     smsCode: otp,
  //   );

  //   // Sign in the user
  //   try {
  //     // await _auth.signInWithCredential(credential);
  //     print("Phone number verified and user signed in.");
  //     // updateUserToFirestore();
  //     setState(() {
  //       widget.userData['phone'] = widget.phoneNo;
  //     });
  //     Navigator.of(context).push(_createRoute(
  //       SetProfile(
  //         widget.userData,
  //       ),
  //     ));
  //     setState(() {
  //       showSpinner = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       showSpinner = false;
  //     });
  //     print("Failed to sign in: ${e.toString()}");
  //   }
  // }

  void _verifyOtp(String otp) async {
    // Show spinner while verifying
    setState(() {
      showSpinner = true;
    });

    // Check if verificationId is available
    if (widget.verificationId == null) {
      print("Verification ID is null.");
      setState(() {
        showSpinner = false;
      });
      return;
    }

    try {
      // Create PhoneAuthCredential with OTP
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId!,
        smsCode: otp,
      );

      // Sign in the user
      await _auth.signInWithCredential(credential);
      print("Phone number verified and user signed in.");

      // Update user data
      setState(() {
        widget.userData['phone'] = widget.phoneNo;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
            30.0,
          )),
          // margin: EdgeInsets.symmetric(
          //   horizontal: 20.0,
          //   vertical: 50.0,
          // ),
          padding: EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 20.0,
          ),
          // elevation: 6.0,
          // behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green[400],
          content: Text(
            "Phone Number Authenticated.",
            style: TextStyle(
              fontSize: 17.0,
            ),
          ),
        ),
      );
      // Navigate to next screen
      Navigator.of(context).pushReplacement(
        _createRoute(
          SetProfile(widget.userData, widget.cameras),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        showSpinner = false;
      });
      print(e.code);
      // Check for incorrect OTP error
      if (e.code == 'invalid-verification-code') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
              30.0,
            )),
            padding: EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 20.0,
            ),
            backgroundColor: Colors.red[400],
            content: Text(
              "OTP is incorrect. Please try again.",
              style: TextStyle(
                fontSize: 17.0,
              ),
            ),
          ),
        );
      } else if (e.code == 'session-expired') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
              30.0,
            )),
            // margin: EdgeInsets.symmetric(
            //   horizontal: 20.0,
            //   vertical: 50.0,
            // ),
            padding: EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 20.0,
            ),
            // elevation: 6.0,
            // behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red[400],
            content: Text(
              "OTP has expired. Please request a new one.",
              style: TextStyle(
                fontSize: 17.0,
              ),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
              30.0,
            )),
            // margin: EdgeInsets.symmetric(
            //   horizontal: 20.0,
            //   vertical: 50.0,
            // ),
            padding: EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 20.0,
            ),
            // elevation: 6.0,
            // behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red[400],
            content: Text(
              "Failed to verify OTP: ${e.message}",
              style: TextStyle(
                fontSize: 17.0,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        showSpinner = false;
      });

      // General error handling
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
            30.0,
          )),
          // margin: EdgeInsets.symmetric(
          //   horizontal: 20.0,
          //   vertical: 50.0,
          // ),
          padding: EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 5.0,
          ),
          // elevation: 6.0,
          // behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red[400],
          content: Text("An error occurred: ${e.toString()}"),
        ),
      );
    } finally {
      // Stop showing spinner
      setState(() {
        showSpinner = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      resizeToAvoidBottomInset: false,
      body: Container(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 50.0,
                  left: 20.0,
                  right: 20.0,
                ),
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image(
                        image: AssetImage("images/logo.png"),
                      ),
                      Text(
                        "Verification",
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 30.0,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50.0),
                    topRight: Radius.circular(50.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 50.0,
                    bottom: 20.0,
                    left: 20.0,
                    right: 20.0,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: kOtpDecoration,
                                controller: controller1,
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18.0,
                                ),
                                textAlign: TextAlign.start,
                                maxLength: 1,
                                buildCounter: (context,
                                        {required currentLength,
                                        required isFocused,
                                        maxLength}) =>
                                    null,
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  print(value);
                                  if (value.length == 1)
                                    FocusScope.of(context).nextFocus();
                                },
                              ),
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Expanded(
                              child: TextField(
                                decoration: kOtpDecoration,
                                controller: controller2,
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18.0,
                                ),
                                maxLength: 1,
                                buildCounter: (context,
                                        {required currentLength,
                                        required isFocused,
                                        maxLength}) =>
                                    null,
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  if (value.length == 1)
                                    FocusScope.of(context).nextFocus();
                                },
                              ),
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Expanded(
                              child: TextField(
                                decoration: kOtpDecoration,
                                controller: controller3,
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18.0,
                                ),
                                maxLength: 1,
                                buildCounter: (context,
                                        {required currentLength,
                                        required isFocused,
                                        maxLength}) =>
                                    null,
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  if (value.length == 1)
                                    FocusScope.of(context).nextFocus();
                                },
                              ),
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Expanded(
                              child: TextField(
                                decoration: kOtpDecoration,
                                controller: controller4,
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18.0,
                                ),
                                maxLength: 1,
                                buildCounter: (context,
                                        {required currentLength,
                                        required isFocused,
                                        maxLength}) =>
                                    null,
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  if (value.length == 1)
                                    FocusScope.of(context).nextFocus();
                                },
                              ),
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Expanded(
                              child: TextField(
                                decoration: kOtpDecoration,
                                controller: controller5,
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18.0,
                                ),
                                maxLength: 1,
                                buildCounter: (context,
                                        {required currentLength,
                                        required isFocused,
                                        maxLength}) =>
                                    null,
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  if (value.length == 1)
                                    FocusScope.of(context).nextFocus();
                                },
                              ),
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Expanded(
                              child: TextField(
                                decoration: kOtpDecoration,
                                controller: controller6,
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18.0,
                                ),
                                maxLength: 1,
                                buildCounter: (context,
                                        {required currentLength,
                                        required isFocused,
                                        maxLength}) =>
                                    null,
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  if (value.length == 1)
                                    FocusScope.of(context).nextFocus();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 30.0,
                        ),
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                              // padding: Ede
                              ),
                          child: Text(
                            "Resend the code?",
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            showSpinner = true;
                          });
                          try {
                            print(getCombinedOtp());

                            _verifyOtp(getCombinedOtp());
                            // final cred = PhoneAuthProvider.credential(
                            //     verificationId: widget.verificationId,
                            //     smsCode: "123456");

                            // print(cred);
                          } catch (error) {
                            print(error.toString());
                          }
                        },
                        style: TextButton.styleFrom(
                            backgroundColor: primaryColor,
                            fixedSize: Size(
                              150.0,
                              50.0,
                            ),
                            side: BorderSide(
                              width: 1.0,
                              color: whiteColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            )),
                        icon: !showSpinner
                            ? Icon(
                                Icons.arrow_forward,
                                color: whiteColor,
                              )
                            : null,
                        iconAlignment: IconAlignment.end,
                        label: showSpinner
                            ? Transform.scale(
                                scale: 0.7,
                                child: CircularProgressIndicator(
                                  color: whiteColor,
                                ),
                              )
                            : Text(
                                "Submit",
                                style: TextStyle(
                                  color: whiteColor,
                                  fontSize: 18.0,
                                ),
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
    );
  }
}
