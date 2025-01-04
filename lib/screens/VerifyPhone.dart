import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:turf_arena/constants.dart';
import 'package:turf_arena/screens/OtpScreen.dart';

class VerifyPhone extends StatefulWidget {
  VerifyPhone(this.userData);

  Map<dynamic, dynamic> userData;

  @override
  State<VerifyPhone> createState() => _VerifyPhoneState();
}

class _VerifyPhoneState extends State<VerifyPhone> {
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  bool isError = false;
// var storageRef = FirebaseStorage.instance.ref().child('driver_images/$imageName.jpg');
// var uploadTask = storageRef.putFile(_image!);
// var downloadUrl = await (await uploadTask).ref.getDownloadURL();

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

  void verifyPhoneNumber() {
    _auth.verifyPhoneNumber(
        phoneNumber: "+91 9384926154",
        timeout: Duration(seconds: 60),
        verificationCompleted: (phoneCredential) {
          print(phoneCredential);
        },
        verificationFailed: (error) {
          print(error.toString());
          setState(() {
            isError = true;
          });
        },
        codeSent: (verificationId, forceResending) {
          print(verificationId);
          // Navigator.of(context).push(_createRoute(
          //   Otpscreen(
          //     verificationId: verificationId,
          //     userData: widget.userData,
          //     phoneNo: phoneController.text,
          //     // url: downloadUrl,
          //   ),
          // ));
        },
        codeAutoRetrievalTimeout: (verificationId) {
          print("Auto Retrieval Timeout");
        });
  }

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  String? _verificationId;

  // void _sendOtp() async {
  //   setState(() {
  //     showSpinner = true;
  //   });
  //   await _auth.verifyPhoneNumber(
  //     phoneNumber: phoneController.text,
  //     timeout: const Duration(seconds: 60),
  //     verificationCompleted: (PhoneAuthCredential credential) async {
  //       // Auto sign-in if verification is successful
  //       await _auth.signInWithCredential(credential);
  //     },
  //     verificationFailed: (FirebaseAuthException e) {
  //       print("Verification Failed: ${e.message}");
  //       setState(() {
  //         isError = true;
  //         showSpinner = false;
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(
  //               30.0,
  //             ),
  //           ),
  //           margin: EdgeInsets.symmetric(
  //             horizontal: 5.0,
  //             vertical: 5.0,
  //           ),
  //           padding: EdgeInsets.symmetric(
  //             horizontal: 30.0,
  //             vertical: 5.0,
  //           ),
  //           elevation: 50.0,
  //           behavior: SnackBarBehavior.floating,
  //           backgroundColor: Colors.red[400],
  //           showCloseIcon: true,
  //           closeIconColor: whiteColor,
  //           content: Text(
  //             "Error Occured. Try Again!",
  //             style: TextStyle(
  //               fontSize: 17.0,
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //     codeSent: (String verificationId, int? resendToken) {
  //       setState(() {
  //         _verificationId = verificationId;
  //         showSpinner = false;
  //       });
  //       print("Code sent to phone number.");
  //       Navigator.of(context).pushReplacement(_createRoute(
  //         Otpscreen(
  //           verificationId: verificationId,
  //           userData: widget.userData,
  //           phoneNo: phoneController.text,
  //           cameras: [],
  //           alt: "",

  //           // url: downloadUrl,
  //         ),
  //       ));
  //     },
  //     codeAutoRetrievalTimeout: (String verificationId) {
  //       setState(() {
  //         _verificationId = verificationId;
  //         showSpinner = false;
  //       });
  //       print("Auto retrieval timeout.");
  //     },
  //   );
  // }

  void _verifyOtp(otp) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      body: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 100.0,
            horizontal: 25.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Authorize Your Account!",
                style: TextStyle(
                  color: whiteColor,
                  fontSize: 20.0,
                ),
              ),
              SizedBox(
                height: 40.0,
              ),
              TextField(
                decoration: kLoginFieldDecoration.copyWith(
                  hintText: "Phone No.",
                ),
                controller: phoneController,
                onChanged: (value) {
                  setState(() {
                    isError = false;
                  });
                },
              ),
              SizedBox(
                height: 25.0,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(200.0, 50.0),
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1.0,
                      color: whiteColor,
                    ),
                    borderRadius: BorderRadius.circular(
                      12.0,
                    ),
                  ),
                ),
                onPressed: () async {
                  // !showSpinner ? _sendOtp() : null;
                  // print(downloadUrl);
                  // Navigator.of(context).push(_createRoute(
                  //   Otpscreen(
                  //     verificationId,
                  //   ),
                  // ));
                  // _verificationId == null ? _sendOtp() : _verifyOtp();
                },
                child: showSpinner
                    ? Transform.scale(
                        scale: 0.7,
                        child: CircularProgressIndicator(
                          color: whiteColor,
                        ),
                      )
                    : Text(
                        'Verify Phone',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: whiteColor,
                        ),
                      ),
              ),
              SizedBox(
                height: 15.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
