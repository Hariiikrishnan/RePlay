import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fui_kit/fui_kit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:turf_arena/screens/BookingScreen.dart';
import 'package:turf_arena/screens/IndividualTurf.dart';
import 'package:turf_arena/screens/NearbyList.dart';
import 'package:turf_arena/screens/TurfsList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:turf_arena/constants.dart';
import 'components/ProfileHeader.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen(this.userDetails, this.alt);
  Map userDetails;
  String alt;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

Route _createRoute(Widget ScreenName) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ScreenName,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

class _HomeScreenState extends State<HomeScreen> {
  late Map respData;

  late double latitude;
  late double longitude;

  void getLocationData() async {
    await getNearby();
  }

  List<String> names = [];

  Future<void> getNearby() async {
    print("calling nearby");

    try {
      print(widget.alt);
      if (widget.alt != "0.0,0.0") {
        HttpsCallable callable =
            FirebaseFunctions.instance.httpsCallable("getNearby");
        dynamic response = await callable.call({
          // 'alt': "10.897774, 79.022481",
          'alt': widget.alt,
        });
        print(response.data);
        print(response.data['results'].length);
        if (response.data['results'].length > 0) {
          setState(() {
            respData = response.data;
            loadingNearby = false;
          });
          print(respData);
          print(respData['results'].length);
        } else {
          setState(() {
            isEmpty = true;
            loadingNearby = false;
          });
        }

        !isEmpty ? getNearbyTurfs() : null;
      } else {
        setState(() {
          print("No access");
          loadingNearby = false;
          isNoAccess = true;
        });
        // showAlertDialog(context);
      }
    } on FirebaseFunctionsException catch (e) {
      // Do clever things with e
      print(e.toString());
      setState(() {
        // paymentData = resp.data;
        loadingNearby = false;
      });
    } catch (e) {
      // Do other things that might be thrown that I have overlooked
      print(e.toString());
      setState(() {
        // paymentData = resp.data;
        loadingData = false;
      });
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

  void getNearbyTurfs() {
    // print("calling");
    // print(respData["results"][0]['name']);
    // respData['results'].map((item) {
    //   print(item);
    // });
    names = [];
    print(respData.length);
    for (int i = 0; i < respData['results'].length; i++) {
      print(respData['results'][i]['name']);
      names.add(respData['results'][i]['name']);
    }
    print(names);
    print(names.length);
    _loadMoreData(names);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocationData();
  }

  List<Map<String, dynamic>> nearbyList = [];
  List<Map<String, dynamic>> courtsList = [
    {
      'name': 'Cricket',
      'src':
          "https://firebasestorage.googleapis.com/v0/b/turf-arena.firebasestorage.app/o/assets%2Fcricket.png?alt=media&token=922659d1-f406-4a1e-8acf-4867fb0e047a",
    },
    {
      'name': 'Football',
      'src':
          "https://firebasestorage.googleapis.com/v0/b/turf-arena.firebasestorage.app/o/assets%2Ffootball.png?alt=media&token=e92a41e4-4f72-4f23-b48d-c27e05a7733f",
    },
    {
      'name': 'Badminton',
      'src':
          "https://firebasestorage.googleapis.com/v0/b/turf-arena.firebasestorage.app/o/assets%2Fbadminton_court.jpg?alt=media&token=9dc4f38b-fb40-4934-a4af-92a5dd3357b6",
    },
    {
      'name': 'Tennis',
      'src':
          "https://firebasestorage.googleapis.com/v0/b/turf-arena.firebasestorage.app/o/assets%2Ftennis_court.jpg?alt=media&token=b75f0e08-c9ed-4e5f-8e0c-0e0db76ca087",
    },
    {
      'name': 'Other Turfs',
      'src':
          "https://firebasestorage.googleapis.com/v0/b/turf-arena.firebasestorage.app/o/assets%2Fturf_img.jpg?alt=media&token=2c1e98e6-06f8-4b77-b773-356265546339",
    },
  ];

  bool loadingNearby = true;
  bool loadingData = true;
  bool isEmpty = false;
  bool isNoAccess = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // List<DocumentSnapshot> _documents = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _documentLimit = 4; // Number of documents to fetch per page
  DocumentSnapshot? _lastDocument; // To keep track of the last fetched document
  late ScrollController _scrollController = ScrollController();

  Future<void> fetchNearby(List names) async {
    print(names);
    CollectionReference turfs = FirebaseFirestore.instance.collection('turfs');

    Query query = turfs.where('name', whereIn: names).limit(4);

    try {
      QuerySnapshot snapshot = await query.get();

      // if (_lastDocument == null && snapshot.docs.length == 0) {
      //   setState(() {
      //     isEmpty = true;
      //   });
      // // }

      // if (snapshot.docs.length < _documentLimit) {
      //   _hasMore = false; // No more documents to load
      // // }

      // _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      print(snapshot.docs);
      if (snapshot.docs.length == 0) {
        setState(() {
          loadingData = false;
          isEmpty = true;
        });
      } else {
        setState(() {
          loadingData = false;
          snapshot.docs.forEach((doc) {
            nearbyList.add(doc.data() as Map<String, dynamic>);
          });
        });
        print("Here");
        print(nearbyList);
      }
    } catch (error) {
      print("Error getting documents: $error");
    }
  }

  Future<void> _loadMoreData(List names) async {
    if (_isLoading || !_hasMore) return; // Prevent duplicate loading

    setState(() {
      _isLoading = true;
    });

    await fetchNearby(names); // Your existing data fetch method

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Dhanush Turf"),
      // ),

      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: primaryColor,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 30.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileHeader(widget.userDetails, whiteColor),
                  SizedBox(
                    height: 15.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10.0,
                      // right: 35.0,
                      // top: 55.0,
                    ),
                    child: Container(
                      child: Row(
                        children: [
                          Text(
                            "Rekindle Your Passion for ",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                              fontSize: 18.0,
                            ),
                          ),
                          Text(
                            "Play.",
                            style: TextStyle(
                              color: greenColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 20.0,
                            ),
                          ),
                        ],
                      ),
                      // child: Row(
                      //   children: [
                      //     Text(
                      //       "Play.",
                      //       style: TextStyle(
                      //         color: Colors.grey[300],
                      //         fontWeight: FontWeight.w600,
                      //         fontSize: 22.0,
                      //       ),
                      //     ),
                      //     Text(
                      //       " Relive.",
                      //       style: TextStyle(
                      //         color: Colors.grey[500],
                      //         fontWeight: FontWeight.w600,
                      //         fontSize: 22.0,
                      //       ),
                      //     ),
                      //     Text(
                      //       " Cherish.",
                      //       style: TextStyle(
                      //         color: Colors.grey[600],
                      //         fontWeight: FontWeight.w600,
                      //         fontSize: 22.0,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // child: TextField(
                      //   style: TextStyle(
                      //     color: whiteColor,
                      //   ),
                      //   onSubmitted: (value) {
                      //     Navigator.of(context).push(
                      //       _createRoute(
                      //         TurfsList(value, widget.userDetails),
                      //       ),
                      //     );
                      //   },
                      //   textInputAction: TextInputAction.search,
                      //   decoration: kTextFieldDecoration,
                      // ),
                      // decoration: BoxDecoration(
                      //   color: primaryColor,
                      //   borderRadius: BorderRadius.circular(30.0),
                      //   // backgroundBlendMode: BlendMode.screen,
                      //   border: Border.all(
                      //     width: 1.0,
                      //     color: whiteColor,
                      //   ),
                      //   image: DecorationImage(
                      //     fit: BoxFit.cover,
                      //     opacity: 0.6,
                      //     image: AssetImage(
                      //       "images/grass_bg.jpg",
                      //     ),
                      //   ),
                      // ),
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                ],
              ),
            ),
            Expanded(
              // flex: 4,
              child: Container(
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50.0),
                      topRight: Radius.circular(50.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 10.0,
                      bottom: 40.0,
                      // left: 30.0,
                      // right: 30.0,
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 25.0,
                                ),
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Near You",
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontSize: 17.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          (loadingNearby || isNoAccess)
                                              ? null
                                              : isEmpty
                                                  ? null
                                                  : Navigator.of(context).push(
                                                      _createRoute(
                                                        Nearbylist(
                                                          names,
                                                          widget.userDetails,
                                                        ),
                                                      ),
                                                    );
                                        },
                                        child: Text(
                                          "See All",
                                          style: TextStyle(
                                            color: (loadingNearby || isNoAccess)
                                                ? greyColor
                                                : isEmpty
                                                    ? greyColor
                                                    : greenColor,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: loadingNearby
                                    ? SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            Skeletonizer(
                                              enabled: true,
                                              enableSwitchAnimation: true,
                                              child: NearbyTile({
                                                'name': "Lorem Ipsum",
                                                'src': 'images/grass.jpg',
                                              }, widget.userDetails),
                                            ),
                                            Skeletonizer(
                                              enabled: true,
                                              enableSwitchAnimation: true,
                                              child: NearbyTile({
                                                'name': "Lorem Ipsum",
                                                'src': 'images/grass.jpg',
                                              }, widget.userDetails),
                                            ),
                                          ],
                                        ),
                                      )
                                    : isNoAccess
                                        ? Container(
                                            height: 120.0,
                                            width: double.infinity,
                                            child: Column(
                                              children: [
                                                Expanded(
                                                  flex: 3,
                                                  child: FUI(
                                                    RegularRounded
                                                        .MAP_MARKER_CROSS,
                                                    height: 75.0,
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    "Kindly enable location access and try again.",
                                                    style: TextStyle(
                                                      color: primaryColor,
                                                      fontSize: 16.0,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : isEmpty
                                            ? Container(
                                                height: 150.0,
                                                width: double.infinity,
                                                child: Column(
                                                  children: [
                                                    Expanded(
                                                      flex: 3,
                                                      child: CachedNetworkImage(
                                                        placeholder:
                                                            (context, url) =>
                                                                Skeletonizer(
                                                          child: SizedBox(
                                                            width: 150.0,
                                                            height: 150.0,
                                                          ),
                                                        ),
                                                        imageUrl:
                                                            "https://firebasestorage.googleapis.com/v0/b/turf-arena.firebasestorage.app/o/assets%2Fnoturfs.gif?alt=media&token=a1acbf91-7f85-43ce-9427-293fb511edab",
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Text(
                                                        "No nearby turfs found.",
                                                        style: TextStyle(
                                                          color: primaryColor,
                                                          fontSize: 16.0,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : ListView.builder(
                                                // controller: _scrollController,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                physics:
                                                    AlwaysScrollableScrollPhysics(),
                                                itemCount: loadingNearby
                                                    ? nearbyList.length + 1
                                                    : nearbyList.length,
                                                itemBuilder: (context, index) {
                                                  // if (index < nearbyList.length) {
                                                  //   // Replace with your booking item widget
                                                  return NearbyTile(
                                                      nearbyList[index],
                                                      widget.userDetails);
                                                  // } else if (loadingNearby) {
                                                  //   return Skeletonizer(
                                                  //     enabled: true,
                                                  //     enableSwitchAnimation: true,
                                                  //     child: NearbyTile({
                                                  //       'name': "Lorem Ipsum",
                                                  //       'src': 'images/grass.jpg',
                                                  //     }, widget.userDetails),
                                                  //   );
                                                  // }
                                                },
                                              ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 25.0,
                                ),
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Games",
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontSize: 17.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      // GestureDetector(
                                      //   onTap: () {},
                                      //   child: Text(
                                      //     "See All",
                                      //     style: TextStyle(
                                      //       color: greenColor,
                                      //       fontSize: 15.0,
                                      //       fontWeight: FontWeight.w600,
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  // controller: _scrollController,
                                  scrollDirection: Axis.horizontal,
                                  physics: AlwaysScrollableScrollPhysics(),
                                  itemCount: courtsList.length,
                                  itemBuilder: (context, index) {
                                    return SportsTile(
                                        courtsList[index], widget.userDetails);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class SportsTile extends StatelessWidget {
  SportsTile(this.turfDetails, this.userDetails);

  Map userDetails;
  Map turfDetails;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20.0,
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            _createRoute(
              TurfsList(
                turfDetails['name'],
                userDetails,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(
                30.0,
              )),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                Container(
                  // height: 250.0,
                  width: MediaQuery.of(context).size.width - 200,
                  decoration: BoxDecoration(
                    // color: Colors.red,
                    borderRadius: BorderRadius.circular(
                      24.0,
                    ),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      // image: AssetImage(turfDetails['src']),
                      image: turfDetails['src'] == null
                          ? AssetImage(
                              "images/grass.jpg",
                            )
                          : CachedNetworkImageProvider(
                              turfDetails['src'],
                            ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: BackdropFilter(
                        filter:
                            new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(
                          height: 40.0,
                          width: MediaQuery.of(context).size.width - 216,
                          decoration: BoxDecoration(
                              color: primaryColor.withOpacity(
                                0.25,
                              ),
                              borderRadius: BorderRadius.circular(
                                20.0,
                              )),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                turfDetails['name'],
                                style: TextStyle(
                                  color: whiteColor,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Icon(
                                Icons.north_east_rounded,
                                color: whiteColor,
                                size: 17.0,
                              ),
                            ],
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
      ),
    );
  }
}

class NearbyTile extends StatelessWidget {
  NearbyTile(this.turfDetails, this.userDetails);

  Map userDetails;
  Map turfDetails;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20.0,
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            _createRoute(
              Individualturf(
                turfDetails,
                userDetails,
              ),
            ),
          );
        },
        child: Container(
          child: Stack(
            children: [
              Container(
                // height: 250.0,
                width: MediaQuery.of(context).size.width - 150,
                decoration: BoxDecoration(
                  // color: Colors.red,
                  borderRadius: BorderRadius.circular(
                    30.0,
                  ),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    // image: AssetImage(turfDetails['src']),
                    image: turfDetails['imgList'] == null
                        ? AssetImage(
                            "images/grass.jpg",
                          )
                        : CachedNetworkImageProvider(
                            turfDetails['imgList'][0],
                          ),
                    // : Image.network(
                    //     turfDetails['imgList'][0],
                    //     loadingBuilder: (BuildContext context, Widget child,
                    //         ImageChunkEvent? loadingProgress) {
                    //       if (loadingProgress == null) {
                    //         return child; // Image is fully loaded
                    //       }
                    //       return Skeletonizer(
                    //         enabled: true,
                    //         enableSwitchAnimation: true,
                    //         child: ClipRRect(
                    //           borderRadius: BorderRadius.circular(16.0),
                    //           child: Container(
                    //             height: double.maxFinite,
                    //             width: 160.0,
                    //             color: greyColor,
                    //           ),
                    //         ),
                    //       );
                    //     },
                    //     errorBuilder: (BuildContext context, Object error,
                    //         StackTrace? stackTrace) {
                    //       return Icon(Icons.error,
                    //           color: Colors.red, size: 50);
                    //     },
                    //   ).image,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: BackdropFilter(
                      filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        height: 50.0,
                        width: MediaQuery.of(context).size.width - 166,
                        decoration: BoxDecoration(
                            color: primaryColor.withOpacity(
                              0.25,
                            ),
                            borderRadius: BorderRadius.circular(
                              20.0,
                            )),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              turfDetails['name'],
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 17.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              Icons.north_east_rounded,
                              color: whiteColor,
                            ),
                          ],
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
    );
  }
}
