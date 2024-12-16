import 'dart:async';
import 'dart:ui';
import 'package:turf_arena/constants.dart';
import 'package:turf_arena/screens/IndividualTurf.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:turf_arena/screens/SearchedList.dart';
import 'package:turf_arena/screens/components/ProfileHeader.dart';

class TurfsList extends StatefulWidget {
  TurfsList(this.title, this.userDetails);
  String title;
  Map userDetails;

  @override
  State<TurfsList> createState() => _TurfsListState();
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

class _TurfsListState extends State<TurfsList> {
  bool loadingData = true;
  bool isEmpty = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // print(widget.userDetails['u_id']);
    print(loadingData);

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

    filter = widget.title;
    (filter == "Other Turfs" ||
            filter == "Football" ||
            filter == "Badminton" ||
            filter == "Tennis")
        ? fetchTurfs()
        : widget.title == "Favorites"
            ? checkAndLoadSaved()
            : null;
  }

  void checkAndLoadSaved() {
    widget.userDetails['liked'].length == 0
        ? setState(() {
            isEmpty = true;
          })
        : fetchSaved();
  }

  late String filter;

  List<Map<String, dynamic>> turfList = []; // List to store the document data

  bool _isLoading = true;
  bool _hasMore = true;
  int _documentLimit = 4; // Number of documents to fetch per page
  DocumentSnapshot? _lastDocument; // To keep track of the last fetched document
  late ScrollController _scrollController = ScrollController();

  Future<void> fetchTurfs() async {
    CollectionReference turfs = FirebaseFirestore.instance.collection('turfs');

    Query query =
        turfs.where('allowed', arrayContains: filter).limit(_documentLimit);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    try {
      QuerySnapshot snapshot = await query.get();

      if (_lastDocument == null && snapshot.docs.isEmpty) {
        setState(() {
          isEmpty = true;
        });
      }

      if (snapshot.docs.length < _documentLimit) {
        _hasMore = false; // No more documents to load
      }

      _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

      setState(() {
        loadingData = false;
        _isLoading = false;
        snapshot.docs.forEach((doc) {
          // print(doc.id);

          turfList.add(doc.data() as Map<String, dynamic>);
        });
      });
    } catch (error) {
      print("Error getting documents: $error");
    }
  }

