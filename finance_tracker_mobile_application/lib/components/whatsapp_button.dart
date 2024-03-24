import 'package:finance_tracker_mobile_application/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class CustomWhatsappButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color color;
  final double elevation;

  const CustomWhatsappButton({
    required this.onPressed,
    required this.child,
    this.color = TColors.buttonWhatsapp,
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

class CustomWhatsappButtonWidget extends StatefulWidget {
  const CustomWhatsappButtonWidget({Key? key, required this.onPressAction}) : super(key: key);

  final String onPressAction;

  @override
  // ignore: library_private_types_in_public_api
  _CustomWhatsappButtonWidgetState createState() =>
      _CustomWhatsappButtonWidgetState();
}

class _CustomWhatsappButtonWidgetState
    extends State<CustomWhatsappButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return CustomWhatsappButton(
      onPressed: () {
        // Add your button press logic here
        print(widget.onPressAction);
      },
      child: const Center(
        child: Text(
          'Whatsapp',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
