import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/painting.dart';
import 'package:fui_kit/fui_kit.dart';
import 'package:turf_arena/constants.dart';
import 'package:turf_arena/screens/PaymentError.dart';
import 'package:turf_arena/screens/booking_success.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/api/cftheme/cftheme.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'components/ProfileHeader.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:cloud_functions/cloud_functions.dart';

class BookingScreen extends StatefulWidget {
  BookingScreen(this.details, this.userDetails);
  Map details;
  Map userDetails;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
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

class _BookingScreenState extends State<BookingScreen> {
  // Cashfree Payment Instance
  // CFPaymentGatewayService cfPaymentGatewayService = CFPaymentGatewayService();

  late Map paymentData;

  NumberFormat format = NumberFormat.decimalPattern();
  List<String> times = [
    '12 AM',
    '1 AM',
    '2 AM',
    '3 AM',
    '4 AM',
    '5 AM',
    '6 AM',
    '7 AM',
    '8 AM',
    '9 AM',
    '10 AM',
    '11 AM',
    '12 PM',
    '1 PM',
    '2 PM',
    '3 PM',
    '4 PM',
    '5 PM',
    '6 PM',
    '7 PM',
    '8 PM',
    '9 PM',
    '10 PM',
    '11 PM'
  ];

  // var items = [
  //   '9 AM',
  //   '10 AM',
  //   '11 AM',
  //   '12 PM',
  //   '1 PM',
  //   '2 PM',
  //   '3 PM',
  //   '4 PM',
  //   '5 PM',
  //   '6 PM',
  //   '7 PM',
  //   '8 PM',
  //   '9 PM',
  //   '10 PM',
  //   '11 PM',
  //   '12 AM',
  // ];
  // var items2 = ['2024', '2025'];

  late String startValue;
  late String endValue;
  bool disableEverything = false;

  String dropdownvalue2 = '2024';

  late int amount;
  late Map details;

  List<String> bookedTimes = [];
  DateTime now = DateTime.now();
  int status = 0;
  String selectedDate = DateFormat("d - MMM").format(DateTime.now());
  String currentDate = DateFormat("d - MMM").format(DateTime.now());
  String currentTimeStr = DateFormat("h a").format(DateTime.now());

  // String currentTime = inputFormat.parse(DateTime.now().toString()).toString();
  bool isTurfAvailable = true;
  // bool isPaying = false;

  List<String> getTimeList(startTime, endTime) {
    int timeToIndex(String time) {
      return times.indexOf(time);
    }

    // Convert an index to a time string
    String indexToTime(int index) {
      return times[index % times.length];
    }

    int startIndex = timeToIndex(startTime);
    int endIndex = timeToIndex(endTime);

    List<String> result = [];

    // If the end time is after the start time within the same day
    if (startIndex <= endIndex) {
      for (int i = startIndex; i <= endIndex; i++) {
        result.add(indexToTime(i));
      }
    } else {
      // If the end time is before the start time, wrap around midnight
      for (int i = startIndex; i < times.length; i++) {
        result.add(indexToTime(i));
      }
      for (int i = 0; i <= endIndex; i++) {
        result.add(indexToTime(i));
      }
    }

    // print(result);
    return result;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // print(currentTimeStr);
    amount = widget.details['amtPerHour'];
    details = widget.details;
    // startValue = widget.details['startTime'];
    // startValue = currentTimeStr;

    checkAvailablity();
    makeCurrentBefore();
  }

  void makeCurrentBefore() {
    disableEverything = false;
    print(selectedDate);
    print(currentDate);
    if (selectedDate == currentDate) {
      print("Equal Date");
      DateTime curr = DateFormat('h a').parse(currentTimeStr);
      DateTime strt = DateFormat('h a').parse(widget.details['startTime']);

      if (curr.isBefore(strt)) {
        print("Here");
        setState(() {
          startValue = widget.details['startTime'];
        });
        int startIdx = times.indexOf(startValue);
        setState(() {
          endValue = times[startIdx + 1];
        });
      } else {
        print("No Here");
        List<String> list =
            getTimeList(widget.details['startTime'], widget.details['endTime']);
        String lastItem = list[list.length - 2];
        DateTime lastItemDate =
            _adjustForMidnight(DateFormat('h a').parse(lastItem));

        if (curr.isAfter(DateFormat('h a').parse(lastItem)) ||
            DateFormat('h a').format(curr) == lastItem) {
          print("Came Along");
          setState(() {
            startValue = widget.details['startTime'];
          });
          int startIdx = times.indexOf(startValue);
          setState(() {
            endValue = times[startIdx + 1];
            disableEverything = true;
            amount = 0;
          });
          print(amount);
        } else {
          setState(() {
            startValue = DateFormat("h a").format(now.add(
              Duration(minutes: 60),
            ));
            endValue = DateFormat("h a").format(now.add(
              Duration(minutes: 120),
            ));
            // print(times);
            // print(startValue);
            // print(endValue);
          });
        }
      }
      // print(startValue);
    } else {
      print("not equal date");
      setState(() {
        startValue = widget.details['startTime'];
      });
      int startIdx = times.indexOf(startValue);
      setState(() {
        endValue = times[startIdx + 1];
      });
    }
  }

  DateTime _adjustForMidnight(DateTime dateTime) {
    // If the time is '12 AM', adjust it to the next day
    if (dateTime.hour == 0 && dateTime.minute == 0) {
      return dateTime.add(Duration(days: 1));
    }
    return dateTime;
  }

