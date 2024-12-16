import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:turf_arena/screens/BookingScreen.dart';
import 'package:turf_arena/screens/IndividualTurf.dart';
import 'package:turf_arena/screens/TurfsList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:turf_arena/constants.dart';
import 'components/ProfileHeader.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen(this.userDetails);
  Map userDetails;

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
  Map respData = {
    "html_attributions": [],
    "results": [
      {
        "business_status": "OPERATIONAL",
        "geometry": {
          "location": {"lat": 10.7576557, "lng": 79.11217499999999},
          "viewport": {
            "northeast": {"lat": 10.75903437989272, "lng": 79.11356962989272},
            "southwest": {"lat": 10.75633472010728, "lng": 79.11086997010729}
          }
        },
        "icon":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/generic_business-71.png",
        "icon_background_color": "#7B9EB0",
        "icon_mask_base_uri":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v2/generic_pinlet",
        "name": "Power Smack Turf",
        "photos": [
          {
            "height": 4032,
            "html_attributions": [
              "<a href=\"https://maps.google.com/maps/contrib/107776269615430639692\">Sa ba</a>"
            ],
            "photo_reference":
                "AdDdOWrKCSi8evabGZeLgarKzb74RYsgTPzycQMfEfNti5_sqPkJ77qp-fEzL1ak2MTnbcIVwfhYAt1z2YXw6_uoiGlWHPgO8CNODpM3d7VtgUAxcfuR52g-uDNexiF4brAGUDziFb7XM2_Fv2NQPtcIMHX4V1HZ7iN-8un3YnAtymmRs5LG",
            "width": 3024
          }
        ],
        "place_id": "ChIJVz-qaAC5qjsRIxDshxRiQC4",
        "plus_code": {
          "compound_code": "Q456+3V Thanjavur, Tamil Nadu",
          "global_code": "7J2XQ456+3V"
        },
        "rating": 2.6,
        "reference": "ChIJVz-qaAC5qjsRIxDshxRiQC4",
        "scope": "GOOGLE",
        "types": ["point_of_interest", "establishment"],
        "user_ratings_total": 7,
        "vicinity":
            "Serfoji ground backside, Indra Nagar main road, Devan Nagar 1st St, near power Smack Gym, opposite to Mother MIRA school, Thanjavur"
      },
      {
        "business_status": "OPERATIONAL",
        "geometry": {
          "location": {"lat": 10.7824672, "lng": 79.1020084},
          "viewport": {
            "northeast": {"lat": 10.78388007989272, "lng": 79.10333197989272},
            "southwest": {"lat": 10.78118042010728, "lng": 79.10063232010728}
          }
        },
        "icon":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/generic_business-71.png",
        "icon_background_color": "#7B9EB0",
        "icon_mask_base_uri":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v2/generic_pinlet",
        "name": "Vinyaka Sports Club",
        "opening_hours": {},
        "photos": [
          {
            "height": 3024,
            "html_attributions": [
              "<a href=\"https://maps.google.com/maps/contrib/103715711055695403623\">THANJAI THAMILAN</a>"
            ],
            "photo_reference":
                "AdDdOWr52M9Rao2H1Kby8Il-UMpId82D--ypXq-mrVp9n8NFtJyhD4zXhT3376Oc6zylxrxx3iSl2khwvzQIy7iGahbxSLCqu-gz-eu5SyyoD35TEF5xPTUg278T7kKk2-QAplnkci9iTWXc4Oa1qepodHCuoePlu_FqP8tHZqSlzmxuA1aI",
            "width": 4032
          }
        ],
        "place_id": "ChIJ-Q54d5O_qjsR88xKd15v6mk",
        "rating": 3.8,
        "reference": "ChIJ-Q54d5O_qjsR88xKd15v6mk",
        "scope": "GOOGLE",
        "types": ["point_of_interest", "establishment"],
        "user_ratings_total": 9,
        "vicinity": "Q4J2+XRJ, Sundram Nagar, Thanjavur"
      },
      {
        "business_status": "OPERATIONAL",
        "geometry": {
          "location": {"lat": 10.754707, "lng": 79.1132502},
          "viewport": {
            "northeast": {"lat": 10.75642412989272, "lng": 79.11425152989271},
            "southwest": {"lat": 10.75372447010728, "lng": 79.11155187010728}
          }
        },
        "icon":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/generic_business-71.png",
        "icon_background_color": "#7B9EB0",
        "icon_mask_base_uri":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v2/generic_pinlet",
        "name": "Rajah Serfoji Ground",
        "photos": [
          {
            "height": 3551,
            "html_attributions": [
              "<a href=\"https://maps.google.com/maps/contrib/101974870093925708792\">A Google User</a>"
            ],
            "photo_reference":
                "AdDdOWp6WZhlNjduambXmJvXQMUMz4kgAmHrvpejtuLxHVi8rWAO0QO5ryFPHXA_kx3p7Z1qB_ycBeLVXiO4DndTSbY8ej-k4gpV8tYwtudBIQs7wM6jNwJSZdDK17D3HyCMw48_JWeeyGffBa0cwBsg4sgpfneKOheOAZqhGxJodQtNmYDj",
            "width": 2590
          }
        ],
        "place_id": "ChIJr6GuFXu5qjsRo6CCLxkEfuI",
        "rating": 4.5,
        "reference": "ChIJr6GuFXu5qjsRo6CCLxkEfuI",
        "scope": "GOOGLE",
        "types": ["point_of_interest", "establishment"],
        "user_ratings_total": 2,
        "vicinity": "Q437+V8J, AVP Azhagammal Nagar, Thanjavur"
      },
      {
        "business_status": "OPERATIONAL",
        "geometry": {
          "location": {"lat": 10.7574897, "lng": 79.1120679},
          "viewport": {
            "northeast": {"lat": 10.75883747989272, "lng": 79.11341477989272},
            "southwest": {"lat": 10.75613782010728, "lng": 79.11071512010727}
          }
        },
        "icon":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/generic_business-71.png",
        "icon_background_color": "#7B9EB0",
        "icon_mask_base_uri":
            "https://maps.gstatic.com/mapfiles/place_api/icons/v2/generic_pinlet",
        "name": "VelTam",
        "opening_hours": {"open_now": true},
        "photos": [
          {
            "height": 4640,
            "html_attributions": [
              "<a href=\"https://maps.google.com/maps/contrib/112097577530498879180\">karthik</a>"
            ],
            "photo_reference":
                "AdDdOWpAYnvZfiC48bk_wm19o794Sd3tDlXfe-1uSnwUJow4jcxIf1ltOdAfbIH3kwVO94gzl_b3hHVSv2mzBR6u7w6YkLZOeS0DDgtpqY9I1pYNZ-z30p8qk-vtf9hvMLiDGkR80KCvOfTPZN2lHJYep0k9zg8bfL9lOO1luVJheCnagmYf",
            "width": 3472
          }
        ],
        "place_id": "ChIJuezpxga5qjsRYwWkEOFLLAM",
        "plus_code": {
          "compound_code": "Q456+2V Thanjavur, Tamil Nadu",
          "global_code": "7J2XQ456+2V"
        },
        "rating": 4.5,
        "reference": "ChIJuezpxga5qjsRYwWkEOFLLAM",
        "scope": "GOOGLE",
        "types": ["point_of_interest", "establishment"],
        "user_ratings_total": 37,
        "vicinity": "No75 Rajagopal Moopanar Colony, Indira Nagar, Thanjavur"
      }
    ],
    "status": "OK"
  };

  void getNearbyTurfs() {
    print("calling");
    // print(respData["results"][0]['name']);
    // respData['results'].map((item) {
    //   print(item);
    // });
    List<String> names = [];
    for (int i = 0; i < respData.length; i++) {
      print(respData['results'][i]['name']);
      names.add(respData['results'][i]['name']);
    }
    _loadMoreData(names);
    // respData['results'].map((result) => {print(result)});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNearbyTurfs();
  }

  List<Map<String, dynamic>> nearbyList = [];
  List<Map<String, dynamic>> courtsList = [
    {
      'name': 'Badminton',
      'src': "images/badminton_court.jpg",
    },
    {
      'name': 'Tennis',
      'src': "images/tennis_court.jpg",
    },
    {
      'name': 'Football',
      'src': "images/football.png",
    },
    {
      'name': 'Other Turfs',
      'src': "images/turf_img.jpg",
    },
  ];

  bool loadingData = true;
  bool isEmpty = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // List<DocumentSnapshot> _documents = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _documentLimit = 4; // Number of documents to fetch per page
  DocumentSnapshot? _lastDocument; // To keep track of the last fetched document
  late ScrollController _scrollController = ScrollController();

  Future<void> fetchBookings(List names) async {
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

    await fetchBookings(names); // Your existing data fetch method

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
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  // controller: _scrollController,
                                  scrollDirection: Axis.horizontal,
                                  physics: AlwaysScrollableScrollPhysics(),
                                  itemCount: _isLoading
                                      ? nearbyList.length + 1
                                      : nearbyList.length,
                                  itemBuilder: (context, index) {
                                    if (index < nearbyList.length) {
                                      // Replace with your booking item widget
                                      return NearbyTile(nearbyList[index],
                                          widget.userDetails);
                                    } else if (_isLoading) {
                                      return Skeletonizer(
                                        enabled: true,
                                        enableSwitchAnimation: true,
                                        child: SportsTile({
                                          'name': "Lorem Ipsum",
                                          'src': 'images/turf_img.jpg',
                                        }, widget.userDetails),
                                      );
                                    }
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
                              "images/turf_img.jpg",
                            )
                          : AssetImage(
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
                    image: turfDetails['src'] == null
                        ? AssetImage(
                            "images/turf_img.jpg",
                          )
                        : AssetImage(
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
