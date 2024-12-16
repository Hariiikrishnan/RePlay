import 'dart:async';
import 'dart:io';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
  App(this.userDetails, this.cameras);
  Map userDetails;
  final List<CameraDescription> cameras;

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
  }

  File? _image;

  // Future<void> _initUniLinks() async {
  //   // Listen for incoming links
  //   _sub = uriLinkStream.listen((Uri? uri) {
  //     if (uri != null) {
  //       _handleIncomingLink(uri);
  //     }
  //   }, onError: (Object err) {
  //     // Handle exception by warning the user their action did not succeed
  //     print('Error: $err');
  //   });

  //   // Handle app being opened with a link initially
  //   final initialUri = await getInitialUri();
  //   if (initialUri != null) {
  //     _handleIncomingLink(initialUri);
  //   }
  // }

  // void _handleIncomingLink(Uri uri) {
  //   // Handle the deep link
  //   print('Received link: ${uri.toString()}');
  //   Navigator.push(context, MaterialPageRoute(builder: (context) {
  //     return AcceptInviteScreen(uri.toString());
  //   }));
  //   // Navigate to a specific page or perform any action based on the link
  // }

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
                    selectedIcon: Icon(
                      Icons.home,
                      size: 25.0,
                      color: greenColor,
                    ),
                    icon: Icon(
                      size: 25.0,
                      Icons.home_outlined,
                      color: Colors.grey,
                    ),
                    label: '',
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: 40.0,
                    ),
                    child: NavigationDestination(
                      selectedIcon: Icon(
                        Icons.confirmation_number_rounded,
                        size: 25.0,
                        color: greenColor,
                      ),
                      icon: Icon(
                        size: 25.0,
                        Icons.confirmation_number_outlined,
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
                      selectedIcon: Icon(
                        Icons.favorite_rounded,
                        size: 25.0,
                        color: greenColor,
                        // Icons.notifications,
                      ),
                      icon: Icon(
                        Icons.favorite_outline_outlined,
                        size: 25.0,
                        // Icons.notifications_outlined,
                        color: Colors.grey,
                      ),
                      label: '',
                    ),
                  ),
                  NavigationDestination(
                    selectedIcon: Icon(
                      Icons.account_circle,
                      size: 25.0,
                      color: greenColor,
                      // Icons.notifications,
                    ),
                    icon: Icon(
                      Icons.account_circle_outlined,
                      size: 25.0,
                      // Icons.notifications_outlined,
                      color: Colors.grey,
                    ),
                    label: '',
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: Offset(0, -40),
              child: Transform.scale(
                scale: 1.4,
                child: GestureDetector(
                  onTap: () {
                    print("Call Camera");
                    // final image = await ImagePicker().pickImage(
                    //   source: ImageSource.camera,
                    //   maxHeight: 640,
                    //   maxWidth: 640,
                    // );
                    // if (image != null) {
                    //   setState(() {
                    //     _image = File(image.path);
                    //   });
                    // }
                    // Navigator.of(context)
                    // .push(_createRoute(CameraApp(cameras: widget.cameras)));
                  },
                  child: Container(
                    // transform: Matrix4.translation(1),

                    decoration: BoxDecoration(
                      // border: BoxBorder.lerp(a, b, t),
                      border: Border.all(
                        color: Colors.white,
                        width: 3.5,
                      ),
                      image: DecorationImage(
                        fit: BoxFit.fitWidth,
                        image: AssetImage(
                          "images/cock.jpg",
                        ),
                      ),
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(100.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: secondaryColor.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),

                    height: 60.0,
                    width: 60.0,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: [
          // Center(
          //   child: Container(
          //     child: Text("1"),
          //   ),
          // ),
          HomeScreen(widget.userDetails),
          MyBookings(widget.userDetails),
          TurfsList("Favorites", widget.userDetails),
          Profilescreen(widget.userDetails)
        ][currentPageIndex]);
  }
}

// class _HomeScreenState extends State<HomeScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         // margin: EdgeInsets.symmetric(
//         //   vertical: 50.0,
//         // ),
//         children: [
//           BottomNavigationBar(
//             backgroundColor: Colors.transparent,
//             showUnselectedLabels: true,
//             type: BottomNavigationBarType.fixed,
//             elevation: 0,
//             items: [
//               BottomNavigationBarItem(
//                 backgroundColor: Colors.red,
//                 icon: Icon(Icons.home),
//                 label: '',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.local_activity),
//                 label: '',
//               ),
//               BottomNavigationBarItem(
//                 icon: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.black,
//                   ),
//                   height: 100.0,
//                   width: 50.0,
//                   child: ModelViewer(
//                     disableTap: false,
//                     // backgroundColor: Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
//                     src: 'assets/football.glb',
//                     alt: 'A 3D model of an astronaut',
//                     ar: false,
//                     autoRotate: false,

//                     // iosSrc: 'https://modelviewer.dev/shared-assets/models/Astronaut.usdz',
//                     disableZoom: true,
//                   ),
//                 ),
//                 label: '',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.inbox),
//                 label: '',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.person),
//                 label: '',
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// Container(
//               height: 170.0,
//               color: Colors.red,
//               child: Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Container(
//                   decoration: BoxDecoration(
//                       color: Colors.black,
//                       borderRadius: BorderRadius.circular(80.0)),
//                   height: 100.0,
//                   width: 100.0,
//                   child: ModelViewer(
//                     disableTap: true,
//                     // backgroundColor: Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
//                     src: 'assets/football.glb',
//                     alt: 'A 3D model of an astronaut',
//                     ar: false,
//                     autoRotate: false,
//                     autoPlay: false,
//                     disablePan: true,

//                     // iosSrc: 'https://modelviewer.dev/shared-assets/models/Astronaut.usdz',
//                     disableZoom: true,
//                   ),
//                 ),
//               ),
//             ),

// late List<CameraDescription> _cameras;

/// CameraApp is the Main Application.
class CameraApp extends StatefulWidget {
  /// Default Constructor
  const CameraApp({super.key, required this.cameras});
  final List<CameraDescription> cameras;

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;
  late XFile? imageFile;

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
    controller = CameraController(widget.cameras[0], ResolutionPreset.max);
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
              ShowMoment(File(imageFile!.path), _currentIndex),
        ),
      );
    } catch (e) {
      print("Error taking picture: $e");
    }
  }

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.of(context).size;
    final scale = 1 / (controller.value.aspectRatio * mediaSize.aspectRatio);

    if (!controller.value.isInitialized) {
      return Container();
    }
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
                          scale: scale - 0.4,
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
                        child: Image.asset(
                          opacity: const AlwaysStoppedAnimation(.9),
                          imgList[_currentIndex],
                          fit: BoxFit.cover,
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
                height: 150.0,
                width: double.infinity,
                child: Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MyCarouselContainer((index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        }),
                      ),
                      Container(
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
  MyCarouselContainer(this.callback);

  Function callback;
  @override
  _MyCarouselContainerState createState() => _MyCarouselContainerState();
}

class _MyCarouselContainerState extends State<MyCarouselContainer> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          // height: double.infinity,
          height: 40.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40.0),
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
                widget.callback(index);
              },
            ),
            items: imgList
                .map((item) => Container(
                      height: 35.0,
                      width: 35.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(item),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ))
                .toList(),
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
