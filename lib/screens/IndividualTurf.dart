import 'dart:ui';

import 'package:fui_kit/fui_kit.dart';
import 'package:turf_arena/screens/BookingScreen.dart';
import 'package:turf_arena/screens/SuccessBook.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:turf_arena/constants.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class Individualturf extends StatefulWidget {
  Individualturf(this.details, this.userDetails);
  Map details;
  Map userDetails;

  @override
  State<Individualturf> createState() => _IndividualturfState();
}

class _IndividualturfState extends State<Individualturf> {
  bool isLiked = false;

  Future<void> addLike(String userId, String turfId) async {
    // Get a reference to the Firestore collection
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('users');

    // Reference the specific document
    // DocumentReference docRef = collectionRef.doc(documentId);

    try {
      // Get documents that match the condition
      QuerySnapshot querySnapshot =
          await collectionRef.where('uid', isEqualTo: userId).get();

      // Iterate through the matching documents
      for (var doc in querySnapshot.docs) {
        // Update each document
        await doc.reference.update({
          'liked': FieldValue.arrayUnion([turfId]),
        });
        print("Updated document: ${doc.id}");
        setState(() {
          isLiked = true;
          widget.userDetails['liked'].add(turfId);
        });
      }
    } catch (e) {
      print("Error updating documents: $e");
    }
  }

  Future<void> removeLike(String userId, String turfId) async {
    // Get a reference to the Firestore collection
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('users');

    // Reference the specific document
    // DocumentReference docRef = collectionRef.doc(documentId);

    try {
      // Get documents that match the condition
      QuerySnapshot querySnapshot =
          await collectionRef.where('uid', isEqualTo: userId).get();

      // Iterate through the matching documents
      for (var doc in querySnapshot.docs) {
        // Update each document
        await doc.reference.update({
          'liked': FieldValue.arrayRemove([turfId]),
        });
        print("Updated document: ${doc.id}");
        setState(() {
          isLiked = false;
          widget.userDetails['liked'].remove(turfId);
        });
      }
    } catch (e) {
      print("Error updating documents: $e");
    }
  }

