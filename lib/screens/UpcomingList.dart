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
import 'package:turf_arena/screens/TicketScreen.dart';
import 'package:turf_arena/screens/components/ProfileHeader.dart';

class UpcomingList extends StatefulWidget {
  const UpcomingList(this.userDetails);
  final Map userDetails;

  @override
  State<UpcomingList> createState() => _UpcomingListState();
}

class _UpcomingListState extends State<UpcomingList> {
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

  // Future<void> fetchUpComing() async {
  //   CollectionReference bookings =
  //       FirebaseFirestore.instance.collection('bookings');

  //   Query query = bookings
  //       .where('u_id', isEqualTo: widget.userDetails['uid'])
  //       // .where('paid', isEqualTo: true)
  //       .where('date', isGreaterThanOrEqualTo: now)
  //       .orderBy('date')
  //       .limit(_documentLimit);

  //   try {
  //     QuerySnapshot snapshot = await query.get();

  //     if (snapshot.docs.isEmpty) {
  //       setState(() {
  //         isUpcomingEmpty = true;
  //       });
  //     }

  //     setState(() {
  //       snapshot.docs.forEach((doc) {
  //         upcomingList.add(doc.data() as Map<String, dynamic>);
  //       });
  //       loadUpcoming = false;

  //       print("Upcoming = " + upcomingList.toString());
  //     });
  //   } catch (error) {
  //     print("Error getting documents: $error");
  //   }
  // }

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

    _loadMoreData();
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
    CollectionReference bookings =
        FirebaseFirestore.instance.collection('bookings');
    Query query = bookings
        .where('u_id', isEqualTo: widget.userDetails['uid'])
        // .where('paid', isEqualTo: true)
        .where('date', isGreaterThanOrEqualTo: now)
        .orderBy('date')
        .limit(_documentLimit);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    Map temp;
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
          temp = doc.data() as Map<String, dynamic>;
          temp['id'] = doc.id;
          print(doc.id);
          upcomingList.add(temp as Map<String, dynamic>);
          // upcomingList.add(doc.data() as Map<String, dynamic>);
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      DateFormat('d MMM,hh:mm a').format(DateTime.now()),
                      // textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5.0,
              ),

              Text(
                "Upcoming Bookings",
                // textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              Expanded(
                child: isUpcomingEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            // vertical: 8.0,
                            horizontal: 25.0,
                            vertical: 25.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                spacing: 10.0,
                                children: [
                                  Text(
                                    "Oops!",
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 45.0,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Icon(
                                    Icons.search_off_rounded,
                                    color: Colors.grey[400],
                                    size: 45.0,
                                  )
                                ],
                              ),
                              Text(
                                "No upcoming bookings,book and play!",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 15.0,
                                ),
                              ),
                            ],
                          ),
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
                                  UpcomingBookingTile(
                                    upcomingList[index],
                                  ), () {
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
                                child: UpcomingBookingTile(
                                  {
                                    'turfName': "Lorem Ipsum",
                                    'date': Timestamp.now(),
                                    'bookedTime': "",
                                    "from": "7 AM",
                                    "to": "8 AM",
                                  },
                                ),
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

class UpcomingBookingTile extends StatelessWidget {
  UpcomingBookingTile(this.bookedDetails);

  Map bookedDetails;

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
    return Padding(
      padding: const EdgeInsets.only(
        // left: 20.0,
        top: 5.0,
        bottom: 5.0,
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            _createRoute(
              Ticketscreen(bookedDetails),
            ),
          );
        },
        child: Container(
          // width: MediaQuery.of(context).size.width - 120,
          height: MediaQuery.of(context).size.height / 4,
          child: Stack(
            children: [
              Container(
                // height: 250.0,
                width: MediaQuery.of(context).size.width - 40,

                decoration: BoxDecoration(
                  // color: Colors.red,
                  borderRadius: BorderRadius.circular(
                    30.0,
                  ),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    // image: AssetImage(turfDetails['src']),
                    image: bookedDetails['src'] == null
                        ? AssetImage(
                            "images/turf_img.jpg",
                          )
                        : CachedNetworkImageProvider(
                            bookedDetails['imgList'][0],
                          ),
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
                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        height: 70.0,
                        width: MediaQuery.of(context).size.width - 56,
                        decoration: BoxDecoration(
                            color: primaryColor.withOpacity(
                              0.25,
                            ),
                            borderRadius: BorderRadius.circular(
                              20.0,
                            )),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bookedDetails['turfName'],
                                    style: TextStyle(
                                      color: whiteColor,
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    "At " +
                                        bookedDetails['date']
                                            .toDate()
                                            .toString()
                                            .substring(0, 10) +
                                        ", " +
                                        bookedDetails['from'] +
                                        " - " +
                                        bookedDetails['to'],
                                    style: TextStyle(
                                      color: greyColor,
                                      fontSize: 13.0,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                        left: BorderSide(
                                  width: 2.0,
                                  color: whiteColor,
                                ))),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 15.0,
                                  ),
                                  child: Text(
                                    "₹ " + bookedDetails['amount'].toString(),
                                    style: TextStyle(
                                      color: whiteColor,
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
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
