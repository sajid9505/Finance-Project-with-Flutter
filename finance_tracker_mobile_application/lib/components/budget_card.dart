import 'package:flutter/material.dart';
import 'package:finance_tracker_mobile_application/controller/form_controller.dart';
import 'package:finance_tracker_mobile_application/model/form.dart';

class BudgetCardPage extends StatefulWidget {
  const BudgetCardPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  // ignore: library_private_types_in_public_api
  _BudgetCardPageState createState() => _BudgetCardPageState();
}

class _BudgetCardPageState extends State<BudgetCardPage> {
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
      height: MediaQuery.of(context).size.height * 0.25,
      margin: const EdgeInsets.all(16.0),
      child: Card(
        color: const Color.fromARGB(255, 2, 54, 97),
        child: Stack(
          children: [
            const SizedBox(
              width: double.infinity,
              height: double.infinity,
            ),
            Container(
              margin: const EdgeInsets.all(16.0), // Set the desired margin
              child: Positioned(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2), // Add margin at the top
                      const Text(
                        'Food Budget',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 12), // Add margin at the top
                      Text(
                        '${feedback?.foodSpent ?? 0} TK',
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        'Left out of ${feedback?.foodBudget ?? 0} TK budgeted',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 20), // Add margin at the top
                      LinearProgressIndicator(
                        value: feedback != null
                            ? feedback!.foodSpent / feedback!.foodBudget
                            : 0.0, // Set the progress value between 0.0 and 1.0
                        backgroundColor:
                            Colors.grey, // Set the background color
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color.fromARGB(255, 74, 241, 130),
                        ), // Set the progress bar color
                      ),
                      const SizedBox(height: 30), // Add margin at the top
                      const Text(
                        'Calm down, you are spending too much!',
                        style: TextStyle(
                          fontSize: 15,
                          // fontWeight: FontWeight.w800,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Add more widgets on top as needed
          ],
        ),
      ),
    );
  }
}
