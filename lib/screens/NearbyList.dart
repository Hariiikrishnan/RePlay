import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:turf_arena/constants.dart';
import 'package:turf_arena/screens/IndividualTurf.dart';
import 'package:turf_arena/screens/components/ProfileHeader.dart';

class Nearbylist extends StatefulWidget {
  Nearbylist(this.names, this.userDetails);
  final Map userDetails;
  List<String> names;

  @override
  State<Nearbylist> createState() => _NearbylistState();
}

class _NearbylistState extends State<Nearbylist> {
  List<Map<String, dynamic>> upcomingList = [];

  bool loadUpcoming = true;

  bool isUpcomingEmpty = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // List<DocumentSnapshot> _documents = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _documentLimit = 4; // Number of documents to fetch per page
  DocumentSnapshot? _lastDocument; // To keep track of the last fetched document
  late ScrollController _scrollController = ScrollController();

  Timestamp now = Timestamp.fromDate(DateTime.now());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.userDetails);
    _scrollController.addListener(() {
      print("Scrolling position: ${_scrollController.position.pixels}");
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading &&
          _hasMore) {
        _loadMoreData();
        print("Loading more data...");
      }
    });

    widget.names.isNotEmpty ? _loadMoreData() : null;
  }

  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMore) return; // Prevent duplicate loading

    setState(() {
      _isLoading = true;
    });

    await fetchUpComing(); // Your existing data fetch method

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> fetchUpComing() async {
    CollectionReference turfs = FirebaseFirestore.instance.collection('turfs');
    Query query =
        turfs.where('name', whereIn: widget.names).limit(_documentLimit);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    try {
      QuerySnapshot snapshot = await query.get();
      print(snapshot.docs.isEmpty);
      if (_lastDocument == null && snapshot.docs.isEmpty) {
        setState(() {
          isUpcomingEmpty = true;
        });
      }

      if (snapshot.docs.length < _documentLimit) {
        _hasMore = false; // No more documents to load
      }

      _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

      setState(() {
        snapshot.docs.forEach((doc) {
          upcomingList.add(doc.data() as Map<String, dynamic>);
        });
        loadUpcoming = false;
      });

      print(upcomingList);
      // filterBookings();
    } catch (error) {
      print("Error getting documents: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Container(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 35.0,
            left: 20.0,
            right: 20.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10.0,
            children: [
              // ProfileHeader(widget.userDetails, primaryColor),
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
              SizedBox(
                height: 5.0,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Nearby You",
                    // textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  Text(
                    "7km rad",
                    // textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: greyColor,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: isUpcomingEmpty
                    ? Container(
                        height: 150.0,
                        width: double.infinity,
                        child: Column(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Image.asset(
                                "images/noturfs.gif",
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
                    : RefreshIndicator(
                        onRefresh: _loadMoreData,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          controller: _scrollController,
                          physics: AlwaysScrollableScrollPhysics(),
                          itemCount: _isLoading
                              ? upcomingList.length + 3
                              : upcomingList.length,
                          itemBuilder: (context, index) {
                            if (index < upcomingList.length) {
                              return OnTapScaleAndFade(
                                  NearbyTile(
                                      upcomingList[index], widget.userDetails),
                                  () {
                                // print("tapping");
                                // Navigator.of(context).push(
                                //   _createRoute(
                                //       // Individualturf(
                                //       //   turfList[index],
                                //       //   widget.userDetails,
                                //       // ),
                                //       ),
                                // );
                              });
                            } else if (loadUpcoming) {
                              return Skeletonizer(
                                enabled: true,
                                enableSwitchAnimation: true,
                                child: NearbyTile({
                                  'name': "Lorem Ipsum",
                                  'src': 'images/turf_img.jpg',
                                }, widget.userDetails),
                              );
                            }
                          },
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

class NearbyTile extends StatelessWidget {
  NearbyTile(this.turfDetails, this.userDetails);

  Map userDetails;
  Map turfDetails;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 5.0,
        bottom: 5.0,
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
          height: 250.0,
          child: Stack(
            children: [
              Container(
                // width: MediaQuery.of(context).size.width - 150,
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
                            "images/turf_img.jpg",
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
                        height: 55.0,
                        // width: MediaQuery.of(context).size.width - 166,
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

class OnTapScaleAndFade extends StatefulWidget {
  final Widget child;
  final void Function() onTap;
  OnTapScaleAndFade(this.child, this.onTap);

  @override
  _OnTapScaleAndFadeState createState() => _OnTapScaleAndFadeState();
}

class _OnTapScaleAndFadeState extends State<OnTapScaleAndFade>
    with TickerProviderStateMixin {
  double squareScaleA = 1;
  late AnimationController _controllerA;
  @override
  void initState() {
    _controllerA = AnimationController(
      // animationBehavior: AnimationBehavior.preserve,
      vsync: this,
      lowerBound: 0.98,
      upperBound: 1.0,
      value: 1,
      duration: Duration(milliseconds: 5),
    );
    _controllerA.addListener(() {
      setState(() {
        squareScaleA = _controllerA.value;
      });
    });
    super.initState();
  }

  // Timer timer = Timer().per;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _controllerA.reverse();
        widget.onTap();
      },
      onTapDown: (dp) {
        _controllerA.reverse();
      },
      onTapUp: (dp) {
        Timer(Duration(milliseconds: 150), () {
          _controllerA.fling(velocity: 0.5);
        });
      },
      onTapCancel: () {
        _controllerA.fling(velocity: 0.5);
      },
      child: Transform.scale(
        scale: squareScaleA,
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _controllerA.dispose();
    super.dispose();
  }
}
