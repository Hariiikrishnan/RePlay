import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lindi_sticker_widget/lindi_controller.dart';
import 'package:lindi_sticker_widget/lindi_sticker_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turf_arena/constants.dart';

import 'package:share_plus/share_plus.dart';

class ShowMoment extends StatefulWidget {
  ShowMoment(this.image, this.selectedImage, this.userData);

  File? image;
  String selectedImage;
  Map userData;
  // GlobalKey<ImageEditorState> editorKey = GlobalKey();

  @override
  State<ShowMoment> createState() => _ShowMomentState();
}

class _ShowMomentState extends State<ShowMoment> {
  Uint8List? resultImage;
  bool showSpinner = false;
  bool isSaved = false;
  bool isNotSaved = false;
  double progress = 0.0;
  bool loadingImage = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    widgets = [
      Image.asset(
        widget.selectedImage,
        // width: 600.0,
      ),
    ];
    // lindiController.add(widgets[0], position: Alignment.topLeft);

    lindiController.insidePadding = 0.0;
    lindiController.shouldMove = false;
    lindiController.shouldRotate = false;
    lindiController.shouldScale = false;
    lindiController.showBorders = false;
    lindiController.onPositionChange((index) {
      debugPrint(
          "widgets size: ${lindiController.widgets.length}, current index: $index");
    });
    addSticker();
    if (widget.userData['moments'] is String) {
      print("Coming");
      // Decode the string into a List<dynamic>, even if it's empty
      widget.userData['moments'] = widget.userData['moments'].isEmpty
          ? [] // If it's an empty string, assign an empty list
          : json.decode(
              widget.userData['moments']); // Otherwise, decode the string
    }
    initSharedPref();
  }

  addSticker() async {
    await createStickerAndAdd();
    setState(() {
      loadingImage = false;
    });
  }

  late SharedPreferences prefs;

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  void showSnackBar(String msg, bool status) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(30.0),
        topRight: Radius.circular(30.0),
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
      backgroundColor: status ? greenColor : Colors.red,
      content: Text(
        msg,
        style: TextStyle(
          color: whiteColor,
          fontSize: 15.0,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.start,
      ),
      showCloseIcon: true,
      closeIconColor: whiteColor,
    ));
  }

  // Get image size and add sticker accordingly
  Future<void> createStickerAndAdd() async {
    // Get the size of the widget.image
    final Image image = Image.file(widget.image!);
    Completer<Size> completer = Completer<Size>();
    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool synchronousCall) {
        final size =
            Size(info.image.width.toDouble(), info.image.height.toDouble());
        completer.complete(size);
      }),
    );
    final Size imageSize = await completer.future;

    // Add sticker as a widget using LindiController
    lindiController.add(
      Image.asset(
        widget.selectedImage,
        width: imageSize.width,
        height: imageSize.height,
        fit: BoxFit.contain,
        scale: 0.55,
      ),
      position: Alignment.center,
    );

    // After adding the sticker, save the image with the sticker
    var result = await lindiController.saveAsUint8List();
    setState(() {
      resultImage = result;
    });
  }

  List<Widget> widgets = [];

  final List<String> imgList = [
    'images/sticker1.png',
    'images/sticker2.png',
    'images/sticker3.png',
  ];

  saveImg() async {
    try {
      await Gal.putImageBytes(resultImage!);

      print("Saved");
    } on GalException catch (e) {
      print(e.type.message);
    }
  }

  LindiController lindiController = LindiController(
    icons: [],
  );

  Future<String> uploadProfile() async {
    setState(() {
      showSpinner = true;
    });

    try {
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/edited_image.png'; // PNG format for high quality
      final file = File(filePath);

      //   // Write the bytes to the file
      await file.writeAsBytes(resultImage!);
      print("Uploading image: $file");
      var imageName = DateTime.now().millisecondsSinceEpoch.toString();
      var storageRef =
          FirebaseStorage.instance.ref().child('moments/$imageName.jpg');

      var uploadTask = storageRef.putFile(
        file,
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
      setState(() {
        isNotSaved = true;
      });
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
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        print(data['moments'].runtimeType);
        print(widget.userData['moments'].runtimeType);
        setState(() {
          widget.userData['moments'].add({
            'url': url,
            'time': DateTime.now().toString(),
          });
        });
        String strJsonString = "";
        if (widget.userData['moments'] != 0) {
          strJsonString = json.encode(widget.userData['moments']);
        }

        prefs.setString('moments', strJsonString);
// // Ensure the moments are a List<String> before adding to Firestore
//         if (widget.userData['moments'] is List<dynamic>) {
//           widget.userData['moments'] =
//               List<String>.from(widget.userData['moments']);
//         }
        print(widget.userData);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userData['uid'])
            .set(widget.userData.cast<String, dynamic>());
        // Navigator.of(context).push(_createRoute(
        //   App(widget.userData, widget.cameras),
        // ));
        setState(() {
          isSaved = true;
        });
      }
    } catch (e) {
      setState(() {
        isNotSaved = true;
      });
      print('Error adding user to Firestore: $e');
    }
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(
        "OK",
        style: TextStyle(
          color: whiteColor,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: Colors.red,
        fixedSize: Size(75.0, 40.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            12.0,
          ),
        ),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text(
        "Continue",
        style: TextStyle(
          color: whiteColor,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: greenColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            12.0,
          ),
        ),
      ),
      onPressed: () {},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      title: Text("Reached Limit"),
      content: Text(
          "You've reached the 4 Moments Limit.If you want to proceed further kindly delete one saved moment."),
      actions: [
        cancelButton,
        // continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Container(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 40.0,
            bottom: 5.0,
          ),
          child: Column(
            spacing: 10.0,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
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
                          offset: Offset(0, 1), // changes position of shadow
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
                        "#RePlayMoment",
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              widget.image != null
                  ? Container(
                      height: MediaQuery.of(context).size.height / 1.5,
                      child: LindiStickerWidget(
                        controller: lindiController,
                        child: SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Image.file(
                              widget.image!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Center(child: Text('No image captured yet')),
              // Container(
              //   child: Text(
              //     "Drag to adjust",
              //     style: TextStyle(
              //       color: greyColor,
              //       fontSize: 14.0,
              //     ),
              //     textAlign: TextAlign.center,
              //   ),
              // ),
              Row(
                spacing: 5.0,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: primaryColor,
                        fixedSize: Size(100.0, 100.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            16.0,
                          ),
                        ),
                      ),
                      onPressed: () async {
                        final hasAccess = await Gal.hasAccess();
                        if (hasAccess) {
                          saveImg();
                          showSnackBar("Image Saved Successfully", true);
                        } else {
                          await Gal.requestAccess();
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 10.0,
                        children: [
                          Icon(
                            Icons.save_alt_rounded,
                            color: whiteColor,
                            size: 35.0,
                          ),
                          Text(
                            "Export Moment",
                            style: TextStyle(
                              color: whiteColor,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: greenColor,
                        fixedSize: Size(100.0, 100.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            16.0,
                          ),
                        ),
                      ),
                      onPressed: () async {
                        // await createStickerAndAdd();

                        final tempDir = await getTemporaryDirectory();
                        final filePath =
                            '${tempDir.path}/edited_image.png'; // PNG format for high quality
                        final file = File(filePath);

                        //   // Write the bytes to the file
                        await file.writeAsBytes(resultImage!);

                        // Share the image using Share package
                        final result = await Share.shareXFiles(
                          [XFile(file.path)],
                          text: 'Check out my #RePlayMoment!',
                        );

                        if (result.status == ShareResultStatus.success) {
                          print('Successfully shared the image!');
                        } else {
                          print('Error: ${result.status}');
                          showSnackBar("Error Occured.Try Again!", false);
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 10.0,
                        children: [
                          Icon(
                            Icons.ios_share_rounded,
                            color: whiteColor,
                            size: 35.0,
                          ),
                          Text(
                            "Share Moment",
                            style: TextStyle(
                              color: whiteColor,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.0, end: progress),
                duration: Duration(milliseconds: 500),
                builder: (context, double value, child) {
                  return GestureDetector(
                    onTap: () async {
                      if (!isSaved && !loadingImage && !showSpinner) {
                        print(widget.userData['moments'].length.toString() +
                            "Length");
                        if (widget.userData['moments'].length < 4) {
                          var url = await uploadProfile();

                          await updateUserToFirestore(url);
                          setState(() {
                            showSpinner = false;
                            // widget.userData['moments'].add({
                            //   'url': url,
                            //   'time': DateTime.now().toIso8601String(),
                            // });
                          });
                        } else {
                          print("Limit Exceeded, Delete One Moment");
                          showAlertDialog(context);
                        }
                      }
                    },
                    child: Container(
                      height: 50,
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          width: 1.0,
                          color: loadingImage
                              ? Colors.grey[100]!
                              : Colors.grey[400]!,
                        ),
                        gradient: LinearGradient(
                          colors: isNotSaved
                              ? [
                                  Colors.red[400]!,
                                  Colors.red[400]!,
                                ]
                              : loadingImage
                                  ? [
                                      Colors.grey[100]!,
                                      Colors.grey[100]!,
                                    ]
                                  : [
                                      Colors.green,
                                      Colors.grey[200]!,
                                    ],
                          stops: [
                            value,
                            value
                          ], // Adjust the gradient stop dynamically
                        ),
                      ),
                      alignment: Alignment.center,
                      child: isNotSaved
                          ? Text(
                              "Couldn't Save",
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 15,
                              ),
                            )
                          : showSpinner
                              ? Text(
                                  'Uploading',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 15,
                                  ),
                                )
                              : isSaved
                                  ? Text(
                                      'Moment Saved',
                                      style: TextStyle(
                                        color: whiteColor,
                                        fontSize: 15,
                                      ),
                                    )
                                  : Text(
                                      'Save Moment',
                                      style: TextStyle(
                                        color: loadingImage
                                            ? primaryColor.withOpacity(0.4)
                                            : primaryColor,
                                        fontSize: 15,
                                      ),
                                    ),
                    ),
                  );
                },
              ),
              // TextButton(
              //     style: TextButton.styleFrom(
              //       backgroundColor: Colors.grey[300],
              //       fixedSize: Size(100.0, 50.0),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(
              //           16.0,
              //         ),
              //       ),
              //     ),
              //     onPressed: () async {},
              //     child: showSpinner
              //         ? Text(
              //             'Uploading..',
              //             style: TextStyle(
              //               color: Colors.white,
              //               fontSize: 18,
              //             ),
              //           )
              //         : Text(
              //             "Save Moment",
              //             style: TextStyle(
              //               color: primaryColor,
              //               fontSize: 15.0,
              //             ),
              //           )),

              // resultImage != null
              //     ? Container(
              //         child: Image.memory(resultImage!),
              //         height: 100.0,
              //       )
              //     : Container(
              //         height: 100.0,
              //         child: Text("Waiting"),
              //       ),
            ],
          ),
        ),
      ),
    );
  }
}

class StickerDrag extends StatelessWidget {
  StickerDrag(this.details, this.callback);
  Map details;

  Function callback;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(
            12.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50.0,
              backgroundImage: AssetImage(
                details['src'],
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                // padding: EdgeInsets.all(0.0,),
                minimumSize: Size(
                  120.0,
                  50.0,
                ),
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12.0),
                    bottomRight: Radius.circular(12.0),
                  ),
                ),
              ),
              onPressed: () {
                callback();
              },
              child: Icon(
                Icons.add,
              ),
            )
          ],
        ),
      ),
    );
  }
}
