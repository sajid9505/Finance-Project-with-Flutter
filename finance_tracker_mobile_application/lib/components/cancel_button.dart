import 'package:finance_tracker_mobile_application/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class BlackButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color color;
  final double elevation;

  const BlackButton({
    required this.onPressed,
    required this.child,
    this.color = TColors.buttonBlack,
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

class BlackButtonWidget extends StatefulWidget {
  const BlackButtonWidget({Key? key, required this.onPressAction, required this.title}) : super(key: key);

  final String onPressAction;
  final String title;

  @override
  // ignore: library_private_types_in_public_api
  _BlackButtonWidgetState createState() =>
      _BlackButtonWidgetState();
}

class _BlackButtonWidgetState
    extends State<BlackButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return BlackButton(
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
