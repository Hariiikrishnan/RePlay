import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turf_arena/constants.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:turf_arena/screens/OtpScreen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:turf_arena/screens/app.dart';

class SetProfile extends StatefulWidget {
  SetProfile(this.userData, this.cameras, this.alt);

  Map<dynamic, dynamic> userData;
  final List<CameraDescription> cameras;
  final String alt;

  @override
  State<SetProfile> createState() => _SetProfileState();
}

class _SetProfileState extends State<SetProfile> {
  File? _image;

  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  bool isError = false;
  double progress = 0.0;

  var imageName = DateTime.now().millisecondsSinceEpoch.toString();
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

  // void verifyPhoneNumber() {
  //   _auth.verifyPhoneNumber(
  //       phoneNumber: "+91 9384926154",
  //       timeout: Duration(seconds: 60),
  //       verificationCompleted: (phoneCredential) {
  //         print(phoneCredential);
  //       },
  //       verificationFailed: (error) {
  //         print(error.toString());
  //         setState(() {
  //           isError = true;
  //         });
  //       },
  //       codeSent: (verificationId, forceResending) {
  //         print(verificationId);
  //         Navigator.of(context).push(_createRoute(
  //           Otpscreen(
  //             verificationId: verificationId,
  //             userData: widget.userData,
  //             phoneNo: phoneController.text,
  //             cameras: widget.cameras,
  //             alt: widget.alt,
  //             // url: downloadUrl,
  //           ),
  //         ));
  //       },
  //       codeAutoRetrievalTimeout: (verificationId) {
  //         print("Auto Retrieval Timeout");
  //       });
  // }

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  String? _verificationId;
  var downloadUrl;

  // void _sendOtp() async {
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
  //       });
  //     },
  //     codeSent: (String verificationId, int? resendToken) {
  //       setState(() {
  //         _verificationId = verificationId;
  //       });
  //       print("Code sent to phone number.");
  //       Navigator.of(context).push(_createRoute(
  //         Otpscreen(
  //           verificationId: verificationId,
  //           userData: widget.userData,
  //           phoneNo: phoneController.text,
  //           cameras: widget.cameras,
  //           alt: widget.alt,
  //           // url: downloadUrl,
  //         ),
  //       ));
  //     },
  //     codeAutoRetrievalTimeout: (String verificationId) {
  //       setState(() {
  //         _verificationId = verificationId;
  //       });
  //       print("Auto retrieval timeout.");
  //     },
  //   );
  //   setState(() {
  //     showSpinner = false;
  //   });
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
  void initState() {
    // TODO: implement initState
    super.initState();
    initSharedPref();
  }

  String displayName = "";

  // Future<String> uploadProfile() async {
  //   print(_image);
  //   var imageName = DateTime.now().millisecondsSinceEpoch.toString();
  //   var storageRef =
  //       FirebaseStorage.instance.ref().child('profiles/$imageName.jpg');
  //   var uploadTask = storageRef.putFile(_image!);
  //   var downloadUrl = await (await uploadTask).ref.getDownloadURL();
  //   return downloadUrl;
  // }

