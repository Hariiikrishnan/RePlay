import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:turf_arena/constants.dart';
import 'package:turf_arena/screens/IndividualTurf.dart';
import 'package:turf_arena/screens/components/ProfileHeader.dart';

class Searchedlist extends StatefulWidget {
  Searchedlist(this.name, this.userDetails);

  String name;
  Map userDetails;

  @override
  State<Searchedlist> createState() => _SearchedlistState();
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

class _SearchedlistState extends State<Searchedlist> {
  bool loadingData = true;
  bool isEmpty = false;

  List<Map<String, dynamic>> turfList = []; // List to store the document data

  bool _isLoading = true;

  Future<void> fetchByName(String name) {
    print(name);
    turfList = [];
    CollectionReference turfs = FirebaseFirestore.instance.collection('turfs');

    // await Future.delayed(Duration(seconds: 5));

    return turfs
        .where('name', isEqualTo: name)
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isEmpty) {
        setState(() {
          isEmpty = true;
        });
      } else {
        snapshot.docs.forEach((doc) {
          setState(() {
            // Store the document data into the list
            loadingData = false;
            turfList.add(doc.data() as Map<String, dynamic>);
            _isLoading = false;
          });
          print(loadingData);
          // print('${doc.id} => ${doc.data()}');
        });
      }
    }).catchError((error) {
      print("Error getting documents: $error");
    });
  }

  void callSearch(String name) async {
    await fetchByName(name);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    callSearch(widget.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                (turfList.length > 1 ? " results" : " result") +
                                (" for " + widget.name),
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
                                itemCount: _isLoading
                                    ? turfList.length + 3
                                    : turfList.length,
                                itemBuilder: (context, index) {
                                  if (index < turfList.length) {
                                    return OnTapScaleAndFade(
                                        TurfTile(
                                          turfList[index],
                                          widget.userDetails,
                                        ), () {
                                      // print("tapping");
                                      Navigator.of(context).push(
                                        _createRoute(
                                          Individualturf(
                                            turfList[index],
                                            widget.userDetails,
                                          ),
                                        ),
                                      );
                                    });
                                  } else if (_isLoading) {
                                    return Skeletonizer(
                                      enabled: true,
                                      enableSwitchAnimation: true,
                                      child: TurfTile({
                                        'name': 'Turf Trichy',
                                        'startTime': "8 AM",
                                        'endTime': "11 PM",
                                        'amtPerHour': "1200",
                                        'address':
                                            'Lorem Ipsum Loreum Ipsum Lorem Ipsum Lorem Ipsum Loreum Ipsum Lorem Ipsum',
                                      }, {}),
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

String capitalize(String text) {
  if (text == null || text.isEmpty) {
    return text; // Return as is if the string is null or empty
  }
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

class TurfTile extends StatelessWidget {
  TurfTile(this.details, this.userDetails);
  Map details;
  Map userDetails;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          // vertical: 10.0,
          ),
      child: Container(
          decoration: BoxDecoration(
            // boxShadow: [
            //   BoxShadow(
            //     color: greyColor.withOpacity(0.2),
            //     spreadRadius: 2,
            //     blurRadius: 7,
            //     offset: Offset(0, 1), // changes position of shadow
            //   ),
            // ],
            borderRadius: BorderRadius.circular(30.0),
            // color: greenColor.withOpacity(0.1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              // horizontal: 8.0,
              vertical: 4.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24.0),
                  child: Image(
                    // width: 150.0,
                    height: 150.0,
                    fit: BoxFit.cover,
                    image: AssetImage(
                      "images/cricket.png",
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      // borderRadius: BorderRadius.circular(2.0),
                      // border: Border(
                      //     bottom: BorderSide(
                      //   width: 3.0,
                      //   color: Colors.grey[400]!,
                      // )),
                      ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 12.0,
                      // left: 8.0,
                      // right: 8.0,
                      bottom: 12.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              capitalize(details['name']),
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              "Opens On : " +
                                  details['startTime'] +
                                  " - " +
                                  details['endTime'],
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 15.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            // Text(
                            //   details['address'],
                            //   style: TextStyle(
                            //     color: primaryColor,
                            //     fontSize: 28.0,
                            //     fontWeight: FontWeight.w400,
                            //   ),
                            // ),
                          ],
                        ),
                        // Text(
                        //   details['address'],
                        //   style: TextStyle(
                        //     color: primaryColor,
                        //     fontSize: 28.0,
                        //     fontWeight: FontWeight.w400,
                        //   ),
                        // ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "₹ " + details['amtPerHour'].toString() + "/-",
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              "Per Hour",
                              style: TextStyle(
                                color: Colors.black38,
                                fontSize: 13.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )),
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