  void launchGoogleMap(double lat, double lng) async {
    final Uri _url = Uri.parse(
        'google.navigation:q=${widget.details['latitude'].toString()},${widget.details['longitude'].toString()}');
    // final Uri _url = Uri.parse('google.navigation:q=10.729448,79.020248');
    final Uri fallbackUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${widget.details['latitude'].toString()},${widget.details['longitude'].toString()}');
    // var url = 'google.navigation:q=${lat.toString()},${lng.toString()}';

    // 'https://www.google.com/maps/search/?api=1&query=${lat.toString()},${lng.toString()}';
    try {
      bool launched =
          await launchUrl(_url, mode: LaunchMode.externalNonBrowserApplication);
      if (!launched) {
        await launchUrl(fallbackUrl,
            mode: LaunchMode.externalNonBrowserApplication);
      }
    } catch (e) {
      await launchUrl(fallbackUrl,
          mode: LaunchMode.externalNonBrowserApplication);
    }
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

  void checkIsLiked() {
    List<dynamic> liked = widget.userDetails['liked'];
    print(liked);
    liked.forEach((value) {
      if (value == widget.details['t_id']) {
        setState(() {
          isLiked = true;
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIsLiked();
    print(widget.userDetails);
    // print(widget.details['t_id']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: whiteColor,
      body: SafeArea(
        child: Container(
          // decoration: BoxDecoration(
          //   image: DecorationImage(
          //     alignment: Alignment.topCenter,
          //     fit: BoxFit.fitWidth,
          //     image: AssetImage("images/turf_bg1.png"),
          //   ),
          // ),
          height: double.infinity,
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    // transform: Matrix4.identity()..scale(1.2),
                    width: double.infinity,
                    // height: MediaQuery.of(context).size.height / 1.5,
                    decoration: BoxDecoration(
                        // color: Colors.green,
                        // image: DecorationImage(
                        //   image: AssetImage("images/turf_bg1.png"),
                        // ),
                        ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MyCarouselContainer(widget.details['imgList']),
                    ),
                    // child: Image(image: AssetImage("images/turf_bg1.png")),
                  ),
                  Positioned(
                    left: 25.0,
                    top: 40.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        30.0,
                      ),
                      child: BackdropFilter(
                        filter:
                            new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(
                          // backgroundColor: whiteColor,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(50.0),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.25),
                                spreadRadius: 2,
                                blurRadius: 7,
                                offset:
                                    Offset(0, 2), // changes position of shadow
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
                      ),
                    ),
                  ),
                  Positioned(
                    right: 25.0,
                    bottom: 20.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        30.0,
                      ),
                      child: BackdropFilter(
                        filter:
                            new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(
                          // backgroundColor: whiteColor,
                          decoration: BoxDecoration(
                            color: isLiked
                                ? whiteColor
                                : primaryColor.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(50.0),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.25),
                                spreadRadius: 2,
                                blurRadius: 7,
                                offset:
                                    Offset(0, 2), // changes position of shadow
                              ),
                            ],
                          ),
                          // radius: 25.0,
                          child: IconButton(
                            splashRadius: 35.0,
                            // color: Colors.red,
                            icon: FUI(
                              isLiked
                                  ? SolidRounded.HEART
                                  : RegularRounded.HEART,
                              width: 25.0,
                              height: 25.0,
                              color: isLiked ? greenColor : whiteColor,
                            ),

                            onPressed: () {
                              // Handle favorite action here
                              isLiked
                                  ? removeLike(
                                      widget.userDetails['uid'],
                                      widget.details['t_id'],
                                    )
                                  : addLike(
                                      widget.userDetails['uid'],
                                      widget.details['t_id'],
                                    );
                              HapticFeedback.mediumImpact();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 20.0,
                      right: 20.0,
                      top: 20.0,
                    ),
                    child: ListView(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      padding: EdgeInsets.zero,
                      children: [
                        Text(
                          widget.details['name'],
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(
                          widget.details['address'],
                          style: TextStyle(
                            color: greenColor,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Text(
                          "Description",
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(
                          widget.details['desc'],
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.0,
                          ),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Text(
                          "Dimensions",
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(
                          widget.details['breadth'].toString() +
                              " m X " +
                              widget.details['length'].toString() +
                              " m",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.0,
                          ),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Text(
                          "Sides",
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(
                          widget.details['side'].toString() + "s",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.0,
                          ),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Text(
                          "Timings",
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Container(
                          // width: 20.0,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(
                              12.0,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 6.0,
                              horizontal: 8.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.details['startTime'] +
                                      " - " +
                                      widget.details['endTime'],
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                BookingWidget(widget.details['amtPerHour']),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        // Text(
                        //   "₹ " + widget.details['amtPerHour'].toString(),
                        //   style: TextStyle(
                        //     color: primaryColor,
                        //     fontSize: 20.0,
                        //     fontWeight: FontWeight.w700,
                        //   ),
                        // ),
                        // Text(
                        //   "per hour",
                        //   style: TextStyle(
                        //     color: greyColor,
                        //     fontSize: 14.0,
                        //     fontWeight: FontWeight.w500,
                        //   ),
                        // ),
                        // BookingWidget(widget.details['amtPerHour']),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.grey[200],
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 15.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            IconButton(
                              style: IconButton.styleFrom(
                                  padding: EdgeInsets.all(
                                    8.0,
                                  ),
                                  backgroundColor: whiteColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  )),
                              onPressed: () {
                                // Navigator.push(context,
                                //     MaterialPageRoute(builder: (context) {
                                //   return SuccessfullyBooked();
                                // }));
                                launchGoogleMap(10.729448, 79.020248);
                              },
                              icon: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: FUI(
                                  SolidRounded.MARKER,
                                  width: 25.0,
                                  height: 25.0,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15.0,
                            ),
                            IconButton(
                                style: IconButton.styleFrom(
                                    padding: EdgeInsets.all(
                                      8.0,
                                    ),
                                    backgroundColor: whiteColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    )),
                                onPressed: () async {
                                  var url = widget.details['phone'];
                                  Uri uri = Uri(scheme: "tel", path: url);
                                  try {
                                    await launchUrl(uri);
                                  } catch (error) {
                                    throw 'Could not launch $url';
                                  }
                                },
                                icon: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: FUI(
                                    SolidRounded.PHONE_CALL,
                                    width: 25.0,
                                    height: 25.0,
                                    color: primaryColor,
                                  ),
                                )),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      Expanded(
                        flex: 4,
                        child: TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.all(12.0),
                              backgroundColor: greenColor,
                              // fixedSize: Size(
                              //   200.0,
                              //   40.0,
                              // ),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                _createRoute(
                                  BookingScreen(
                                      widget.details, widget.userDetails),
                                ),
                              );
                            },
                            child: Text(
                              "Book Slot",
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                color: whiteColor,
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookingWidget extends StatelessWidget {
  BookingWidget(this.amount);
  int amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 50.0,
      width: MediaQuery.of(context).size.width / 3,
      decoration: BoxDecoration(
          color: greenColor,
          borderRadius: BorderRadius.circular(
            8.0,
          )),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                height: 8.0,
                width: 5.0,
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(50.0),
                      bottomRight: Radius.circular(50.0),
                    )),
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                height: 8.0,
                width: 5.0,
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(50.0),
                      bottomRight: Radius.circular(50.0),
                    )),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "₹ " + amount.toString() + "/-",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: whiteColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "per hour",
                    style: TextStyle(
                      color: whiteColor,
                      fontSize: 13.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                height: 8.0,
                width: 5.0,
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50.0),
                      bottomLeft: Radius.circular(50.0),
                    )),
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                height: 8.0,
                width: 5.0,
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50.0),
                      bottomLeft: Radius.circular(50.0),
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MyCarouselContainer extends StatefulWidget {
  MyCarouselContainer(this.imgList);
  List<dynamic> imgList;
  @override
  _MyCarouselContainerState createState() => _MyCarouselContainerState();
}

class _MyCarouselContainerState extends State<MyCarouselContainer> {
  final List<String> stdImgList = [
    'images/turf_img.jpg',
    'images/football.png',
    'images/tennis_court.jpg',
  ];

  int _currentIndex = 0; // To keep track of the current index
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          // height: double.infinity,
          height: MediaQuery.of(context).size.height / 2.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40.0),
            color: whiteColor,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40.0),
            child: Stack(
              children: [
                CarouselSlider(
                  carouselController: _carouselController,
                  options: CarouselOptions(
                    height: double.infinity,
                    viewportFraction: 1.0,
                    autoPlay: true,
                    aspectRatio: MediaQuery.of(context).size.width /
                        MediaQuery.of(context).size.height,
                    enlargeCenterPage: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                  items: widget.imgList.isEmpty
                      ? stdImgList
                          .map((item) => Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(item),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ))
                          .toList()
                      : widget.imgList
                          .map((item) => Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(item),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ))
                          .toList(),
                ),
                Positioned(
                  bottom: 20.0,
                  left: 25.0,
                  // right: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40.0),
                    child: Container(
                      // width: 20.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40.0),
                        color: primaryColor.withOpacity(
                          0.45,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: (30.0 + 30.0 + 10.0 + 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: stdImgList.asMap().entries.map((img) {
                              return GestureDetector(
                                onTap: () =>
                                    _carouselController.animateToPage(img.key),
                                child: AnimatedContainer(
                                  duration: const Duration(
                                      milliseconds: 300), // Animation duration
                                  curve: Curves.easeInOut,
                                  width: _currentIndex == img.key ? 30.0 : 10.0,
                                  height: 10.0,
                                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                                  decoration: BoxDecoration(
                                    borderRadius: _currentIndex == img.key
                                        ? BorderRadius.circular(30.0)
                                        : BorderRadius.all(
                                            Radius.circular(50.0)),
                                    border: Border.all(
                                      color: _currentIndex == img.key
                                          ? whiteColor
                                          : Colors.grey.shade100,
                                      width: 1,
                                    ),
                                    color: _currentIndex == img.key
                                        ? whiteColor
                                        : greyColor,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
