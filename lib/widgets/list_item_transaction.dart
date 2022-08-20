import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../themes/theme_data.dart';

class ListItemTransaction extends StatelessWidget {
  // default value is empty, unless argument is set.
  ListItemTransaction(this.title,
      {Key? key,
      this.value = 0.0,
      this.subtitle = '',
      this.subtitleColor = kDarkNeutral7Color,
      this.icon})
      : super(key: key);

  final String title;
  String subtitle;
  Color subtitleColor;
  double value;
  IconData? icon;

  String getSubString(String fullString) {
    String subString = fullString;
    int _length = fullString.length;
    int _nearEnd = _length - 6;
    if (_length > 30) {
      String _sub1 = fullString.substring(0, 14);
      String _sub2 = fullString.substring(_nearEnd, _length);
      subString = _sub1 + '...' + _sub2;
    }
    return subString;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.rectangle,
        color: kBlackColor,
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
            child: Text(
              value.toString(),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
