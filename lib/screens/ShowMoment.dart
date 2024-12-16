import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:turf_arena/constants.dart';
import 'package:image_stickers/image_stickers.dart';
import 'package:image_stickers/image_stickers_controls_style.dart';
import 'package:share_plus/share_plus.dart';

class ShowMoment extends StatefulWidget {
  ShowMoment(this.image, this.selectedIndex);

  File? image;
  int selectedIndex;
  // GlobalKey<ImageEditorState> editorKey = GlobalKey();

  @override
  State<ShowMoment> createState() => _ShowMomentState();
}

class _ShowMomentState extends State<ShowMoment> {
  List<UISticker> stickers = [];
  List<Map> stickerList = [
    {
      "src": "images/sticker1.png",
    },
    {
      "src": "images/sticker1.png",
    },
    {
      "src": "images/sticker1.png",
    },
    {
      "src": "images/sticker1.png",
    },
    {
      "src": "images/sticker1.png",
    },
  ];

  late ImageStickersController controller;

  Uint64List? resultImage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    stickers.add(createSticker(0));
    controller = ImageStickersController();
  }

  UISticker createSticker(int index) {
    return UISticker(
      imageProvider: AssetImage(
        imgList[widget.selectedIndex],
      ),
      // x: 300 + 300.0 * index,
      x: 165,
      y: 300,
      size: 600.0,
      editable: false,
    );
  }

  // // Save Edited Image and Share
  // Future<void> _saveAndShare(_image) async {
  //   if (_image == null) return;

  //   // Save the edited image
  //   final imageBytes = await editorKey.currentState?.exportImage();
  //   if (imageBytes != null) {
  //     // Save the image to a temporary file
  //     final tempDir = await getTemporaryDirectory();
  //     final filePath = '${tempDir.path}/edited_image.png';
  //     final file = File(filePath)..writeAsBytesSync(imageBytes);

  //     // Share the file
  //     // Share.shareFiles([file.path], text: "Check out my Turf picture!");
  //   }
  // }

  final List<String> imgList = [
    'images/sticker1.png',
    'images/sticker2.png',
    'images/sticker3.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      body: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 40.0,
            horizontal: 30.0,
          ),
          child: Column(
            children: [
              // Padding(
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: 50.0,
              //     vertical: 20.0,
              //   ),
              //   child: Container(
              //     height: MediaQuery.of(context).size.height / 2,
              //     width: double.infinity,

              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(
              //         8.0,
              //       ),
              //       image: DecorationImage(
              //         fit: BoxFit.cover,
              //         // filterQuality: FilterQuality.high,
              //         image: Image.file(widget.image!).image,
              //       ),
              //     ),
              //     // Use FileImage if _image is a File
              //     child: widget.image == null
              //         ? Icon(
              //             Icons.person,
              //             size: 130.0,
              //           )
              //         : null,
              //   ),
              // ),
              widget.image != null
                  ? Expanded(
                      // height: MediaQuery.of(context).size.height / 1.3,
                      child: ImageStickers(
                        // key: editorKey,

                        backgroundImage: FileImage(
                          widget.image!,
                        ),
                        stickerList: stickers,
                        minStickerSize: 300.0,
                        maxStickerSize: 600.0,
                        stickerControlsStyle: ImageStickersControlsStyle(
                            color: Colors.blueGrey,
                            child: const Icon(
                              Icons.zoom_out_map,
                              color: Colors.white,
                            )),
                        controller: controller,
                        stickerControlsBehaviour:
                            StickerControlsBehaviour.alwaysHide,
                      ),
                    )
                  : Center(child: Text('No image captured yet')),

              TextButton(
                onPressed: () async {
                  var image = await controller.getImage();
                  var byteData =
                      await image.toByteData(format: ImageByteFormat.png);

                  if (byteData != null) {
                    final buffer = byteData.buffer;
                    final resultImage = buffer.asUint8List();

                    // Save the image to a temporary file
                    final tempDir = await getTemporaryDirectory();
                    final filePath = '${tempDir.path}/edited_image.png';
                    final file = File(filePath);
                    await file.writeAsBytes(resultImage); // Save in raw format

                    // Share the image using ShareXFiles
                    final result = await Share.shareXFiles(
                      [XFile(file.path)],
                      text: 'Great picture',
                    );

                    if (result.status == ShareResultStatus.success) {
                      print('Thank you for sharing my website!');
                    } else {
                      print('Error: ${result.status}');
                    }
                  } else {
                    print('Error: Unable to retrieve image data.');
                  }
                },
                child: const Text("Share Image"),
              ),
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