  void checkAvailablity() async {
    // print(selectedDate);
    var state = await isAvailable(selectedDate, startValue, endValue);
    // print(state);
    if (state == false) {
      setState(() {
        amount = 0;
        isTurfAvailable = state;
      });
    } else {
      setState(() {
        // amount = (endInt - startInt) * 1200;
        isTurfAvailable = state;
      });
    }
  }

  void calcAmount(
      String selectedDate, String startValue, String endValue) async {
    // Parsing hour from startValue
    int startInt = int.parse(startValue.split(' ')[0]);
    int endInt = int.parse(endValue.split(' ')[0]);

    // Check if AM or PM for startValue
    if (startValue.contains('PM') && startInt != 12) {
      startInt += 12; // Convert PM hours to 24-hour format
    } else if (startValue.contains('AM') && startInt == 12) {
      startInt = 0; // Convert 12 AM to 0 hours
    }

    // Check if AM or PM for endValue
    if (endValue.contains('PM') && endInt != 12) {
      endInt += 12; // Convert PM hours to 24-hour format
    } else if (endValue.contains('AM') && endInt == 12) {
      endInt += 12; // Convert 12 AM to 0 hours
    }

    // print(startInt.toString() + "Start INt");
    // print(endInt.toString() + "End INt");

    if (startValue == endValue) {
      setState(() {
        // amount = (endInt - startInt) * 1200;
        isTurfAvailable = false;
        amount = 0;
      });
    } else {
      var state = await isAvailable(selectedDate, startValue, endValue);
      // Calculate the amount

      if (state == false) {
        setState(() {
          amount = 0;
          isTurfAvailable = state;
        });
      } else {
        setState(() {
          // print("chance");
          amount = (endInt - startInt) * widget.details['amtPerHour'] as int;
          // print(amount.toString());
          isTurfAvailable = state;
        });
      }
    }

    // print("Amount: $amount");
    // Print or handle the availability state as needed
    // print(isTurfAvailable);
  }

  // void calcAmount(selectedDate, startValue, endValue) async {
  //   int startInt = format.parse(startValue.substring(0, 2)).toInt();
  //   int endInt = format.parse(endValue.substring(0, 2)).toInt();

  //   // amount = (format.parse(endValue.substring(0, 2)).toInt() -
  //   //         format.parse(startValue.substring(0, 2)).toInt()) *
  //   //     1200;

  //   // print(startInt);
  //   // print(endInt);

  //   if (startValue.substring(2, 4) == "PM") {
  //     print("PM raa");

  //     if (startInt != 12) {
  //       startInt = startInt + 12;
  //     }
  //   }
  //   if (startValue[2] == " ") {
  //     if (startValue.substring(3, 5) == "PM") {
  //       if (startInt != 12) {
  //         startInt = startInt + 12;
  //       }
  //     }
  //   }
  //   if (endValue.substring(2, 4) == "PM" || endValue.substring(3, 5) == "PM") {
  //     print("PM raa");
  //     if (endInt != 12) {
  //       endInt = endInt + 12;
  //     }
  //   }

  //   // var state = await isAvailable(selectedDate, startValue, endValue);

  //   setState(() {
  //     amount = (endInt - startInt) * 1200;
  //     // isTurfAvailable = state;
  //   });
  //   print(isTurfAvailable);

  // }

  bool loadingData = false;
  bool isPaid = false;

  Future<void> addBooking(String paymentId, bool status) async {
    CollectionReference bookings =
        FirebaseFirestore.instance.collection('bookings');

    // await Future.delayed(Duration(seconds: 5));

    // Convert to Firestore Timestamp
    Timestamp firestoreTimestamp =
        convertToFirestoreTimestamp(selectedDate, startValue);

    final Map<String, dynamic> newBooking = {
      'bookedTime': FieldValue.serverTimestamp(),
      'turfName': details['name'],
      't_id': details['t_id'],
      'date': firestoreTimestamp,
      'from': startValue,
      'paid': status,
      'amount': amount,
      'payment_id': paymentId,
      'to': endValue,
      'u_id': widget.userDetails['uid'],
    };
    await bookings.doc().set(newBooking);
  }

  // Future<void> getFunction() async {
  //   HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
  //       'createPayment',
  //       options: HttpsCallableOptions(timeout: Duration(seconds: 5)));
  //   final results = await callable();
  //   print('${results.data}');
  // }
  Future<void> getFunction() async {
    print("calling");

    try {
      HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable("getPaymentStatus");
      dynamic resp = await callable.call({
        "order_amount": amount,
        "order_currency": "INR",
        "customer_details": {
          // "customer_uid": widget.userDetails['uid'],
          "customer_id": widget.userDetails['uid'],
          "customer_name":
              widget.userDetails['displayName'] ?? widget.userDetails['email'],
          "customer_email": widget.userDetails['email'],
          "customer_phone": widget.userDetails['phone'] ?? "9393939393",
        },
        "order_meta": {
          "return_url": "https://bookmyturf.netlify.app/",
        },
      });
      print(resp);
      //     if (resp.data['order_status'] == "ACTIVE") {
      //       setState(() {
      //         paymentData = resp.data;
      //         loadingData = false;
      //       });
      //       initatePay();
      //     }
      //   } on FirebaseFunctionsException catch (e) {
      //     // Do clever things with e
      //     print(e.toString());
      //     setState(() {
      //       // paymentData = resp.data;
      //       loadingData = false;
      //     });
      //   } catch (e) {
      //     // Do other things that might be thrown that I have overlooked
      //     print(e.toString());
      //     setState(() {
      //       // paymentData = resp.data;
      //       loadingData = false;
      //     });
      //   }
      // }
      print(resp.data);
      if (resp.data != null) {
        print("Payment response: ${resp.data}");
        // Handle successful payment creation logic here
        if (resp.data['order_status'] == "ACTIVE") {
          setState(() {
            paymentData = resp.data;
            loadingData = false;
            status = 2;
          });
          initatePay();
        }
      }
    } catch (error) {
      if (error is FirebaseFunctionsException) {
        if (error.code == 'unauthenticated') {
          print("User is unauthenticated, trying to reauthenticate...");
          // await reauthenticateUser();

          setState(() {
            // paymentData = resp.data;
            loadingData = false;
          });
        } else {
          print("Error calling createPayment function: ${error.message}");
          setState(() {
            // paymentData = resp.data;
            loadingData = false;
          });
        }
      } else {
        print("Unknown error: $error");
        setState(() {
          // paymentData = resp.data;
          loadingData = false;
        });
      }
    }
  }

