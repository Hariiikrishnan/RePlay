import 'dart:async';
import 'dart:io';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:fui_kit/fui_kit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:turf_arena/screens/MyBookings.dart';
import 'package:turf_arena/screens/ShowMoment.dart';
import 'package:turf_arena/screens/TurfsList.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:turf_arena/constants.dart';
import 'package:turf_arena/screens/HomeScreen.dart';
import 'package:turf_arena/screens/Profilescreen.dart';

import 'package:camera/camera.dart';

class App extends StatefulWidget {
  App(this.userDetails, this.cameras, this.alt);
  Map userDetails;
  final List<CameraDescription> cameras;
  final String alt;

  @override
  State<App> createState() => _AppState();
}

var currentPageIndex = 0;

class _AppState extends State<App> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    // _initUniLinks();
    print(widget.userDetails);
    // if (widget.alt == "0.0,0.0") {
    //   showAlertDialog(context);
    // }
  }

  File? _image;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
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
        // extendBody: true,

        backgroundColor: whiteColor,
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              // alignment: AlignmentDirectional.topStart,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50.0),
                topRight: Radius.circular(50.0),
              ),
              child: NavigationBar(
                onDestinationSelected: (int index) {
                  setState(() {
                    currentPageIndex = index;

                    print(index);
                  });
                },
                labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                // indicatorShape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(62.0)),

                backgroundColor: primaryColor,
                indicatorColor: primaryColor,
                height: 70.0,
                selectedIndex: currentPageIndex,
                destinations: [
                  NavigationDestination(
                    // selectedIcon: Icon(
                    //   Icons.home,

                    //   // Icons.home,
                    //   size: 25.0,
                    //   color: greenColor,
                    // ),
                    selectedIcon: FUI(
                      SolidRounded.HOME,
                      width: 22.0,
                      height: 22.0,
                      color: greenColor,
                    ),
                    icon: FUI(
                      RegularRounded.HOME,
                      width: 20.0,
                      height: 20.0,
                      color: Colors.grey,
                    ),
                    // icon: Icon(
                    //   size: 25.0,
                    //   Icons.home_outlined,
                    //   color: Colors.grey,
                    // ),
                    label: '',
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: 40.0,
                    ),
                    child: NavigationDestination(
                      selectedIcon: FUI(
                        SolidRounded.TICKET,
                        width: 22.0,
                        height: 22.0,
                        color: greenColor,
                      ),
                      icon: FUI(
                        RegularRounded.TICKET,
                        width: 20.0,
                        height: 20.0,
                        color: Colors.grey,
                      ),
                      label: '',
                    ),
                  ),
                  // Spacer(
                  //   flex: 1,
                  // ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 40.0,
                    ),
                    child: NavigationDestination(
                      selectedIcon: FUI(
                        SolidRounded.HEART,
                        width: 22.0,
                        height: 22.0,
                        color: greenColor,
                      ),
                      icon: FUI(
                        RegularRounded.HEART,
                        width: 20.0,
                        height: 20.0,
                        color: Colors.grey,
                      ),
                      label: '',
                    ),
                  ),
                  NavigationDestination(
                    selectedIcon: FUI(
                      SolidRounded.USER,
                      width: 22.0,
                      height: 22.0,
                      color: greenColor,
                    ),
                    icon: FUI(
                      RegularRounded.USER,
                      width: 20.0,
                      height: 20.0,
                      color: Colors.grey,
                    ),
                    label: '',
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: Offset(0, -25),
              child: Transform.scale(
                scale: 1.2,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(_createRoute(CameraApp(
                        cameras: widget.cameras,
                        userData: widget.userDetails)));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                        width: 2.5,
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Color(0XFF0ccda3),
                          Color(0XFFc1fcd3),
                        ],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        stops: [0.1, 0.6],
                        tileMode: TileMode.repeated,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(100.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    height: 60.0,
                    width: 60.0,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: FUI(
                        SolidRounded.CAMERA,
                        height: 50.0,
                        color: primaryColor,
                        // color: Color(0XFFff8c21),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: [
          HomeScreen(widget.userDetails, widget.alt),
          MyBookings(widget.userDetails),
          TurfsList("Favorites", widget.userDetails),
          Profilescreen(widget.userDetails, widget.cameras, widget.alt)
        ][currentPageIndex]);
  }
}

/// CameraApp is the Main Application.

class CameraApp extends StatefulWidget {
  /// Default Constructor
  const CameraApp({super.key, required this.cameras, required this.userData});
  final List<CameraDescription> cameras;
  final Map userData;

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  // CameraController controller = CameraController(description, resolutionPreset);
  late CameraController controller;
  late XFile? imageFile;
  bool isFront = false;

  void requestStoragePermission() async {
    // Check if the platform is not web, as web has no permissions
    if (Platform.isAndroid || Platform.isIOS) {
      // Request storage permission
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }

      // Request camera permission
      var cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted) {
        await Permission.camera.request();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    requestStoragePermission();

    controller = CameraController(widget.cameras[0], ResolutionPreset.veryHigh);

    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
    // initialization();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _takePicture() async {
    try {
      final XFile picture = await controller.takePicture();
      setState(() {
        imageFile = picture;
      });
      // Navigate to the image view page after capturing the image
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ShowMoment(File(imageFile!.path), currentUrl, widget.userData),
        ),
      );
    } catch (e) {
      print("Error taking picture: $e");
    }
  }

  int _currentIndex = 0;

  String currentUrl = "images/sticker1.png";

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      print(true);
      return Scaffold(
        backgroundColor: primaryColor.withOpacity(0.2),
        body: Center(
            child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20.0,
            children: [
              Icon(
                Icons.camera,
                size: 200.0,
                color: whiteColor,
              ),
              Text(
                "Re Play Moments",
                style: TextStyle(
                  color: whiteColor,
                  fontSize: 17.0,
                ),
              )
            ],
          ),
        )), // Show a loading indicator
      );
    }
    final mediaSize = MediaQuery.of(context).size;
    final scale = 1 / (controller.value.aspectRatio * mediaSize.aspectRatio);
    return Scaffold(
      body: Container(
        color: primaryColor,
        height: double.infinity,
        width: double.infinity,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    color: primaryColor,
                    // height: MediaQuery.of(context).size.height / 2,
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: ClipRect(
                        clipper: _MediaSizeClipper(mediaSize),
                        child: Transform.scale(
                          scale: scale - 0.17,
                          // scale:
                          //     scale - MediaQuery.of(context).size.width / 2000,
                          alignment: Alignment.topCenter,
                          child: CameraPreview(
                            controller,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    // alignment: Alignment.center,

                    child: Container(
                      // opacity: 0.5,
                      // decoration: BoxDecoration(color: primaryColor),
                      height: MediaQuery.of(context).size.height / 2,
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Transform.scale(
                          scale: 0.85,
                          child: Image.asset(
                            opacity: const AlwaysStoppedAnimation(.9),
                            currentUrl,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: primaryColor,
                height: 180.0,
                width: double.infinity,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                        ),
                        child: MyCarouselContainer((url) {
                          setState(() {
                            currentUrl = url;
                          });
                        }, _currentIndex),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 70.0,
                          ),
                          Center(
                            child: Container(
                              // height: 75.0,
                              // width: 30.0,
                              decoration: BoxDecoration(
                                  color: greyColor,
                                  border: Border.all(
                                    width: 2.0,
                                    color: whiteColor,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    30.0,
                                  )),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: FloatingActionButton(
                                  onPressed: () {
                                    _takePicture(); // Call method to take picture
                                  },
                                  child: Icon(
                                    Icons.camera,
                                    size: 35.0,
                                  ),
                                  backgroundColor: Colors.grey[100],
                                  foregroundColor: greenColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                    30.0,
                                  )),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  // vertical: 5.0,
                                ),
                                child: Container(
                                  child: IconButton(
                                    onPressed: () {
                                      // Dispose of the existing controller if it's initialized
                                      HapticFeedback.mediumImpact();
                                      controller?.dispose();
                                      if (!isFront) {
                                        setState(() {
                                          controller = CameraController(
                                            widget.cameras[
                                                1], // Access the second camera directly
                                            ResolutionPreset.veryHigh,
                                          );
                                          isFront = true;
                                        });
                                      } else {
                                        setState(() {
                                          controller = CameraController(
                                            widget.cameras[
                                                0], // Access the second camera directly
                                            ResolutionPreset.veryHigh,
                                          );
                                          isFront = false;
                                        });
                                      }
                                      // Initialize the controller and handle any errors
                                      controller?.initialize().then((_) {
                                        setState(() {});
                                      }).catchError((e) {
                                        print('Error initializing camera: $e');
                                      });
                                    },
                                    icon: Icon(
                                      Icons.flip_camera_ios_rounded,
                                      color: whiteColor,
                                      size: 25.0,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 5.0,
                              ),
                            ],
                          ),
                        ],
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

final List<String> imgList = [
  'images/sticker1.png',
  'images/sticker2.png',
  'images/sticker3.png',
];
// To keep track of the current index

class MyCarouselContainer extends StatefulWidget {
  MyCarouselContainer(this.callback, this.currentIndex);

  Function callback;
  int currentIndex;
  @override
  _MyCarouselContainerState createState() => _MyCarouselContainerState();
}

class _MyCarouselContainerState extends State<MyCarouselContainer> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  int currentIndex = 0;
  bool _isAnimating = false;

  void _handleTap(int index) async {
    if (_isAnimating) return; // Prevent multiple taps during animation
    setState(() {
      _isAnimating = true;
    });
    await _carouselController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      currentIndex = index; // Update index after animation completes
      _isAnimating = false;
    });
    widget.callback(imgList[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          // height: double.infinity,
          height: 60.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0.0),
            // color: Colors.white,
          ),
          child: CarouselSlider(
            carouselController: _carouselController,
            options: CarouselOptions(
              enableInfiniteScroll: false,
              height: double.infinity,
              viewportFraction: 0.2,
              // autoPlay: true,
              // // aspectRatio: MediaQuery.of(context).size.width /
              // //     MediaQuery.of(context).size.height,
              // enlargeCenterPage: false,
              onPageChanged: (index, reason) {
                // setState(() {
                //   currentIndex = index;
                // });
                // widget.callback(imgList[index]);
                if (!_isAnimating) {
                  setState(() {
                    currentIndex = index;
                  });
                  widget.callback(imgList[index]);
                }
              },
            ),
            items: imgList.asMap().entries.map((entry) {
              int index = entry.key;
              String item = entry.value;
              return GestureDetector(
                onTap: () => _handleTap(index),
                // onTap: () {
                //   setState(() {
                //     currentIndex = index;
                //   });
                //   _carouselController.animateToPage(
                //     index,
                //     duration: Duration(milliseconds: 500), // Animation duration
                //     curve: Curves.easeInOut,
                //   );
                //   widget.callback(item);
                // },
                child: Container(
                  height: currentIndex == index ? 58.0 : 25.0,
                  width: currentIndex == index ? 50.0 : 25.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(item),
                      fit:
                          currentIndex == index ? BoxFit.cover : BoxFit.contain,
                    ),
                    border: Border.all(
                      color: currentIndex == index
                          ? Colors.white
                          : Colors.transparent,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              );
            }).toList(),
            // items: imgList
            //     .map((item) => GestureDetector(
            //           onTap: () {
            //             widget.callback();
            //           },
            //           child: Container(
            //             height: 35.0,
            //             width: 35.0,
            //             decoration: BoxDecoration(
            //               image: DecorationImage(
            //                 image: AssetImage(item),
            //                 fit: BoxFit.cover,
            //               ),
            //             ),
            //           ),
            //         ))
            //     .toList(),
          ),
        ),
      ],
    );
  }
}

class _MediaSizeClipper extends CustomClipper<Rect> {
  final Size mediaSize;
  const _MediaSizeClipper(this.mediaSize);
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, mediaSize.width, mediaSize.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}
