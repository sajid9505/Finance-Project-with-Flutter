import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:finance_tracker_mobile_application/controller/form_controller.dart';
import 'package:finance_tracker_mobile_application/model/form.dart';

// class HomeCard extends StatelessWidget {
//   const HomeCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         title: 'Feedback Responses',
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//         ),
//         home: const HomeCardPage(title: "Responses"));
//   }
// }

// class HomeCardPage extends StatefulWidget {
//   const HomeCardPage({Key? key, required this.title}) : super(key: key);

//   final String title;

//   @override
//   // ignore: library_private_types_in_public_api
//   _HomeCardPageState createState() => _HomeCardPageState();
// }

// class _HomeCardPageState extends State<HomeCardPage> {
//   // const HomeCard({super.key});

//     List<FeedbackForm> feedbackItems = [];

// //   // Method to Submit Feedback and save it in Google Sheets

//   @override
//   void initState() {
//     super.initState();

//     FormController().getFeedbackList().then((feedbackItems) {
//       setState(() {
//         this.feedbackItems = feedbackItems;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         width: double.infinity,
//         height: MediaQuery.of(context).size.height * 0.5,
//         margin: const EdgeInsets.all(16.0),
//         child: Card(
//           color: const Color.fromARGB(255, 2, 54, 97),
//           child: Stack(
//             children: [
//               SizedBox(
//                 width: double.infinity,
//                 height: double.infinity,
//                 child: SvgPicture.asset(
//                   'assets/BackgroundCard.svg',
//                   fit: BoxFit.cover,
//                   color: Colors.black,
//                 ),
//               ),
//               Positioned(
//                 // top: 16, // Adjust the top position as needed
//                 // left: 55, // Adjust the left position as needed
//                 child: Center(
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 16), // Add margin at the top
//                       ClipOval(
//                         child: Image.asset(
//                           'assets/Avatar.jpg',
//                           width: 100,
//                           height: 100,
//                           fit: BoxFit
//                               .cover, // Ensure the image covers the circular area
//                         ),
//                       ),
//                       const SizedBox(height: 16), // Add margin at the top
//                       const Text(
//                         'Your available balance is',
//                         style: TextStyle(
//                           fontSize: 15,
//                           color: Colors.white70,
//                         ),
//                       ),
//                       const Text(
//                         // '20,983 TK',
//                         "${feedbackItems[index].actualBalance}"
//                         style: TextStyle(
//                           fontSize: 45,
//                           fontWeight: FontWeight.w800,
//                           color: Colors.white70,
//                         ),
//                       ),
//                       Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 16.0),
//                         child: const Text(
//                           'By this time last month you spent slightly higher (22,719 TK)',
//                           style: TextStyle(
//                             fontSize: 15,
//                             color: Colors.white70,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                       const SizedBox(height: 16), // Add margin at the top
//                       DataTable(
//                         columns: const <DataColumn>[
//                           DataColumn(
//                             label: Expanded(
//                               child: Text(
//                                 'Recent Transactions',
//                                 style: TextStyle(color: Colors.white),
//                               ),
//                             ),
//                           ),
//                           DataColumn(
//                             label: Expanded(
//                               child: Text(
//                                 '',
//                                 style: TextStyle(fontStyle: FontStyle.italic),
//                               ),
//                             ),
//                           ),
//                         ],
//                         rows: const <DataRow>[
//                           DataRow(
//                             cells: <DataCell>[
//                               DataCell(Text(
//                                 'Bkash',
//                                 style: TextStyle(color: Colors.white70),
//                               )),
//                               DataCell(Text(
//                                 '12,000 TK',
//                                 style: TextStyle(color: Colors.white70),
//                               )),
//                             ],
//                           ),
//                           DataRow(
//                             cells: <DataCell>[
//                               DataCell(Text(
//                                 'Maa Pharmacy',
//                                 style: TextStyle(color: Colors.white70),
//                               )),
//                               DataCell(Text(
//                                 '1,245 TK',
//                                 style: TextStyle(color: Colors.white70),
//                               )),
//                             ],
//                           ),
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//               // Add more widgets on top as needed
//             ],
//           ),
//         ),
//       );
//   }
// }

//// New Code here
///
class HomeCardPage extends StatefulWidget {
  const HomeCardPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  // ignore: library_private_types_in_public_api
  _HomeCardPageState createState() => _HomeCardPageState();
}

class _HomeCardPageState extends State<HomeCardPage> {
  FeedbackForm? feedback;

  @override
  void initState() {
    super.initState();

    FormController().getFeedback().then((feedback) {
      setState(() {
        this.feedback = feedback;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.5,
      margin: const EdgeInsets.all(16.0),
      child: Card(
        color: const Color.fromARGB(255, 2, 54, 97),
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: SvgPicture.asset(
                'assets/BackgroundCard.svg',
                fit: BoxFit.cover,
                color: Colors.black,
              ),
            ),
            Positioned(
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    ClipOval(
                      child: Image.asset(
                        'assets/Avatar.jpg',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your available balance is',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '${feedback?.actualBalance ?? 0} TK',
                      style: const TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.w800,
                        color: Colors.white70,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: const Text(
                        'By this time last month you spent slightly higher (22,719 TK)',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DataTable(
                      columns: const <DataColumn>[
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              'Recent Transactions',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              '',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                        ),
                      ],
                      rows: const [
                        DataRow(
                          cells: <DataCell>[
                            DataCell(Text(
                              'Bkash',
                              style: TextStyle(color: Colors.white70),
                            )),
                            DataCell(Text(
                              '12,000 TK',
                              style: TextStyle(color: Colors.white70),
                            )),
                          ],
                        ),
                        DataRow(
                          cells: <DataCell>[
                            DataCell(Text(
                              'Maa Pharmacy',
                              style: TextStyle(color: Colors.white70),
                            )),
                            DataCell(Text(
                              '1,245 TK',
                              style: TextStyle(color: Colors.white70),
                            )),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
