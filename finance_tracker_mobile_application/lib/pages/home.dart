import 'package:finance_tracker_mobile_application/components/budget_card.dart';
import 'package:finance_tracker_mobile_application/components/budget_week.dart';
import 'package:finance_tracker_mobile_application/components/home_card.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF10161e), // Set your custom background color
      appBar: AppBar(
        backgroundColor: const Color(
            0xFF10161e), // Set your desired background color for the AppBar
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello Sajid',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            Text(
              'Your finances are looking not so good...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Handle search button press
            },
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Handle settings button press
            },
          ),
        ],
      ),
      body: ListView(
        children: const [
          HomeCard(),
          BudgetCard(),
          BudgetWeek()
          // Add more widgets as needed
        ],
      ),
    );
  }
}
