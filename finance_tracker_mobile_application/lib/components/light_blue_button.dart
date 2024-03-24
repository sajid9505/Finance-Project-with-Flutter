import 'package:finance_tracker_mobile_application/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class LightBlueButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color color;
  final double elevation;

  const LightBlueButton({
    required this.onPressed,
    required this.child,
    this.color = TColors.buttonAccent,
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

class LightBlueButtonWidget extends StatefulWidget {
  const LightBlueButtonWidget({Key? key, required this.onPressAction, required this.title}) : super(key: key);

  final String onPressAction;
  final String title;

  @override
  // ignore: library_private_types_in_public_api
  _LightBlueButtonWidgetState createState() =>
      _LightBlueButtonWidgetState();
}

class _LightBlueButtonWidgetState
    extends State<LightBlueButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return LightBlueButton(
      onPressed: () {
        // Add your button press logic here
        print(widget.onPressAction);
      },
      child: Center(
        child: Text(
         (widget.title),
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
