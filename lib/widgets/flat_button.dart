import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../themes/theme_data.dart';

class CustomFlatButton extends StatelessWidget {
  const CustomFlatButton({
    Key? key,
    required this.textLabel,
    this.buttonColor = kYellowColor,
    this.borderColor = kTransparentColor,
    this.fontColor = kDarkBackgroundColor,
    this.enabled = true,
  }) : super(key: key);

  final Color buttonColor;
  final Color borderColor;
  final Color fontColor;
  final String textLabel;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    double opacity = 1.0;
    enabled == false ? opacity = 0.2 : opacity = 1.0;

    return Container(
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        color: buttonColor.withOpacity(opacity),
      ),
      child: Text(
        textLabel,
        style: TextStyle(
            color: fontColor, fontSize: 18.0, fontWeight: FontWeight.w600),
      ),
    );
  }
}
