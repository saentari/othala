import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../themes/theme_data.dart';

class ListItemTransaction extends StatelessWidget {
  // Default value is empty, unless argument is set.
  const ListItemTransaction(this.title,
      {Key? key,
      this.value = 0.0,
      this.subtitle = '',
      this.subtitleValue = '',
      this.subtitleColor = customDarkNeutral7,
      this.icon})
      : super(key: key);

  final String title;
  final String subtitle;
  final Color subtitleColor;
  final double value;
  final String subtitleValue;
  final IconData? icon;

  String getSubString(String fullString) {
    String subString = fullString;
    int length = fullString.length;
    int nearEnd = length - 6;
    if (length > 30) {
      String sub1 = fullString.substring(0, 14);
      String sub2 = fullString.substring(nearEnd, length);
      subString = '$sub1...$sub2';
    }
    return subString;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.rectangle,
        color: customBlack,
      ),
      padding: const EdgeInsets.only(left: 16.0, right: 8.0),
      height: 70,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getSubString(title),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  getSubString(subtitle),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value.toString(),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitleValue.toString(),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