  Future<void> _doNothing() async {}

  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMore) return; // Prevent duplicate loading

    setState(() {
      _isLoading = true;
    });

    await fetchTurfs(); // Your existing data fetch method

    setState(() {
      _isLoading = false;
    });
  }

  // Future<void> fetchTurfs() {
  //   CollectionReference turfs = FirebaseFirestore.instance.collection('turfs');

  //   // await Future.delayed(Duration(seconds: 5));

  //   return turfs
  //       .where('allowed', arrayContains: filter)
  //       .get()
  //       .then((QuerySnapshot snapshot) {
  //     snapshot.docs.forEach((doc) {
  //       setState(() {
  //         // Store the document data into the list
  //         loadingData = false;
  //         turfList.add(doc.data() as Map<String, dynamic>);
  //       });
  //       print(loadingData);
  //       // print('${doc.id} => ${doc.data()}');
  //     });
  //   }).catchError((error) {
  //     print("Error getting documents: $error");
  //   });
  // }

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
      } else {
        snapshot.docs.forEach((doc) {
          setState(() {
            // Store the document data into the list
            loadingData = false;
            turfList.add(doc.data() as Map<String, dynamic>);
          });
          print(loadingData);
          // print('${doc.id} => ${doc.data()}');
        });
      }
    }).catchError((error) {
      print("Error getting documents: $error");
    });
  }

  Future<void> fetchSaved() {
    CollectionReference turfs = FirebaseFirestore.instance.collection('turfs');

    // await Future.delayed(Duration(seconds: 5));

    return turfs
        .where('t_id', whereIn: widget.userDetails['liked'])
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isEmpty) {
        setState(() {
          isEmpty = false;
        });
      }

      snapshot.docs.forEach((doc) {
        turfList.add(doc.data() as Map<String, dynamic>);
        // Store the document data into the list

        print(loadingData);
        // print('${doc.id} => ${doc.data()}');
      });
      setState(() {
        loadingData = false;
        _isLoading = false;
      });
    }).catchError((error) {
      print("Error getting documents: $error");
    });
  }

  // List<TurfTile> list = [];
  // List<TurfTile> getTurfList() {
  //   turfList.forEach(
  //     (turf) => list.add(TurfTile(turf)),
  //   );

  //   return list;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: widget.title == "Favorites"
          ? null
          : AppBar(
              leadingWidth: 75.0,
              leading: Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300]!.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: primaryColor,
                      // color: whiteColor,
                      size: 20.0,
                    ),
                  ),
                ),
              ),
              backgroundColor: whiteColor,
            ),
      backgroundColor: whiteColor,
      body: Container(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 30.0,
          ),
          child: Column(
            children: [
              widget.title == "Favorites"
                  ? Padding(
                      padding: const EdgeInsets.only(
                        bottom: 10.0,
                        // top: 10.0,
                      ),
                      child: ProfileHeader(widget.userDetails, primaryColor),
                    )
                  : SizedBox(),
              Row(
                // mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    // width: MediaQuery.of(context).size.width / 1.5,
                    child: Center(
                      child: Text(
                        capitalize(widget.title) +
                            ((widget.title == "Tennis" ||
                                    widget.title == "Badminton")
                                ? " Courts"
                                : (widget.title == "Other Turfs")
                                    ? ""
                                    : " Turfs"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 22.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
              Expanded(
                // flex: 4,
                child: Container(
                  // height: 500.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60.0),
                        topRight: Radius.circular(60.0),
                      )),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                    child: RefreshIndicator(
                      onRefresh: widget.title == "Favorites"
                          ? () async {
                              // print("1");
                            }
                          : _loadMoreData,
                      child: isEmpty
                          ? NoItems()
                          : Column(
                              children: [
                                SearchAnchor(
                                  viewBackgroundColor: whiteColor,
                                  viewOnSubmitted: (name) {
                                    print(name);
                                    Navigator.of(context).push(
                                      _createRoute(
                                        Searchedlist(
                                          name,
                                          widget.userDetails,
                                        ),
                                      ),
                                    );
                                  },
                                  builder: (BuildContext context,
                                      SearchController controller) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(
                                          60.0,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: SearchBar(
                                          textInputAction:
                                              TextInputAction.search,
                                          constraints: BoxConstraints(
                                            minHeight: 40.0,
                                          ),
                                          elevation: WidgetStatePropertyAll(0),
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                                  Colors.white)!,
                                          onTap: () {
                                            controller.openView();
                                          },
                                          onChanged: (_) {
                                            controller.openView();
                                          },
                                          onSubmitted: (name) async {
                                            controller.closeView(name);
                                            // await fetchByName(name);
                                          },
                                          // onTapOutside: (_) {
                                          //   controller.closeView("1");
                                          //   // FocusScope.of(context).unfocus();
                                          // },
                                          trailing: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 20.0,
                                              ),
                                              child: Icon(Icons.search),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  suggestionsBuilder: (BuildContext context,
                                      SearchController controller) {
                                    return List<ListTile>.generate(0,
                                        (int index) {
                                      final String item = 'item $index';
                                      return ListTile(
                                        title: Text(item),
                                        onTap: () {
                                          setState(() {
                                            controller.closeView(item);
                                          });
                                        },
                                      );
                                    });
                                  },
                                ),

                                SizedBox(
                                  height: 10.0,
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.only(
                                //     top: 8.0,
                                //     left: 8.0,
                                //     right: 8.0,
                                //     bottom: 12.0,
                                //   ),
                                //   child: Container(
                                //     child: TextField(
                                //       style: TextStyle(
                                //         color: whiteColor,
                                //       ),
                                //       onSubmitted: (value) {
                                //         Navigator.of(context).push(
                                //           _createRoute(
                                //             TurfsList(
                                //                 value, widget.userDetails),
                                //           ),
                                //         );
                                //       },
                                //       textInputAction: TextInputAction.search,
                                //       decoration: kTextFieldDecoration,
                                //     ),
                                //     decoration: BoxDecoration(
                                //       color: primaryColor,
                                //       borderRadius: BorderRadius.circular(30.0),
                                //       // backgroundBlendMode: BlendMode.screen,
                                //       border: Border.all(
                                //         width: 1.0,
                                //         color: greyColor,
                                //       ),
                                //       image: DecorationImage(
                                //         fit: BoxFit.cover,
                                //         opacity: 0.6,
                                //         image: AssetImage(
                                //           "images/grass_bg.jpg",
                                //         ),
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                Expanded(
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    controller: _scrollController,
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