  late SharedPreferences prefs;

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<String> uploadProfile() async {
    setState(() {
      showSpinner = true;
    });
    try {
      if (_image == null) {
        throw Exception("No image selected for upload");
      }
      print("Uploading image: $_image");
      var imageName = DateTime.now().millisecondsSinceEpoch.toString();
      var storageRef =
          FirebaseStorage.instance.ref().child('profiles/$imageName.jpg');
      var uploadTask = storageRef.putFile(
        _image!,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          progress = snapshot.bytesTransferred / snapshot.totalBytes;
        });
        print("Upload progress: ${progress * 100}%");
      });

      var snapshot = await uploadTask;
      var downloadUrl = await snapshot.ref.getDownloadURL();
      print("Upload successful, download URL: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      rethrow;
    }
  }

  Future<void> updateUserToFirestore(url) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userData['uid'])
          .get();
      if (userDoc.exists) {
        setState(() {
          // widget.userData['phone'] = widget.phoneNo;
          widget.userData['photoURL'] = url;
        });

        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userData['uid'])
            .set(widget.userData.cast<String, dynamic>());
        Navigator.of(context).pushReplacement(_createRoute(
          App(widget.userData, widget.cameras, widget.alt),
        ));
      }
    } catch (e) {
      print('Error adding user to Firestore: $e');
    }
  }

  Future<void> updateUserNameToFirestore(newName) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userData['uid'])
          .update({'displayName': newName});
      setState(() {
        // widget.userData['phone'] = widget.phoneNo;
        widget.userData['displayName'] = newName;
        progress = 100.0;
      });
      prefs.setString('displayName', newName);

      // if (userDoc.exists) {
      //   setState(() {
      //     // widget.userData['phone'] = widget.phoneNo;
      //     widget.userData['displayName'] = newName;
      //   });

      //   await FirebaseFirestore.instance
      //       .collection('users')
      //       .doc(widget.userData['uid'])
      //       .set(widget.userData.cast<String, dynamic>());
      // }
    } catch (e) {
      print('Error adding user to Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: whiteColor,
      body: Container(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 30.0,
            left: 20.0,
            right: 20.0,
            bottom: 5.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 50.0,
              ),
              Container(
                width: 200.0,
                height: 200.0,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 180.0,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _image == null
                          ? null
                          : FileImage(
                              _image!), // Use FileImage if _image is a File
                      child: _image == null
                          ? Icon(
                              Icons.person,
                              size: 130.0,
                            )
                          : null,
                    ),
                    Align(
                      heightFactor: MediaQuery.of(context).size.height / 175,
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            side: BorderSide(
                              width: 1.0,
                              color: whiteColor,
                            )),
                        onPressed: () async {
                          final image = await ImagePicker()
                              .pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            setState(() {
                              _image = File(image.path);
                            });
                          }
                        },
                        child: Icon(
                          Icons.edit,
                          color: whiteColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              TextField(
                onChanged: (value) {
                  setState(() {
                    displayName = value;
                  });
                },
                // controller: displayName,
                // textInputAction: TextInputAction.search,
                decoration: kLoginFieldDecoration.copyWith(
                  hintText: 'Display Name',
                ),
              ),
              SizedBox(
                height: 5.0,
              ),

              Spacer(),
              // ElevatedButton(
              //     style: ElevatedButton.styleFrom(
              //       fixedSize: Size(150.0, 45.0),
              //       backgroundColor: primaryColor,
              //       shape: RoundedRectangleBorder(
              //         side: BorderSide(
              //           width: 1.0,
              //           color: whiteColor,
              //         ),
              //         borderRadius: BorderRadius.circular(
              //           12.0,
              //         ),
              //       ),
              //     ),
              //     onPressed: () async {
              //       var downloadUrl = await uploadProfile();

              //       await updateUserToFirestore(downloadUrl);

              //       setState(() {
              //         showSpinner = false;
              //       });
              //     },
              //     child: showSpinner
              //         ? Transform.scale(
              //             scale: 0.7,
              //             child: CircularProgressIndicator(
              //               color: whiteColor,
              //             ),
              //           )
              //         : Text(
              //             "Add Profile",
              //             style: TextStyle(
              //               fontSize: 18.0,
              //               color: whiteColor,
              //             ),
              //           )),
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.0, end: progress),
                duration: Duration(milliseconds: 500),
                builder: (context, double value, child) {
                  return GestureDetector(
                    onTap: () async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      if (_image == null || displayName == "") {
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
                              "Enter All Fields!",
                              style: TextStyle(
                                fontSize: 17.0,
                              ),
                            ),
                          ),
                        );
                      } else {
                        var downloadUrl = await uploadProfile();
                        await updateUserNameToFirestore(displayName);
                        await updateUserToFirestore(downloadUrl);

                        setState(() {
                          showSpinner = false;
                        });
                      }
                    },
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          width: 1.0,
                          color: whiteColor,
                        ),
                        gradient: LinearGradient(
                          colors: [
                            Colors.green,
                            primaryColor,
                          ],
                          stops: [
                            value,
                            value
                          ], // Adjust the gradient stop dynamically
                        ),
                      ),
                      alignment: Alignment.center,
                      child: showSpinner
                          ? Text(
                              'Uploading',
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 15,
                              ),
                            )
                          : Text(
                              'Add Profile',
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  );
                },
              ),
              // ButtonProgressColorChange(),
            ],
          ),
        ),
      ),
    );
  }
}

// class ButtonProgressColorChange extends StatefulWidget {
//   @override
//   _ButtonProgressColorChangeState createState() =>
//       _ButtonProgressColorChangeState();
// }

// class _ButtonProgressColorChangeState extends State<ButtonProgressColorChange> {
//   double progress = 0.0;

  // void _increaseProgress() {
  //   // setState(() {
  //   //   progress += 0.2; // Increment progress by 20% per click
  //   //   if (progress > 1.0) progress = 0.0; // Reset if progress exceeds 100%
  //   // });
  //    var downloadUrl = await uploadProfile();

  //                   await updateUserToFirestore(downloadUrl);

  //                   setState(() {
  //                     showSpinner = false;
  //                   });
  // }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child:
//     );
//   }
// }
