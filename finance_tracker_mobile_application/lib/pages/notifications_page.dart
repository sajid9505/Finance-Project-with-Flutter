import 'package:finance_tracker_mobile_application/utils/theme/custom_themes/text_theme.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(

        // Chips

        // child: Chip(
        //   label: Text('Tag 1'),
        // ),

        // TextFields

        // child: TextField(
        //   decoration: InputDecoration(
        //     labelText: 'Enter your name', // Placeholder text for the TextField
        //     suffixIcon: Icon(Icons.edit), // Add a pen icon as a suffix
        //   ),
        // ),

        // Text Themes

        child: Text(
          'This is the Notifications Page',
          style: TTextTheme.textTheme.headlineLarge // Apply your custom text style from the theme
        ),

        // Elevated Button Calling

        // child: ElevatedButton.icon(
        //   onPressed: () {
        //     // Add your button press logic here
        //   },
        //   icon: const Icon(Icons.notification_important), // Icon for the button
        //   label: const Text('Continue'),
        // ),

        // Accent Button 
        // child: ButtonTheme(
        //   // data: theme.accentButtonTheme,
        //   child: TextButton(
        //     onPressed: () {
        //       // Add your button press logic here
        //     },
        //     child: const Text(
        //       'Your Button Text',
        //       style: TextStyle(
        //         // Add any custom styles here if needed
        //       ),
        //     ),
        //   ),
        // ),
      ),
    );
  }
}