  Future<void> getPaymentStatus(String order_id) async {
    print("calling payment status function");

    try {
      HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable("places");
      dynamic resp = await callable.call({"order_id": order_id});
      print(resp.data);
      if (resp.data['order_status'] == "PAID") {
        // initatePay();
        await addBooking(order_id, true);
        setState(() {
          // paymentData = resp.data;
          // loadingData = false;
          isPaid = true;
          status = 3;
        });
        Navigator.of(context).push(
          _createRoute(
            BookingSuccess(),
          ),
        );
      } else if (resp.data['order_status'] == "ACTIVE") {
        Navigator.of(context).push(
          _createRoute(
            PaymentError(),
          ),
        );
        setState(() {
          loadingData = false;
        });
      }
    } on FirebaseFunctionsException catch (e) {
      // Do clever things with e
      print(e.toString());
      // setState(() {
      //   // paymentData = resp.data;
      //   loadingData = false;
      // });
    } catch (e) {
      // Do other things that might be thrown that I have overlooked
      print(e.toString());
      // setState(() {
      //   // paymentData = resp.data;
      //   loadingData = false;
      // });
    }
  }

  void initatePay() {
    try {
      var session = CFSessionBuilder()
          .setEnvironment(CFEnvironment.SANDBOX)
          .setOrderId(paymentData['order_id'])
          .setPaymentSessionId(
            paymentData['payment_session_id'],
          )
          // "session_Ij7QBOgUL6eFiqExx6UqZFl6859P6gwiFvjpaPfDy3HyfZYQopYHOTtS6cdiW8gJPrGEnyIcF1KFa9gfTNoaLjgcRBRPo4wYVceS24sybMny")
          // "session_i5v2OpaVL1LS6fhObiHGpx8D0DOxL1nDLxYKi6Nr5WJR3hfYaQmdvFvxzLTP5IC_TwK9ZBUhW67BijMiA_f4M9aR2Pli18r1mr4_c2uxCIUO")
          // "session_QJRvFcu7-AVWhbev9P1AG2KnyqKKNC-PQe-AaCxwNGSgGiAn2DY2pQaLzhaKYUIT4i0h7GeTe7zVFBymodGXSx5Vu44puqVV-4DBXYqd6I0g")
          .build();

      var theme = CFThemeBuilder()
          .setNavigationBarBackgroundColorColor("#1E293B")
          .setPrimaryFont("Menlo")
          .setSecondaryFont("Futura")
          .build();

      var cfWebCheckout = CFWebCheckoutPaymentBuilder()
          .setSession(session)
          .setTheme(theme)
          .build();
      var cfPaymentGateway = CFPaymentGatewayService();

      cfPaymentGateway.setCallback((order_id) {
        print(order_id);

        getPaymentStatus(order_id);
        Navigator.pop(context);
      }, (error, order_id) {
        print(error.getMessage());
        Navigator.of(context).push(
          _createRoute(
            PaymentError(),
          ),
        );
        // addBooking(order_id, false);
        setState(() {
          loadingData = false;
        });
        // print(order_id);
      });
      cfPaymentGateway.doPayment(cfWebCheckout);
    } catch (e) {
      print("Error :" + e.toString());
      Navigator.of(context).push(
        _createRoute(
          PaymentError(),
        ),
      );
      setState(() {
        loadingData = false;
      });
    }
  }

