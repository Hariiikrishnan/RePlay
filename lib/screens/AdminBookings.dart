import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:turf_arena/constants.dart';
import 'package:turf_arena/screens/TicketScreen.dart';
import 'package:turf_arena/screens/components/ProfileHeader.dart';

class AdminBookings extends StatefulWidget {
  AdminBookings(this.userDetails);
  Map userDetails;

  @override
  State<AdminBookings> createState() => _AdminBookingsState();
}

class _AdminBookingsState extends State<AdminBookings> {
  List<Map<String, dynamic>> bookingsList = [];
  List<Map<String, dynamic>> pastList = [];

  bool loadingData = true;

  bool isPastEmpty = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // List<DocumentSnapshot> _documents = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _documentLimit = 5; // Number of documents to fetch per page
  DocumentSnapshot? _lastDocument; // To keep track of the last fetched document
  late ScrollController _scrollController = ScrollController();
  // late DocumentSnapshot _lastDocument;

  Timestamp now = Timestamp.fromDate(DateTime.now());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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

  Future<void> fetchBookings() async {
    CollectionReference bookings =
        FirebaseFirestore.instance.collection('bookings');
    CollectionReference turfs = FirebaseFirestore.instance.collection('turfs');

    QuerySnapshot turfQuery = await turfs
        .where('adminId', isEqualTo: widget.userDetails['uid'])
        .get();

    if (turfQuery.docs.isEmpty) {
      print(
        "No Turfs Found, Please check the admin Id and User Id",
      );
      return;
    }
    Query query = bookings
        .where('t_id', isEqualTo: turfQuery.docs.first['t_id'])
        // .where('paid', isEqualTo: true)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Container(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 30.0,
          ),
          child: RefreshIndicator(
            onRefresh: _loadMoreData,
            child: Column(
              spacing: 15.0,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileHeader(widget.userDetails, primaryColor),
                Row(
                  children: [
                    Text(
                      "Our Bookings",
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
