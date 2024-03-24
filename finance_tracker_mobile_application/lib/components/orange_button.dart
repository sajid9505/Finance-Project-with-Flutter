import 'package:finance_tracker_mobile_application/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class OrangeButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color color;
  final double elevation;

  const OrangeButton({
    required this.onPressed,
    required this.child,
    this.color = TColors.buttonSecondary,
    this.elevation = 2.0,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      borderRadius: BorderRadius.circular(8.0), // Adjust the radius as needed
      color: color,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: child,
        ),
      ),
    );
  }
}

class OrangeButtonWidget extends StatefulWidget {
  const OrangeButtonWidget(
      {Key? key, required this.onPressAction, required this.title, this.icon})
      : super(key: key);

  final String onPressAction;
  final String title;
  final String? icon;

  @override
  // ignore: library_private_types_in_public_api
  _OrangeButtonWidgetState createState() => _OrangeButtonWidgetState();
}

class _OrangeButtonWidgetState extends State<OrangeButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return OrangeButton(
      onPressed: () {
        // Add your button press logic here
        print(widget.onPressAction);
        print(widget.icon);
      },
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null)
              const Icon(
                Icons.add, // TO DO: replace this with icons once figured out how to use icons for our project
                color: Colors.white,
              ),
            const SizedBox(width: 8), // Add some space between the icon and text
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
