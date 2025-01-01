import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:turf_arena/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:turf_arena/screens/TicketScreen.dart';
import 'package:turf_arena/screens/UpcomingList.dart';
import 'package:turf_arena/screens/components/ProfileHeader.dart';

class MyBookings extends StatefulWidget {
  MyBookings(this.details);
  Map details;

  @override
  State<MyBookings> createState() => _MyBookingsState();
}

class _MyBookingsState extends State<MyBookings> {
  List<Map<String, dynamic>> bookingsList = [];
  List<Map<String, dynamic>> pastList = [];
  List<Map<String, dynamic>> upcomingList = [];
  bool loadingData = true;
  bool loadUpcoming = true;
  bool isPastEmpty = false;
  bool isUpcomingEmpty = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // List<DocumentSnapshot> _documents = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _documentLimit = 4; // Number of documents to fetch per page
  DocumentSnapshot? _lastDocument; // To keep track of the last fetched document
  late ScrollController _scrollController = ScrollController();
  // late DocumentSnapshot _lastDocument;

  // late ScrollController _scrollController;

  Timestamp now = Timestamp.fromDate(DateTime.now());

  @override
  void initState() {
    super.initState();
    // amount = widget.details['amtPerHour'];
    // details = widget.details;

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

    // Load initial data
    fetchUpComing();
    _loadMoreData();
  }

  int page = 1; // Current page number
  // final int itemsPerPage = 3;

  // Future<void> fetchTurfs() async {
  //   CollectionReference bookings =
  //       FirebaseFirestore.instance.collection('bookings');

  //   Query query = bookings
  //       .where('u_id', isEqualTo: 'ZdJQ8w3OsoYqQaNxrMyOV2kVbQu1')
  //       .limit(_documentLimit);

  //   if (_lastDocument != null) {
  //     query = query.startAfterDocument(_lastDocument!);
  //   }

  //   try {
  //     QuerySnapshot snapshot = await query.get();

  //     if (snapshot.docs.length < _documentLimit) {
  //       _hasMore = false; // No more documents to load
  //     }

  //     _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

  //     setState(() {
  //       loadingData = false;
  //       snapshot.docs.forEach((doc) {
  //         bookingsList.add(doc.data() as Map<String, dynamic>);
  //       });
  //     });
  //   } catch (error) {
  //     print("Error getting documents: $error");
  //   }
  // }

  Future<void> fetchUpComing() async {
    CollectionReference bookings =
        FirebaseFirestore.instance.collection('bookings');

    Query query = bookings
        .where('u_id', isEqualTo: widget.details['uid'])
        // .where('paid', isEqualTo: true)
        .where('date', isGreaterThanOrEqualTo: now)
        .orderBy('date')
        .limit(1);

    Map temp;
    try {
      QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          isUpcomingEmpty = true;
        });
      }

      setState(() {
        snapshot.docs.forEach((doc) {
          temp = doc.data() as Map<String, dynamic>;
          temp['id'] = doc.id;
          print(doc.id);
          upcomingList.add(temp as Map<String, dynamic>);
          // upcomingList.add(doc.data() as Map<String, dynamic>);
        });
        loadUpcoming = false;

        print("Upcoming " + upcomingList.toString());
      });
    } catch (error) {
      print("Error getting documents: $error");
    }
  }

  Future<void> fetchBookings() async {
    CollectionReference bookings =
        FirebaseFirestore.instance.collection('bookings');

    Query query = bookings
        .where('u_id', isEqualTo: widget.details['uid'])
        // .where('paid', isEqualTo: true)
        .where('date', isLessThan: now)
        .orderBy('date', descending: true)
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
          isPastEmpty = true;
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
          pastList.add(temp as Map<String, dynamic>);
        });
        // loadingdata = false;
      });

      print(pastList);
      // filterBookings();
    } catch (error) {
      print("Error getting documents: $error");
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMore) return; // Prevent duplicate loading

    setState(() {
      _isLoading = true;
    });

    await fetchBookings(); // Your existing data fetch method

    setState(() {
      _isLoading = false;
    });
  }

// *****  OLD WORKING CODE FOR FILTERING THE BOOKINGS INTO PAST AND UPCOMING BOOKINGS.
  // void filterBookings() {
  //   // Get the current date and time
  //   DateTime now = DateTime.now();

  //   // Separate past and upcoming bookings
  //   List<Map<String, dynamic>> pastBookings = [];
  //   List<Map<String, dynamic>> upcomingBookings = [];

  //   for (var booking in bookingsList) {
  //     print(booking);
  //     try {
  //       // Parse the booking date and time
  //       String bookingDateStr = booking['date']?.trim() ?? '';
  //       DateTime bookingDate = DateFormat("d - MMM").parse(bookingDateStr);

  //       String bookedTimeStr = booking['from']?.trim() ?? '';
  //       DateTime bookedTime = DateFormat("h a").parse(bookedTimeStr);

  //       // Combine booking date and time into a single DateTime object
  //       DateTime fullBookedDateTime = DateTime(
  //         now.year,
  //         bookingDate.month,
  //         bookingDate.day,
  //         bookedTime.hour,
  //         bookedTime.minute,
  //       );

  //       // Classify booking
  //       if (fullBookedDateTime.isBefore(now)) {
  //         // Add to past bookings
  //         pastBookings.add(booking);
  //       } else if (bookingDate.month > now.month ||
  //           (bookingDate.month == now.month && bookingDate.day > now.day)) {
  //         // Add to upcoming bookings
  //         upcomingBookings.add(booking);
  //       }
  //     } catch (e) {
  //       print("Error processing booking: $booking, Error: $e");
  //     }
  //   }
  // Update state
  //   setState(() {
  //     loadingData = false;
  //     pastList = pastBookings;
  //     upcomingList = upcomingBookings;
  //   });

  //   // Debug logs
  //   print("Past bookings: $pastBookings");
  //   print("Upcoming bookings: $upcomingBookings");
  // }

  void filterBookings() {
    // Get the current date and time
    DateTime now = DateTime.now();

    // Separate past and upcoming bookings
    List<Map<String, dynamic>> pastBookings = [];
    List<Map<String, dynamic>> upcomingBookings = [];

    for (var booking in bookingsList) {
      print(booking);
      try {
        // Retrieve the booking timestamp and convert it to DateTime
        Timestamp bookingTimestamp = booking['date'];
        DateTime bookingDateTime = bookingTimestamp.toDate();

        // Combine booking date and time into a single DateTime object
        String bookedTimeStr = booking['from']?.trim() ?? '';
        DateTime bookedTime = DateFormat("h a").parse(bookedTimeStr);

        DateTime fullBookedDateTime = DateTime(
          bookingDateTime.year,
          bookingDateTime.month,
          bookingDateTime.day,
          bookedTime.hour,
          bookedTime.minute,
        );

        // Classify booking
        if (fullBookedDateTime.isBefore(now)) {
          // Add to past bookings
          pastBookings.add(booking);
        } else {
          // Add to upcoming bookings
          upcomingBookings.add(booking);
        }
      } catch (e) {
        print("Error processing booking: $booking, Error: $e");
      }
    }

    // Update state
    setState(() {
      loadingData = false;
      pastList = pastBookings;
      upcomingList = upcomingBookings;
    });

    // Debug logs
    print("Past bookings: $pastBookings");
    print("Upcoming bookings: $upcomingBookings");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: whiteColor,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 30.0,
          ),
          child: RefreshIndicator(
            onRefresh: _loadMoreData,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ProfileHeader(widget.details, primaryColor),
                SizedBox(
                  height: 15.0,
                ),
                Expanded(
                  // width: 150.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Upcoming Bookings",
                            // textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              isUpcomingEmpty
                                  ? null
                                  : Navigator.of(context).push(
                                      _createRoute(
                                        UpcomingList(widget.details),
                                      ),
                                    );
                            },
                            child: Text(
                              "See All",
                              style: TextStyle(
                                color: isUpcomingEmpty ? greyColor : greenColor,
                                fontSize: 15.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      loadUpcoming
                          ? Skeletonizer(
                              enabled: true,
                              enableSwitchAnimation: true,
                              child: UpcomingBookingTile({
                                'turfName': "Lorem Ipsum",
                                'date': Timestamp.now(),
                                'bookedTime': "",
                                "from": "7 AM",
                                "to": "8 AM",
                              }),
                            )
                          : isUpcomingEmpty
                              ? Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 8.0,
                                    horizontal: 25.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                )
                              : UpcomingBookingTile(upcomingList[0]),
                      // : BookingWidget(pastList[0], greenColor),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "Past Bookings",
                        // textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Expanded(
                        child: isPastEmpty
                            ? NoBookings()
                            : ListView.builder(
                                padding: EdgeInsets.zero,
                                controller: _scrollController,
                                physics: AlwaysScrollableScrollPhysics(),
                                itemCount: _isLoading
                                    ? pastList.length + 3
                                    : pastList.length,
                                itemBuilder: (context, index) {
                                  if (index < pastList.length) {
                                    // Replace with your booking item widget
                                    return BookingWidget(
                                        pastList[index], Colors.grey[400]!);
                                  } else if (_isLoading) {
                                    return Skeletonizer(
                                      enabled: true,
                                      enableSwitchAnimation: true,
                                      child: BookingWidget({
                                        'turfName': "Lorem Ipsum",
                                        'date': '00-00-00',
                                        'bookedTime': "",
                                        "from": "7 AM",
                                        "to": "8 AM",
                                      }, Colors.white),
                                    );
                                  }
                                },
                              ),
                      ),
                    ],
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

class NoBookings extends StatelessWidget {
  const NoBookings({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_dissatisfied_rounded,
              color: Colors.grey[400],
              size: 120.0,
            ),
            //  FUI(
            //   RegularRounded.SAD,
            //   color: primaryColor,
            //   height: 150.0,
            //   width: 150.0,
            // ),
            SizedBox(
              height: 20.0,
            ),
            Text(
              'No past bookings,fun missed!',
              style: TextStyle(
                color: primaryColor,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookingWidget extends StatelessWidget {
  BookingWidget(this.details, this.bgColor);
  Color bgColor;
  Map details;

  String capitalize(String? text) {
    if (text == null || text.isEmpty) {
      return text!; // Return as is if the string is null or empty
    }
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7.0,
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            _createRoute(
              Ticketscreen(details),
            ),
          );
        },
        child: Container(
          // height: 170.0,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 82, 213, 182).withOpacity(0.6),
            // gradient: LinearGradient(
            //   colors: [
            //     Colors.grey[200]!.withOpacity(1),
            //     const Color.fromARGB(255, 82, 213, 182).withOpacity(0.6),
            //   ],
            //   begin: Alignment.bottomLeft,
            //   end: Alignment.topRight,
            //   stops: [0.2, 1.0],
            //   tileMode: TileMode.repeated,
            // ),
            borderRadius: BorderRadius.circular(
              16.0,
            ),
            // boxShadow: [
            //   BoxShadow(
            //     color: greyColor.withOpacity(0.3),
            //     spreadRadius: 2,
            //     blurRadius: 15,
            //     offset: Offset(2, -5), // changes position of shadow
            //   ),
            // ],
            boxShadow: [
              // const BoxShadow(
              //   color: Color.fromRGBO(203, 203, 203, 1),
              //   spreadRadius: 1.0,
              //   blurRadius: 0.0,
              // ),
              // const BoxShadow(
              //   color: whiteColor,
              //   spreadRadius: 1.0,
              //   blurRadius: 2.0,
              //   offset: Offset(0, 3),
              // ),
              // const BoxShadow(
              //   color: Color.fromRGBO(203, 203, 203, 1),
              //   spreadRadius: 1.0,
              //   blurRadius: 0.0,
              // ),
              // const BoxShadow(
              //   color: whiteColor,
              //   spreadRadius: 1.0,
              //   blurRadius: 2.0,
              //   offset: Offset(0, -3),
              // ),
            ],
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: 25.0,
                    width: 15.0,
                    decoration: BoxDecoration(
                        color: whiteColor,
                        // boxShadow: [
                        //   const BoxShadow(
                        //     color: greyColor,
                        //     spreadRadius: 1.0,
                        //     blurRadius: 1.0,
                        //   ),
                        //   const BoxShadow(
                        //     color: whiteColor,
                        //     spreadRadius: 2.0,
                        //     blurRadius: 3.0,
                        //     offset: Offset(-2, 0),
                        //   ),
                        // ],
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(50.0),
                          bottomRight: Radius.circular(50.0),
                        )),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  Container(
                    height: 25.0,
                    width: 15.0,
                    decoration: BoxDecoration(
                        color: whiteColor,
                        // boxShadow: [
                        //   const BoxShadow(
                        //     color: greyColor,
                        //     spreadRadius: 1.0,
                        //     blurRadius: 1.0,
                        //   ),
                        //   const BoxShadow(
                        //     color: whiteColor,
                        //     spreadRadius: 2.0,
                        //     blurRadius: 3.0,
                        //     offset: Offset(-2, 0),
                        //   ),
                        // ],
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(50.0),
                          bottomRight: Radius.circular(50.0),
                        )),
                  ),
                ],
              ),
              Expanded(
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 10.0,
                            right: 3.0,
                            top: 20.0,
                            bottom: 20.0,
                          ),
                          child: Column(
                            spacing: 2.0,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                "Turf Booked",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "To Play at",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "Time",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "Booked at",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "Amount Paid",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // VerticalDivider(
                      //   color: whiteColor,
                      //   thickness: 3.0,
                      //   width: 5.0,
                      //   // indent: 10.0,
                      //   // endIndent: 10.0,
                      // ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          // width: 2.0,
                          // height: 150.0, // Adjust this to your desired height
                          decoration: BoxDecoration(
                            border: Border(
                                // right: BorderSide(
                                //   color: Colors.grey[200]!,
                                //   width: 2.0,
                                //   style: BorderStyle
                                //       .solid, // This is the trick to dashed effect
                                // ),
                                ),
                          ),
                          child: Column(
                            children: List.generate(
                              10, // Number of dots
                              (index) => Expanded(
                                flex: 1,
                                child: Container(
                                  width: 3.0,
                                  // height: 15.0,
                                  margin: index == 9
                                      ? EdgeInsets.only(bottom: 6.0)
                                      : EdgeInsets.only(bottom: 8.0),
                                  color: whiteColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 7,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: 10.0,
                            left: 3.0,
                            top: 20.0,
                            bottom: 20.0,
                          ),
                          child: Column(
                            spacing: 2.0,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                capitalize(details['turfName']),
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              details['bookedTime'].runtimeType == String
                                  ? Text(
                                      "details['date']",
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  : Text(
                                      DateFormat('MMM d').format(
                                        DateTime.parse(details['date']
                                            .toDate()
                                            .toString()),
                                      ),
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                              Text(
                                details['from'] + " - " + details['to'],
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.0,
                                ),
                              ),
                              details['bookedTime'].runtimeType == String
                                  ? Text(
                                      "details['bookedTime']",
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14.0,
                                      ),
                                    )
                                  : Text(
                                      DateFormat('d MMM, hh:mm a').format(
                                        DateTime.parse(details['bookedTime']
                                            .toDate()
                                            .toString()),
                                      ),
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14.0,
                                      ),
                                    ),
                              Text(
                                "₹ " + details['amount'].toString(),
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
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
                    height: 25.0,
                    width: 15.0,
                    decoration: BoxDecoration(
                        color: whiteColor,
                        // boxShadow: [
                        //   const BoxShadow(
                        //     color: greyColor,
                        //     spreadRadius: 1.0,
                        //     blurRadius: 1.0,
                        //   ),
                        //   const BoxShadow(
                        //     color: whiteColor,
                        //     spreadRadius: 2.0,
                        //     blurRadius: 5.0,
                        //     offset: Offset(0, -2),
                        //   ),
                        // ],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50.0),
                          bottomLeft: Radius.circular(50.0),
                        )),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  Container(
                    height: 25.0,
                    width: 15.0,
                    decoration: BoxDecoration(
                        color: whiteColor,
                        // boxShadow: [
                        //   const BoxShadow(
                        //     color: greyColor,
                        //     spreadRadius: 1.0,
                        //     blurRadius: 1.0,
                        //   ),
                        //   const BoxShadow(
                        //     color: whiteColor,
                        //     spreadRadius: 2.0,
                        //     blurRadius: 5.0,
                        //     offset: Offset(0, -2),
                        //   ),
                        // ],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50.0),
                          bottomLeft: Radius.circular(50.0),
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MySeparator extends StatelessWidget {
  const MySeparator({Key? key, this.height = 1, this.color = Colors.black})
      : super(key: key);
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 10.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
        );
      },
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

class UpcomingBookingTile extends StatelessWidget {
  UpcomingBookingTile(this.bookedDetails);

  Map bookedDetails;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          // left: 20.0,
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
                      filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
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
