// import 'package:flutter/material.dart';
// import 'package:finance_tracker_mobile_application/controller/form_controller.dart';
// import 'package:finance_tracker_mobile_application/model/form.dart';

// class FeedbackListScreen extends StatelessWidget {
//   const FeedbackListScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         title: 'Feedback Responses',
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//         ),
//         home: const FeedbackListPage(title: "Responses"));
//   }
// }

// class FeedbackListPage extends StatefulWidget {
//   const FeedbackListPage({Key? key, required this.title}) : super(key: key);

//   final String title;

//   @override
//   // ignore: library_private_types_in_public_api
//   _FeedbackListPageState createState() => _FeedbackListPageState();
// }

// class _FeedbackListPageState extends State<FeedbackListPage> {
//   List<FeedbackForm> feedbackItems = [];

//   // Method to Submit Feedback and save it in Google Sheets

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
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: ListView.builder(
//         itemCount: feedbackItems.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             title: Row(
//               children: <Widget>[
//                 const Icon(Icons.person),
//                 Expanded(
//                   child: Text(
//                       "${feedbackItems[index].name} (${feedbackItems[index].email})"),
//                 )
//               ],
//             ),
//             subtitle: Row(
//               children: <Widget>[
//                 const Icon(Icons.message),
//                 Expanded(
//                   child: Text(feedbackItems[index].feedback),
//                 )
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }