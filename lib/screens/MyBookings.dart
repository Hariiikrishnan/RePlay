import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:turf_arena/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skeletonizer/skeletonizer.dart';
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

    try {
      QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          isUpcomingEmpty = true;
        });
      }

      setState(() {
        snapshot.docs.forEach((doc) {
          upcomingList.add(doc.data() as Map<String, dynamic>);
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
          pastList.add(doc.data() as Map<String, dynamic>);
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
                            onTap: () {},
                            child: Text(
                              "See All",
                              style: TextStyle(
                                color: greenColor,
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
                              child: BookingWidget({
                                'turfName': "Lorem Ipsum",
                                'date': '00-00-00',
                                'bookedTime': "",
                                "from": "7 AM",
                                "to": "8 AM",
                              }, Color.fromARGB(232, 215, 214, 214)),
                            )
                          : isUpcomingEmpty
                              ? Container(
                                  child: Text(
                                    "Book Something!",
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
                                      }, Color.fromARGB(232, 215, 214, 214)),
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
              color: primaryColor,
              size: 120.0,
            ),
            SizedBox(
              height: 30.0,
            ),
            Text(
              'No Bookings Found.',
              style: TextStyle(
                color: primaryColor,
                fontSize: 18.0,
              ),
            ),
            Text(
              'Book Your Turfs Now!',
              style: TextStyle(
                color: primaryColor,
                fontSize: 18.0,
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
      child: Container(
        // height: 170.0,
        decoration: BoxDecoration(
            color: Colors.grey[200],
            // gradient: LinearGradient(
            //   colors: [
            //     Colors.grey[200]!.withOpacity(1),
            //     whiteColor.withOpacity(1.0)
            //   ],
            //   begin: Alignment.bottomLeft,
            //   end: Alignment.topRight,
            //   stops: [0.2, 1.0],
            //   tileMode: TileMode.repeated,
            // ),
            borderRadius: BorderRadius.circular(
              16.0,
            )),
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
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(50.0),
                        bottomRight: Radius.circular(50.0),
                      )),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "Turf Booked : " + capitalize(details['turfName']),
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    details['bookedTime'].runtimeType == String
                        ? Text(
                            "To Play at :  details['date']",
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 14.0,
                            ),
                          )
                        : Text(
                            "To Play at : " +
                                details['date']
                                    .toDate()
                                    .toString()
                                    .substring(0, 16),
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 14.0,
                            ),
                          ),
                    Text(
                      "Time : " +
                          " From " +
                          details['from'] +
                          " to " +
                          details['to'],
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 14.0,
                      ),
                    ),
                    details['bookedTime'].runtimeType == String
                        ? Text(
                            "Booked at : details['bookedTime']",
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 14.0,
                            ),
                          )
                        : Text(
                            "Booked at : " +
                                details['bookedTime']
                                    .toDate()
                                    .toString()
                                    .substring(0, 16),
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 14.0,
                            ),
                          ),
                    Text(
                      "Amount Paid : Rs.1200",
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 14.0,
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
          // Navigator.of(context).push(
          //   _createRoute(
          //       // Individualturf(
          //       //   turfDetails,
          //       //   userDetails,
          //       // ),
          //       ),
          // );
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
                        : AssetImage(
                            bookedDetails['src'],
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
