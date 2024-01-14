import 'package:flutter/material.dart';

class BudgetCard extends StatelessWidget {
  const BudgetCard({super.key});

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
              child: const Positioned(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2), // Add margin at the top
                      Text(
                        'Food Budget',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 12), // Add margin at the top
                      Text(
                        '2,900 TK',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        'Left out of 10,000 TK budgeted',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 20), // Add margin at the top
                      LinearProgressIndicator(
                        value:
                            0.5, // Set the progress value between 0.0 and 1.0
                        backgroundColor:
                            Colors.grey, // Set the background color
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Color.fromARGB(255, 74, 241,
                                130)), // Set the progress bar color
                      ),
                      SizedBox(height: 30), // Add margin at the top
                      Text(
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
