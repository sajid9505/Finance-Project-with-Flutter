import 'package:finance_tracker_mobile_application/components/budget_card.dart';
import 'package:finance_tracker_mobile_application/components/cancel_button.dart';
import 'package:finance_tracker_mobile_application/components/light_blue_button.dart';
import 'package:finance_tracker_mobile_application/components/orange_button.dart';
import 'package:finance_tracker_mobile_application/components/whatsapp_button.dart';
import 'package:finance_tracker_mobile_application/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

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

          child: ListView(
        padding: const EdgeInsets.all(TSizes.sm),
        children: [
          Text('This is the Notifications Page',
              style: theme.textTheme
                  .labelLarge // Apply your custom text style from the theme
              ),

          const Padding(padding: EdgeInsets.all(TSizes.md)),

          const CustomWhatsappButtonWidget(
            onPressAction: 'Hello World',
          ),
          
          const Padding(padding: EdgeInsets.all(TSizes.md)),
          
          const BlackButtonWidget(
            title: 'Cancel',
            onPressAction: 'Cancelled',
          ),

          const Padding(padding: EdgeInsets.all(TSizes.md)),
          
          const OrangeButtonWidget(
            title: 'Review',
            onPressAction: 'Reviewed',
            icon: 'Icon',
          ),

          const Padding(padding: EdgeInsets.all(TSizes.md)),
          
          const LightBlueButtonWidget(
            title: 'Details',
            onPressAction: 'Detail viewed',
          ),
        ],
      )

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