  void showBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            color: Colors.transparent,
            height: 300,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    height: 5.0,
                    width: MediaQuery.of(context).size.width / 4,
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40.0),
                        topRight: Radius.circular(40.0),
                      ),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 30.0,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          // mainAxisSize: MainAxisSize.center,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Container(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Confirm Booking",
                                      style: TextStyle(
                                        fontSize: 17.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () => Navigator.pop(context),
                                        icon: Icon(
                                          Icons.cancel,
                                          size: 30.0,
                                          color: Colors.red,
                                        ))
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Expanded(
                              flex: 3,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    height: double.infinity,
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "On",
                                              style: TextStyle(
                                                color: primaryColor,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              selectedDate,
                                              style: TextStyle(
                                                color: primaryColor,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        // color:
                                        // Color.fromARGB(
                                        // 255,
                                        // 148,
                                        // 219,
                                        // 252),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      height: double.infinity,
                                      child: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Center(
                                          child: Text(
                                            "Game Starts From " +
                                                startValue +
                                                " to " +
                                                endValue +
                                                " at " +
                                                widget.details['name'],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: primaryColor,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        child: Text(
                                          "₹ " + amount.toString(),
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w600,
                                              color: primaryColor),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // initatePay();
                                          setState(() {
                                            loadingData = true;
                                            status = 1;
                                          });
                                          !isPaid ? getFunction() : null;
                                          // getPaymentStatus(
                                          //     "order_103321992qUmD3WjKQj43YCKmzrj7vCSN6l");

                                          // addBooking();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              15.0,
                                            ),
                                          ),
                                          fixedSize: Size(100.0, 55.0),
                                          backgroundColor: isPaid
                                              ? Colors.green
                                              : Colors.blue,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: loadingData
                                              ? Transform.scale(
                                                  scale: 0.7,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: whiteColor,
                                                  ),
                                                )
                                              : isPaid
                                                  ? Text(
                                                      "Paid",
                                                      style: TextStyle(
                                                        color: whiteColor,
                                                        fontSize: 18.0,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    )
                                                  : Text(
                                                      "Pay Now",
                                                      style: TextStyle(
                                                        color: whiteColor,
                                                        fontSize: 18.0,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                        ),
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
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  /// Function to generate an array of times between startTime and endTime
  List<String> generateTimeRange(String startTime, String endTime) {
    List<String> times = [];
    List<String> hours = [
      "12 AM",
      "1 AM",
      "2 AM",
      "3 AM",
      "4 AM",
      "5 AM",
      "6 AM",
      "7 AM",
      "8 AM",
      "9 AM",
      "10 AM",
      "11 AM",
      "12 PM",
      "1 PM",
      "2 PM",
      "3 PM",
      "4 PM",
      "5 PM",
      "6 PM",
      "7 PM",
      "8 PM",
      "9 PM",
      "10 PM",
      "11 PM"
    ];

    int startIdx = hours.indexOf(startTime);
    int endIdx = hours.indexOf(endTime);

    // print("Start index for $startTime: $startIdx");
    // print("End index for $endTime: $endIdx");

    // Check if startTime and endTime are valid entries in the hours list
    if (startIdx == -1 || endIdx == -1) {
      throw FormatException(
          "Invalid start or end time. Ensure times like '8 AM' or '10 PM' are correctly formatted.");
    }

    // Ensure startIdx is within bounds of hours list length
    if (startIdx < 0 ||
        startIdx >= hours.length ||
        endIdx < 0 ||
        endIdx >= hours.length) {
      throw RangeError(
          "Time index out of bounds. Ensure that the times are valid.");
    }

    // Ensure startIdx is before or equal to endIdx
    // if (startIdx > endIdx) {
    //   throw RangeError("Start time must be earlier than or equal to end time.");
    // }

    // Generate times between start and end times inclusively
    for (int i = startIdx; i < endIdx; i++) {
      times.add(hours[i]);
      // print("Added time: ${hours[i]}");
    }

    // print("Generated time range: $times");
    return times;
  }

  // /// Checks availability for a new booking
  // Future<bool> isAvailable(
  //     String date, String newStartTime, String newEndTime) async {
  //   // Firestore collection reference

  //   final bookings = FirebaseFirestore.instance.collection('bookings');

  //   // Convert to Firestore Timestamp
  //   Timestamp firestoreTimestamp =
  //       convertToFirestoreTimestamp(selectedDate, startValue);

  //   // Query Firestore for all bookings on the specified date
  //   QuerySnapshot snapshot = await bookings
  //       .where('turfName', isEqualTo: widget.details['name'])
  //       .where('date', isEqualTo: firestoreTimestamp)
  //       // .where('paid', isEqualTo: true)
  //       .get();

  //   // List to store all booked time intervals for that date
  //   List<String> bookedTimes = [];

  //   // Populate bookedTimes list with intervals from each existing booking
  //   for (var doc in snapshot.docs) {
  //     String from = doc['from'];
  //     String to = doc['to'];
  //     bookedTimes.addAll(generateTimeRange(from, to));
  //   }
  //   print("Booked : " + bookedTimes.toString());
  //   // Create intervals for the new booking

  //   List<String> newBookingIntervals =
  //       generateTimeRange(newStartTime, newEndTime);
  //   print(newBookingIntervals);
  //   // Check if any of the new booking times are in the already booked times
  //   for (String time in newBookingIntervals) {
  //     if (bookedTimes.contains(time)) {
  //       return false; // Not available if any time overlap exists
  //     }
  //   }

  //   return true; // Available if no overlap
  // }

  DateTime parseAndFormatDate(String date) {
    try {
      // Remove extra spaces and handle the format "12 - Dec"
      date = date.replaceAll(' - ', ' ');

      // Parse the date in the format "d MMM" (e.g., "12 Dec")
      DateFormat parseFormat = DateFormat('d MMM');
      DateTime parsedDate = parseFormat.parse(date);

      // Set the year (assuming the current year, or use a fixed year)
      DateTime finalDate =
          DateTime(DateTime.now().year, parsedDate.month, parsedDate.day);

      return finalDate;
    } catch (e) {
      print("Error parsing date: $e");
      return DateTime.now(); // Return current date if there's an error
    }
  }

  Future<Set<String>> getBookedData(
      String date, String newStartTime, String newEndTime) async {
    DateTime parsedDate = parseAndFormatDate(date);

    DateTime startOfDay =
        DateTime(parsedDate.year, parsedDate.month, parsedDate.day, 0, 0, 0);
    DateTime endOfDay =
        DateTime(parsedDate.year, parsedDate.month, parsedDate.day, 23, 59, 59);

    // Convert to Firestore Timestamps
    Timestamp startTimestamp = Timestamp.fromDate(startOfDay);
    Timestamp endTimestamp = Timestamp.fromDate(endOfDay);

    final bookings = FirebaseFirestore.instance.collection('bookings');
    QuerySnapshot snapshot = await bookings
        .where('turfName', isEqualTo: widget.details['name'])
        .where('date', isGreaterThanOrEqualTo: startTimestamp)
        .where('date', isLessThanOrEqualTo: endTimestamp)
        .get();

    Set<String> bookedList = {};

    // Populate bookedTimes set with intervals from each existing booking
    print(snapshot.docs.isEmpty);
    for (var doc in snapshot.docs) {
      String from = doc['from'];
      String to = doc['to'];
      bookedList.addAll(generateTimeRange(from, to));
    }

    return bookedList;
  }

  /// Checks availability for a new booking
  Future<bool> isAvailable(
      String date, String newStartTime, String newEndTime) async {
    // Firestore collection reference

    // Convert to Firestore Timestamp
    // Timestamp firestoreTimestamp = convertToFirestoreTimestamp(selectedDate,startValue);

    // print(date);

    // Query Firestore for bookings within the date range

    // List to store all booked time intervals for that date
    Set<String> bookedData =
        await getBookedData(date, newStartTime, newEndTime);
    setState(() {
      bookedTimes = bookedData.toList();
    });

    // print("Booked : $bookedTimes");

    // Create intervals for the new booking
    List<String> newBookingIntervals =
        generateTimeRange(newStartTime, newEndTime);
    // print("New Booking: $newBookingIntervals");

    // Check for any overlap
    for (String time in newBookingIntervals) {
      if (bookedTimes.contains(time)) {
        return false; // Not available if any time overlap exists
      }
    }

    return true; // Available if no overlap
  }

  Timestamp convertToFirestoreTimestamp(String dateString, String timeString) {
    try {
      // Parse the date from the format "9 - Dec"
      DateTime parsedDate = DateFormat("d - MMM").parse(dateString);

      // Parse the time from the format "7 AM"
      DateTime parsedTime = DateFormat("h a").parse(timeString);

      // Combine date and time into a single DateTime object
      DateTime fullDateTime = DateTime(
        DateTime.now().year, // Use the current year
        parsedDate.month,
        parsedDate.day,
        parsedTime.hour,
        parsedTime.minute,
      );

      // Convert to Firestore Timestamp
      return Timestamp.fromDate(fullDateTime);
    } catch (e) {
      print("Error converting date and time: $e");
      throw e;
    }
  }

  void showInfoSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: 300.0,
          width: double.infinity,
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50.0),
              topRight: Radius.circular(50.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 30.0,
              horizontal: 30.0,
            ),
            child: Column(
              spacing: 10.0,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Info",
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.cancel,
                          size: 30.0,
                          color: Colors.red,
                        ))
                  ],
                ),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      margin: EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[350],
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 14.0,
                        ),
                        child: Text(
                          "9 AM",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 30.0,
                    ),
                    Text(
                      "Available Slots",
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 15.0,
                      ),
                    ),
                  ],
                ),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      margin: EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 14.0,
                        ),
                        child: Text(
                          "9 AM",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 30.0,
                    ),
                    Text(
                      "Booked Slots",
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 15.0,
                      ),
                    ),
                  ],
                ),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      margin: EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 14.0,
                        ),
                        child: Text(
                          "9 AM",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 30.0,
                    ),
                    Text(
                      "Selected Slots",
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 15.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 70.0,
        leading: Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            bottom: 5.0,
          ),
          child: Container(
            // height: 50.0,
            decoration: BoxDecoration(
              color: Colors.grey[300]!.withOpacity(0.9),
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: primaryColor,
                // color: whiteColor,
                size: 22.0,
              ),
            ),
          ),
        ),
        backgroundColor: whiteColor,
      ),
      backgroundColor: whiteColor,
      body: Container(
        color: Colors.grey[300],
        // decoration: BoxDecoration(
        //   image: DecorationImage(
        //     image: AssetImage("images/grass_bg.jpg"),
        //     repeat: ImageRepeat.repeatX,
        //     fit: BoxFit.cover,
        //     opacity: 0.6,
        //   ),
        // ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 1.4,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(60.0),
                    bottomRight: Radius.circular(60.0),
                  )),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 30.0,
                  right: 30.0,
                  bottom: 10.0,
                  // top: 30.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  spacing: 20.0,
                  children: [
                    // ProfileHeader(),
                    Text(
                      "Grab your Slots! ",
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      // height: 70.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(
                            16.0,
                          )),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 8.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: DateTile(
                                // "Turf Trichy",
                                DateFormat("d - MMM").format(DateTime.now()),
                                DateFormat("d").format(
                                  DateTime.now(),
                                ),
                                (date) {
                                  setState(() {
                                    selectedDate = date;
                                  });
                                  // checkAvailablity();
                                  makeCurrentBefore();
                                  calcAmount(
                                    selectedDate,
                                    startValue,
                                    endValue,
                                  );
                                },
                                selectedDate,
                              ),
                            ),
                            SizedBox(width: 5.0),
                            Expanded(
                              child: DateTile(
                                // widget.turfTitle,
                                DateFormat("d - MMM").format(
                                    DateTime.now().add(Duration(days: 1))),
                                DateFormat("d").format(
                                  DateTime.now().add(Duration(days: 1)),
                                ),
                                (date) {
                                  setState(() {
                                    selectedDate = date;
                                  });
                                  // checkAvailablity();
                                  makeCurrentBefore();
                                  calcAmount(
                                      selectedDate, startValue, endValue);
                                },
                                selectedDate,
                              ),
                            ),
                            SizedBox(width: 5.0),
                            Expanded(
                              child: DateTile(
                                // widget.turfTitle,
                                DateFormat("d - MMM").format(
                                    DateTime.now().add(Duration(days: 2))),
                                DateFormat("d").format(
                                  DateTime.now().subtract(Duration(days: 2)),
                                ),
                                (date) {
                                  setState(() {
                                    selectedDate = date;
                                  });
                                  // checkAvailablity();
                                  makeCurrentBefore();
                                  calcAmount(
                                      selectedDate, startValue, endValue);
                                },
                                selectedDate,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      // decoration: BoxDecoration(
                      // color: whiteColor,
                      // borderRadius: BorderRadius.circular(12.0),
                      // ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16.0),
                        image: DecorationImage(
                          image: AssetImage("images/grass.jpg"),
                          repeat: ImageRepeat.repeatX,
                          // fit: BoxFit.cover,
                          // scale: 1.5,
                          opacity: 0.6,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25.0,
                          vertical: 15.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Timing",
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomDropDown(
                                  "Start",
                                  (String newValue) {
                                    setState(() {
                                      startValue = newValue;
                                    });
                                    calcAmount(
                                        selectedDate, startValue, endValue);
                                  },
                                  startValue,
                                  startValue,
                                  endValue,
                                  getTimeList(
                                      details['startTime'], details['endTime']),
                                ),
                                CustomDropDown("End", (String newValue) {
                                  setState(() {
                                    endValue = newValue;
                                  });
                                  calcAmount(
                                      selectedDate, startValue, endValue);
                                },
                                    endValue,
                                    startValue,
                                    endValue,
                                    getTimeList(details['startTime'],
                                        details['endTime'])),
                              ],
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Slot Availability",
                                  style: TextStyle(
                                    color: whiteColor,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  width: 5.0,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: whiteColor,
                                    borderRadius: BorderRadius.circular(100.0),
                                  ),
                                  child: Icon(
                                    isTurfAvailable
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color: isTurfAvailable
                                        ? Colors.green
                                        : Colors.red,
                                    size: 22.0,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      // height: 300.0,
                      // color: primaryColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Slots",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  showInfoSheet();
                                },
                                icon: FUI(
                                  BoldRounded.INFO,
                                  color: primaryColor,
                                  height: 20.0,
                                  width: 20.0,
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: TimeSlotWidget(
                              bookedTimes: bookedTimes,
                              startValue: widget.details['startTime'],
                              endValue: widget.details['endTime'],
                              newStart: startValue,
                              newEnd: endValue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(
                    50.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: greenColor.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: Offset(0, 1), // changes position of shadow
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                    vertical: 15.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            startValue + " to " + endValue,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Rs. " +
                                ((amount > 0 && !disableEverything)
                                    ? amount.toString()
                                    : "0"),
                            style: TextStyle(
                              color: greenColor,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          // enableFeedback: isTurfAvailable,
                          backgroundColor: isTurfAvailable
                              ? (amount > 0 && !disableEverything)
                                  ? (status == 0)
                                      ? greenColor
                                      : status == 3
                                          ? Colors.green
                                          : greenColor.withOpacity(0.75)
                                  : Colors.grey[400]
                              : Colors.grey[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          fixedSize: Size(165, 50),
                        ),
                        onPressed: () {
                          // showModalBottomSheet<void>
                          final snackBar = SnackBar(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                              30.0,
                            )),
                            margin: EdgeInsets.symmetric(
                              horizontal: 5.0,
                              vertical: 5.0,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 30.0,
                              vertical: 5.0,
                            ),
                            elevation: 50.0,
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.red[400],
                            content: Text(
                              'Please Select Different Slot!',
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            showCloseIcon: true,
                            closeIconColor: whiteColor,
                          );

                          isTurfAvailable
                              ? (amount > 0 && !disableEverything)
                                  ? showBottomSheet()
                                  : null
                              :

                              // Find the ScaffoldMessenger in the widget tree
                              // and use it to show a SnackBar.
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                          ;
                          // initatePay();

                          // addBooking();
                        },
                        iconAlignment: IconAlignment.end,
                        icon: (status != 0 && status != 3)
                            ? Transform.scale(
                                scale: 0.5,
                                child: CircularProgressIndicator(
                                  // value: 0.5,
                                  color: whiteColor.withOpacity(0.7),
                                ),
                              )
                            : status == 3
                                ? Container(
                                    height: 20.0,
                                    width: 20.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50.0),
                                      color: whiteColor,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: FUI(
                                        BoldRounded.CHECK,
                                        color: Colors.green,
                                        height: 12.0,
                                      ),
                                    ),
                                  )
                                : null,
                        label: status == 0
                            ? Text(
                                "Book Now",
                                style: TextStyle(
                                  color: whiteColor,
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : status == 2
                                ? Text(
                                    "Processing",
                                    style: TextStyle(
                                      color: whiteColor,
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                : status == 3
                                    ? Text(
                                        "Booked",
                                        style: TextStyle(
                                          color: whiteColor,
                                          fontSize: 17.0,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      )
                                    : Text(
                                        "Booking",
                                        style: TextStyle(
                                          color: whiteColor,
                                          fontSize: 17.0,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
          ],
        ),
      ),
    );
  }

  Column CustomDropDown(String name, Function callback, String value,
      String selectedStart, String selectedEnd, List<String> timeZones) {
    // void changeState(String? newValue) {
    //   setState(() {
    //     startValue = newValue!;
    //   });
    // }

    // CustomDropDown(
    //   if(){

    //   }
    // );
    List<String> sublist = [];
    if (name == "Start") {
      // print("Start");

      timeZones.add(timeZones.removeLast());
      sublist.add(timeZones.removeLast());
      print(timeZones);
      print(sublist);
    }

    // if (currentDate == selectedDate) {
    //   if (currentTimeStr == timeZones[timeZones.length - 1] ||
    //       DateFormat('h a')
    //           .parse(currentTimeStr)
    //           .isAfter(DateFormat('h a').parse(timeZones.last))) {
    //     setState(() {
    //       selectedStart = timeZones.last;
    //       selectedEnd = sublist.last;
    //     });
    //   }
    // }
    bool greaterTime(String selectedStart, String itemValue, String type) {
      // Ensure both strings have the correct length
      if (selectedStart.length < 4 || itemValue.length < 4) {
        throw FormatException(
            "Time strings must be at least 4 characters long (e.g., 'H AM').");
      }

      // Parse the selected time
      int selectedHour =
          int.parse(selectedStart.substring(0, selectedStart.indexOf(' ')));
      String selectedPeriod =
          selectedStart.substring(selectedStart.indexOf(' ') + 1); // AM or PM

      // Parse the item time
      int itemHour = int.parse(itemValue.substring(0, itemValue.indexOf(' ')));
      String itemPeriod =
          itemValue.substring(itemValue.indexOf(' ') + 1); // AM or PM

      // Convert to a comparable format
      int selectedTotalHours = selectedHour +
          ((selectedPeriod == "PM" && selectedHour != 12) ? 12 : 0);
      int itemTotalHours = itemHour +
          ((itemPeriod == "PM" && itemHour != 12) ||
                  (itemPeriod == "AM" && itemHour == 12)
              ? 12
              : 0);

      // Adjust for 12 AM case
      if (selectedPeriod == "AM" && selectedHour == 12) {
        selectedTotalHours = 0; // 12 AM is 0 hours
      }
      if (itemPeriod == "AM" && itemHour == 12) {
        itemTotalHours = 0; // 12 AM is 0 hours
      }

      // Compare total hours

      if (type == "End") {
        return itemTotalHours <= selectedTotalHours;
      } else {
        return itemTotalHours < selectedTotalHours;
        // return itemTotalHours > selectedTotalHours;
      }
    }

    bool state = true;
    bool checkEnable(String selectedStart, String item) {
      if (selectedDate == currentDate) {
        print("Checking ");
        state = greaterTime(item, currentTimeStr, "Start");
        print(state);
      }
      // print(state);
      if (name == "End") {
        state = !greaterTime(selectedStart, item, "End");
      }
      return state;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: TextStyle(
            color: whiteColor,
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: greenColor,
            borderRadius: BorderRadius.circular(16.0),
            // border: Border.all(
            //   width: 1.5,
            //   color: greyColor,
            // ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 2.0,
              horizontal: 12.0,
            ),
            child: DropdownButton(
              borderRadius: BorderRadius.circular(18.0),

              menuMaxHeight: 200,
              alignment: Alignment.topCenter,
              underline: SizedBox(),
              // Initial Value
              value: value,
              dropdownColor: greenColor,
              // Down Arrow Icon
              icon: const Icon(Icons.keyboard_arrow_down),
              iconEnabledColor: whiteColor,
              // Array list of items
              disabledHint: Text(""),
              items: timeZones.map((String items) {
                // print(items);
                // print(selectedStart);
                return DropdownMenuItem(
                  enabled: disableEverything
                      ? false
                      : checkEnable(selectedStart, items),
                  value: items,
                  child: Text(
                    items,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: disableEverything
                          ? Color.fromARGB(143, 213, 213, 213)
                          : checkEnable(selectedStart, items)
                              ? whiteColor
                              : Color.fromARGB(143, 213, 213, 213),
                    ),
                  ),
                  // child: name == "End"
                  //     ? format.parse(items.substring(0, 2)).toInt() >
                  //             format
                  //                 .parse(selectedStart.substring(0, 2))
                  //                 .toInt()
                  //         ? Text(items)
                  //         : Text("")
                  //     : Text(items),
                );
              }).toList(),
              // After selecting the desired option,it will
              // change button value to selected value
              onChanged: (String? newValue) {
                // changeState(newValue);
                callback(newValue);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class DateTile extends StatelessWidget {
  DateTile(this.date, this.onlyDate, this.callback, this.selectedDate);
  final String date;
  final String selectedDate;
  final String onlyDate;
  final Function callback;
  // final String turfName;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: selectedDate == date ? greenColor : Colors.grey[300],
        // side: BorderSide(
        //   width: 2.0,
        //   color: scaffoldColor,
        // ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            8.0,
          ),
        ),
      ),
      onPressed: () {
        callback(date);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
            // horizontal: 4.0,
            // vertical: 2.0,
            ),
        child: Text(
          date,
          // date.substring(0, 2),
          // DateFormat("d - MMM")
          // .format(DateTime.now().subtract(Duration(days: 1))),
          // DateTime.now().toString(),
          style: TextStyle(
            color: selectedDate == date ? whiteColor : primaryColor,
            fontSize: 17.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

bool greaterTime(String selectedStart, String itemValue) {
  // Ensure both strings have the correct length
  if (selectedStart.length < 4 || itemValue.length < 4) {
    throw FormatException(
        "Time strings must be at least 4 characters long (e.g., 'H AM').");
  }

  // Parse the selected time
  int selectedHour =
      int.parse(selectedStart.substring(0, selectedStart.indexOf(' ')));
  String selectedPeriod =
      selectedStart.substring(selectedStart.indexOf(' ') + 1); // AM or PM

  // Parse the item time
  int itemHour = int.parse(itemValue.substring(0, itemValue.indexOf(' ')));
  String itemPeriod =
      itemValue.substring(itemValue.indexOf(' ') + 1); // AM or PM

  // Convert to a comparable format
  int selectedTotalHours =
      selectedHour + ((selectedPeriod == "PM" && selectedHour != 12) ? 12 : 0);
  int itemTotalHours = itemHour +
      ((itemPeriod == "PM" && itemHour != 12) ||
              (itemPeriod == "AM" && itemHour == 12)
          ? 12
          : 0);

  // Adjust for 12 AM case
  if (selectedPeriod == "AM" && selectedHour == 12) {
    selectedTotalHours = 0; // 12 AM is 0 hours
  }
  // if (itemPeriod == "AM" && itemHour == 12) {
  // itemTotalHours = 24; // 12 AM is 0 hours
  // }

  // Compare total hours
  return itemTotalHours <= selectedTotalHours;
}

class TimeSlotWidget extends StatelessWidget {
  final List<String> bookedTimes;
  final String startValue;
  final String endValue;
  final String newStart;
  final String newEnd;
  const TimeSlotWidget({
    required this.bookedTimes,
    required this.startValue,
    required this.endValue,
    required this.newStart,
    required this.newEnd,
  });

  // bool isTimeInRange(String time, String newStart, String newEnd) {
  //   DateFormat inputFormat = DateFormat('h a'); // Handle time with minutes
  //   try {
  //     DateTime startTime = inputFormat.parse(newStart);
  //     DateTime endTime = inputFormat.parse(newEnd);
  //     DateTime currentTime = inputFormat.parse(time);

  //     return (currentTime.isAfter(startTime) &&
  //             currentTime.isBefore(endTime)) ||
  //         currentTime == startTime ||
  //         currentTime == endTime;
  //   } catch (e) {
  //     print('Error parsing time in range: $e');
  //     return false;
  //   }
  // }

  bool isTimeInRange(String time, String newStart, String newEnd) {
    DateFormat inputFormat = DateFormat('h a'); // Handle time with minutes

    try {
      // Check if the times are '12 AM' and adjust to the next day
      DateTime startTime = _adjustForMidnight(inputFormat.parse(newStart));
      DateTime endTime = _adjustForMidnight(inputFormat.parse(newEnd));
      DateTime currentTime = _adjustForMidnight(inputFormat.parse(time));

      return (currentTime.isAfter(startTime) &&
              currentTime.isBefore(endTime)) ||
          currentTime == startTime ||
          currentTime == endTime;
    } catch (e) {
      print('Error parsing time in range: $e');
      return false;
    }
  }

  DateTime _adjustForMidnight(DateTime dateTime) {
    // If the time is '12 AM', adjust it to the next day
    if (dateTime.hour == 0 && dateTime.minute == 0) {
      return dateTime.add(Duration(days: 1));
    }
    return dateTime;
  }

  @override
  Widget build(BuildContext context) {
    // Generate all time slots for the day in 15-minute intervals
    List<String> allTimeSlots =
        generateTimeSlots(startValue, endValue, bookedTimes);

    return GestureDetector(
      onTap: () {
        print("Tapped");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
              30.0,
            )),
            margin: EdgeInsets.symmetric(
              horizontal: 5.0,
              vertical: 5.0,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 30.0,
              vertical: 5.0,
            ),
            elevation: 50.0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: primaryColor.withOpacity(0.8),
            content: Text(
              'Please Use Slot DropDown!',
              style: TextStyle(
                color: whiteColor.withOpacity(0.7),
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.start,
            ),
            showCloseIcon: true,
            closeIconColor: whiteColor,
          ),
        );
      },
      child: GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, // Adjust based on UI requirements
          childAspectRatio: 2,
        ),
        itemCount: allTimeSlots.length,
        itemBuilder: (context, index) {
          String time = allTimeSlots[index];
          bool isBooked = bookedTimes.contains(time);
          bool isInBookingRange = !greaterTime(newStart, newEnd)
              ? isTimeInRange(time, newStart, newEnd)
              : false;

          // bool isBooking = bookedTimes.contains()

          return Container(
            margin: EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: isBooked
                  ? Colors.red
                  : isInBookingRange
                      ? Colors.green
                      : Colors.grey[350],
              borderRadius: BorderRadius.circular(10.0),
            ),
            alignment: Alignment.center,
            child: Text(
              time,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}

List<String> generateTimeSlots(
    String start, String end, List<String> bookedTimes) {
  List<String> timeSlots = [];
  DateFormat inputFormat = DateFormat('h a'); // Handle "7 AM", "11 PM"
  DateFormat outputFormat = DateFormat('h:mm a'); // Standardize output format

  try {
    // Parse start and end times into DateTime objects
    DateTime startTime = inputFormat.parse(start);

    DateTime endTime = inputFormat.parse(end);
    if (endTime.hour == 0 && endTime.minute == 0) {
      endTime = endTime.add(Duration(days: 1));
    }

    // Generate time slots
    while (startTime.isBefore(endTime) || startTime == endTime) {
      timeSlots.add(inputFormat.format(startTime));
      startTime =
          startTime.add(Duration(minutes: 60)); // Increment by 60 minutes
    }

    // print(timeSlots);
  } catch (e) {
    print('Error parsing time: $e');
  }
  return timeSlots;
}
