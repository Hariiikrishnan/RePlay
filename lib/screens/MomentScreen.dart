import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:turf_arena/constants.dart';

class MomentScreen extends StatefulWidget {
  MomentScreen(this.img, this.userData);

  Map img;
  Map userData;

  @override
  State<MomentScreen> createState() => _MomentScreenState();
}

class _MomentScreenState extends State<MomentScreen> {
  Uint8List? resultImage;
  bool showSpinner = false;
  bool isDeleted = false;
  double progress = 0.0;

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

  saveImg() async {
    try {
      await Gal.putImageBytes(resultImage!);

      print("Saved");
    } on GalException catch (e) {
      print(e.type.message);
    }
  }

  bool loadDelete = false;
  Future<void> removeUrlAndImage(String documentId, String urlToRemove) async {
    try {
      // Step 1: Fetch the document by ID
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users') // replace with your collection name
          .doc(documentId)
          .get();

      if (documentSnapshot.exists) {
        // Step 2: Retrieve the list of moments (assuming it's a list of maps)
        List<dynamic> moments = documentSnapshot['moments'] ?? [];

        // Step 3: Find and remove the URL from the moments list
        moments.removeWhere((moment) => moment['url'] == urlToRemove);
        print(moments);
        // Step 4: Delete the image from Firebase Storage if URL exists
        // Extract image path from the URL (assuming URL contains the image path)
        try {
          // Assuming the image is stored in the 'moments' folder
          // Extract the image name from the URL (assuming the URL contains the file name at the end)
          final Uri imageUri = Uri.parse(urlToRemove);
          final String imagePath = imageUri.pathSegments
              .last; // Get the last part of the path (the image file name)

          // Construct the reference to the image in Firebase Storage (inside the 'moments' folder)
          // Reference imageRef =
          //     FirebaseStorage.instance.ref().child('moments/$imagePath');
          Reference imageRef = FirebaseStorage.instance.refFromURL(urlToRemove);

          // Delete the image from Firebase Storage
          await imageRef.delete();
          print('Image deleted successfully from storage');
        } catch (e) {
          setState(() {
            loadDelete = false;
          });
          print('Error deleting image from storage: $e');
        }
        setState(() {
          progress = 50.0;
        });
        setState(() {
          widget.userData['moments']
              .removeWhere((moment) => moment['url'] == urlToRemove);
        });

        // Step 5: Update the document with the new list of moments
        await FirebaseFirestore.instance
            .collection('users') // replace with your collection name
            .doc(documentId)
            .update({'moments': moments});

        print('Document updated and URL removed successfully');
        setState(() {
          loadDelete = false;
          isDeleted = true;
          progress = 100.0;
        });
      } else {
        print('Document not found');
        setState(() {
          loadDelete = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        loadDelete = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
          ),
          child: Column(
            spacing: 15.0,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(widget.img['url']),
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
                          text: 'Check out my Re Play Moment!',
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
                      setState(() {
                        loadDelete = true;
                      });
                      await removeUrlAndImage(
                          widget.userData['uid'], widget.img['url']);
                    },
                    child: Container(
                      height: 50,
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          width: 1.0,
                          color: Colors.grey[400]!,
                        ),
                        gradient: LinearGradient(
                          colors: [
                            greenColor,
                            Colors.grey[200]!,
                          ],
                          stops: [
                            value,
                            value
                          ], // Adjust the gradient stop dynamically
                        ),
                      ),
                      alignment: Alignment.center,
                      child: loadDelete
                          ? Transform.scale(
                              scale: 0.7,
                              child: CircularProgressIndicator(
                                // value: 0.5,
                                color: primaryColor.withOpacity(0.7),
                              ),
                            )
                          : isDeleted
                              ? Text(
                                  'Moment Deleted',
                                  style: TextStyle(
                                    color: whiteColor,
                                    fontSize: 15,
                                  ),
                                )
                              : Text(
                                  'Delete Moment',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 15,
                                  ),
                                ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
