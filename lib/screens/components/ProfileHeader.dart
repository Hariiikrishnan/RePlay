import 'package:turf_arena/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileHeader extends StatelessWidget {
  ProfileHeader(this.userDetails, this.txtColor);

  Map userDetails;
  Color txtColor;
  // User? user = userDetails.user;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: 50.0,
          height: 50.0,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(
                userDetails['photoURL'],
              ),
            ),
            border: Border.all(
              width: 1,
              color: Colors.grey[700]!,
            ),
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        SizedBox(
          width: 10.0,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Howdy, ",
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              (userDetails['displayName'] ?? userDetails['email'] ?? ""),
              style: TextStyle(
                color: txtColor,
                // color: greenColor.withOpacity(0.7),
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}



// Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(50.0),
//           bottomRight: Radius.circular(50.0),
//         ),
//         // image: DecorationImage(
//         //   fit: BoxFit.cover,
//         //   opacity: 0.6,
//         //   image: AssetImage(
//         //     "images/grass_bg.jpg",
//         //   ),
//         // ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.only(
//           left: 35.0,
//           right: 35.0,
//           top: 45.0,
//           bottom: 15.0,
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               userDetails['displayName'] ?? userDetails['email'] ?? "",
//               style: TextStyle(
//                 color: whiteColor,
//                 fontSize: 20.0,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//             Container(
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   width: 1.5,
//                   color: whiteColor,
//                 ),
//                 borderRadius: BorderRadius.circular(50.0),
//               ),
//               child: CircleAvatar(
//                 radius: 25.0,
//                 backgroundImage: NetworkImage(
//                   userDetails['photoURL'],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );