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

class Editprofile extends StatefulWidget {
  Editprofile(this.userData);

  Map<dynamic, dynamic> userData;

  @override
  State<Editprofile> createState() => _EditprofileState();
}

class _EditprofileState extends State<Editprofile> {
  File? _image;

  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  bool isError = false;
  double progress = 0.0;
  bool isSaved = false;

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

  String? _verificationId;
  var downloadUrl;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    newName = widget.userData['displayName'];
    initSharedPref();
    print(widget.userData);
  }

  late SharedPreferences prefs;

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  // Future<String> uploadProfile() async {
  //   print(_image);
  //   var imageName = DateTime.now().millisecondsSinceEpoch.toString();
  //   var storageRef =
  //       FirebaseStorage.instance.ref().child('profiles/$imageName.jpg');
  //   var uploadTask = storageRef.putFile(_image!);
  //   var downloadUrl = await (await uploadTask).ref.getDownloadURL();
  //   return downloadUrl;
  // }

  late String newName;

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

  Future<void> updateUserImgToFirestore(url) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userData['uid'])
          .get();
      if (userDoc.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userData['uid'])
            .set(widget.userData.cast<String, dynamic>());
        setState(() {
          // widget.userData['phone'] = widget.phoneNo;
          widget.userData['photoURL'] = url;
          isSaved = true;
        });
        prefs.setString('photoURL', url);
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
        isSaved = true;
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

  bool checkIsChanged() {
    if (_image != null || newName != widget.userData['displayName']) {
      return true;
    } else {
      return false;
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
            left: 20.0,
            right: 20.0,
            top: 30.0,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    // backgroundColor: whiteColor,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(50.0),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.25),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 1), // changes position of shadow
                        ),
                      ],
                    ),
                    // radius: 25.0,
                    child: IconButton(
                      splashRadius: 35.0,
                      // color: Colors.red,
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: whiteColor,
                        size: 20.0,
                      ), // Favorite icon
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              Container(
                width: 250.0,
                height: 250.0,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(180.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            radius: 180.0,

                            backgroundColor: Colors.grey[200],
                            backgroundImage: _image == null
                                ? NetworkImage(
                                    widget.userData['photoURL'],
                                  )
                                : FileImage(
                                    _image!,
                                  ), // Use FileImage if _image is a File
                            // child: _image != null
                            //     ? Icon(
                            //         Icons.person,
                            //         size: 130.0,
                            //       )
                            //     : null,
                          ),
                        ),
                      ),
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
                height: 25.0,
              ),
              TextField(
                onChanged: (value) {
                  setState(() {
                    newName = value;
                  });
                },
                decoration: kLoginFieldDecoration.copyWith(
                  hintText: widget.userData['displayName'],
                ),
              ),
              Spacer(),
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.0, end: progress),
                duration: Duration(milliseconds: 500),
                builder: (context, double value, child) {
                  return GestureDetector(
                    onTap: () async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      if (newName != widget.userData['displayName']) {
                        print(newName);
                        await updateUserNameToFirestore(newName);
                        setState(() {
                          showSpinner = false;
                        });
                        print("Username updated sucessfully!");
                      }
                      if (_image != null) {
                        var downloadUrl = await uploadProfile();

                        await updateUserImgToFirestore(downloadUrl);

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
                        color: checkIsChanged()
                            ? primaryColor
                            : isSaved
                                ? Colors.green
                                : Colors.grey[200],
                        gradient: LinearGradient(
                          colors: checkIsChanged()
                              ? [
                                  Colors.green,
                                  primaryColor,
                                ]
                              : isSaved
                                  ? [
                                      Colors.green,
                                      Colors.green,
                                    ]
                                  : [
                                      Colors.grey[300]!,
                                      Colors.grey[300]!,
                                      // primaryColor,
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
                          : isSaved
                              ? Text(
                                  'Changes Saved',
                                  style: TextStyle(
                                    color: whiteColor,
                                    fontSize: 15,
                                  ),
                                )
                              : Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    color: checkIsChanged()
                                        ? whiteColor
                                        : Colors.grey[700],
                                    fontSize: 15,
                                  ),
                                ),
                    ),
                  );
                },
              ),
              // ButtonProgressColorChange(),
              SizedBox(
                height: 10.0,
              )
            ],
          ),
        ),
      ),
    );
  }
}
