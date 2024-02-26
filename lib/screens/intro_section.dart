// import 'package:flutter/material.dart';
// import 'login_screen.dart';

// class IntroSection extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               // Large logo
//               CircleAvatar(
//                 radius: 100,
//                 backgroundImage: AssetImage('assets/dilg-main.png'),
//               ),
//               SizedBox(height: 16),
//               // Text below the logo
//               Text(
//                 'Department of the Interior and Local Government Bohol Province',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 16),
//               // "GET STARTED" button
//               ElevatedButton(
//                 onPressed: () {
//                   // Navigate to the LoginScreen
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) =>
//                           LoginScreen(title: 'Your App Title'),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue, // Dark blue color
//                 ),
//                 child: Text('GET STARTED'),
//               ),
//               SizedBox(height: 16),
//               Text(
//                 '© DILG-Bohol Province 2024',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey,
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }