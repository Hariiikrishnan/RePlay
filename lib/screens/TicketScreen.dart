import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:turf_arena/constants.dart';

class Ticketscreen extends StatefulWidget {
  const Ticketscreen(this.details);
  final Map details;
  @override
  State<Ticketscreen> createState() => _TicketscreenState();
}

class _TicketscreenState extends State<Ticketscreen> {
  bool loadingData = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
    print(widget.details);
  }

  void fetchData() async {
    await fetchByName();
  }

  late Map<String, dynamic> turfData;

  Future<void> fetchByName() {
    CollectionReference turfs = FirebaseFirestore.instance.collection('turfs');

    // await Future.delayed(Duration(seconds: 5));

    return turfs
        .where('t_id', isEqualTo: widget.details['t_id'])
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isEmpty) {
      } else {
        setState(() {
          // Store the document data into the list
          loadingData = false;
          turfData = snapshot.docs[0].data() as Map<String, dynamic>;
        });
        print(loadingData);
        print(turfData);
        // print('${doc.id} => ${doc.data()}');
      }
    }).catchError((error) {
      print("Error getting documents: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return loadingData
        ? TicketLoading()
        : TicketScreenWidget(widget.details, turfData);
  }
}

class TicketLoading extends StatelessWidget {
  const TicketLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: greenColor,
      body: Container(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 40.0,
          ),
          child: Column(
            spacing: 10.0,
            children: [
              Row(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      "Ticket",
                      style: TextStyle(
                        color: whiteColor,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5.0,
              ),
              Skeletonizer(
                enabled: true,
                enableSwitchAnimation: true,
                child: BookingWidget({
                  'turfName': "Lorem Ipsum",
                  'date': Timestamp.now(),
                  'bookedTime': "",
                  "from": "7 AM",
                  "to": "8 AM",
                  'paid': true,
                  'amount': '',
                  'id': "fusenfuvskfuvitint",
                }, {
                  'address':
                      "Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum"
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TicketScreenWidget extends StatelessWidget {
  const TicketScreenWidget(this.details, this.turfData);
  final Map details;
  final Map turfData;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: greenColor,
        body: Container(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              top: 40.0,
            ),
            child: Column(
              spacing: 10.0,
              children: [
                Row(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        "Ticket",
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('d MMM yy,hh:mm a').format(
                        DateTime.parse(
                            details['bookedTime'].toDate().toString()),
                      ),
                      style: TextStyle(
                        color: Colors.grey[100],
                        fontSize: 15.0,
                      ),
                    ),
                  ],
                ),
                BookingWidget(details, turfData),
              ],
            ),
          ),
        ));
  }
}

class BookingWidget extends StatelessWidget {
  BookingWidget(this.details, this.turfData);
  Map details;
  Map turfData;

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 50.0,
      // width: MediaQuery.of(context).size.width / 1.1,
      // height: 250.0,
      decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(
            8.0,
          )),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
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
                height: 100.0,
              ),
              Container(
                height: 25.0,
                width: 15.0,
                decoration: BoxDecoration(
                    color: greenColor,
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
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 25.0,
                horizontal: 10.0,
              ),
              child: Column(
                spacing: 10.0,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            details['turfName'],
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                DateFormat('MMM d').format(
                                  DateTime.parse(
                                      details['date'].toDate().toString()),
                                ),
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(
                                width: 15.0,
                              ),
                              Text(
                                "From " +
                                    details['from'] +
                                    " to " +
                                    details['to'],
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        height: 50.0,
                        width: 50.0,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Center(
                          child: Text(
                            DateFormat('h a')
                                    .parse(details['to'])
                                    .difference(DateFormat('h a')
                                        .parse(details['from']))
                                    .inHours
                                    .toString() +
                                "H",
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    ],
                  ),
                  Container(
                    // width: 2.0,
                    height: 10.0, // Adjust this to your desired height
                    decoration: BoxDecoration(
                      border: Border(),
                    ),
                    child: Row(
                      children: List.generate(
                        18, // Number of dots
                        (index) => Expanded(
                          flex: 1,
                          child: Container(
                            height: 1.5,
                            // height: 15.0,
                            margin: index == 9
                                ? EdgeInsets.only(right: 6.0)
                                : EdgeInsets.only(right: 8.0),
                            color: Colors.grey[300],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    turfData['address'],
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    // width: 2.0,
                    height: 10.0, // Adjust this to your desired height
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
                    child: Row(
                      children: List.generate(
                        18, // Number of dots
                        (index) => Expanded(
                          flex: 1,
                          child: Container(
                            height: 1.5,
                            // height: 15.0,
                            margin: index == 9
                                ? EdgeInsets.only(right: 6.0)
                                : EdgeInsets.only(right: 8.0),
                            color: Colors.grey[300],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "Booking ID: ",
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 15.0,
                        ),
                      ),
                      SelectableText(
                        details['id'],
                        style: TextStyle(
                          color: const Color.fromARGB(255, 45, 22, 226),
                          fontSize: 15.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 5.0,
                    children: [
                      Text(
                        "Status : " + (details['paid'] ? " Success" : "Failed"),
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        details['paid'] ? Icons.check_circle : Icons.cancel,
                        color: details['paid'] ? Colors.green : Colors.red,
                        size: 22.0,
                      ),
                    ],
                  ),
                  Container(
                    // width: 2.0,
                    height: 10.0, // Adjust this to your desired height
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
                    child: Row(
                      children: List.generate(
                        18, // Number of dots
                        (index) => Expanded(
                          flex: 1,
                          child: Container(
                            height: 1.5,
                            // height: 15.0,
                            margin: index == 9
                                ? EdgeInsets.only(right: 6.0)
                                : EdgeInsets.only(right: 8.0),
                            color: Colors.grey[300],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Paid ₹" + details['amount'].toString(),
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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
                height: 100.0,
              ),
              Container(
                height: 25.0,
                width: 15.0,
                decoration: BoxDecoration(
                    color: greenColor,
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
    );
  }
}
