import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:turf_arena/constants.dart';
import 'package:turf_arena/screens/TicketScreen.dart';
import 'package:turf_arena/screens/components/ProfileHeader.dart';

class BookingSearch extends StatefulWidget {
  const BookingSearch(this.userDetails, this.bookingId);

  final Map userDetails;
  final String bookingId;

  @override
  State<BookingSearch> createState() => _BookingSearchState();
}

class _BookingSearchState extends State<BookingSearch> {
  List<Map<String, dynamic>> turfList = []; // List to store the document data
  bool loadingData = true;
  bool _isLoading = true;
  bool isEmpty = false;
  bool _hasMore = true;
  int _documentLimit = 4; // Number of documents to fetch per page
  DocumentSnapshot? _lastDocument; // To keep track of the last fetched document
  late ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.bookingId);
    fetchBooking();
  }

  void getData() async {
    await fetchBooking();
  }

  Future<void> fetchBooking() async {
    turfList = [];

    CollectionReference turfs =
        FirebaseFirestore.instance.collection('bookings');
    Map temp;

    try {
      // DocumentSnapshot bookingDoc = await FirebaseFirestore.instance
      //     .collection('bookings')
      //     .doc(widget.bookingId)
      //     .get();
      DocumentSnapshot bookingDoc = await turfs.doc(widget.bookingId).get();
      print(bookingDoc);
      if (bookingDoc.exists) {
        temp = bookingDoc.data() as Map<String, dynamic>;
        temp['id'] = bookingDoc.id;
        setState(() {
          loadingData = false;
          turfList.add(temp as Map<String, dynamic>);
        });
      } else {
        setState(() {
          isEmpty = true;
          loadingData = false;
        });
      }
    } catch (error) {
      print("Error Getting Booking ID : " + error.toString());
    }

    // await Future.delayed(Duration(seconds: 5));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 30.0,
        ),
        child: Container(
          child: Column(
            children: [
              ProfileHeader(widget.userDetails, primaryColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20.0,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            turfList.length.toString() +
                                (turfList.length > 1 ? " results" : " result"),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      isEmpty
                          ? Expanded(
                              child: NoItems(),
                            )
                          : Expanded(
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                // controller: _scrollController,
                                physics: AlwaysScrollableScrollPhysics(),
                                itemCount: loadingData
                                    ? turfList.length + 3
                                    : turfList.length,
                                itemBuilder: (context, index) {
                                  if (index < turfList.length) {
                                    return OnTapScaleAndFade(
                                        BookingWidget(
                                          turfList[index],
                                          greenColor,
                                        ), () {
                                      // print("tapping");
                                      // Navigator.of(context).push(
                                      //   _createRoute(
                                      //     Individualturf(
                                      //       turfList[index],
                                      //       widget.userDetails,
                                      //     ),
                                      //   ),
                                      // );
                                    });
                                  } else if (loadingData) {
                                    return Skeletonizer(
                                      enabled: true,
                                      enableSwitchAnimation: true,
                                      child: BookingWidget({
                                        'turfName': "Lorem Ipsum",
                                        'date': '00-00-00',
                                        'bookedTime': "",
                                        "from": "7 AM",
                                        "to": "8 AM",
                                      }, whiteColor),
                                    );
                                  }
                                },
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
    );
  }
}

class NoItems extends StatelessWidget {
  const NoItems({super.key});

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
              'No Turfs or Courts Found.',
              style: TextStyle(
                color: primaryColor,
                fontSize: 18.0,
              ),
            ),
            // Text(
            //   "Let's wait for",
            //   style: TextStyle(
            //     color: whiteColor,
            //     fontSize: 18.0,
            //   ),
            // ),
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
