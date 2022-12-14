import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../themes/theme_data.dart';

class FlatRoundedButton extends StatelessWidget {
  const FlatRoundedButton({
    Key? key,
    required this.textLabel,
    this.buttonColor = customYellow,
    this.fontColor = customBlack,
    this.enabled = true,
    this.primary = true,
  }) : super(key: key);

  final Color buttonColor;
  final Color fontColor;
  final String textLabel;
  final bool enabled;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    double opacity = 1.0;
    enabled == false ? opacity = 0.2 : opacity = 1.0;

    return Container(
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.0),
        color: buttonColor.withOpacity(opacity),
      ),
      child: Text(
        textLabel.toLowerCase(),
        style: const TextStyle(
            color: customDarkBackground,
            fontSize: 18.0,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}
