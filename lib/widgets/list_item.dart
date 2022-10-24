import 'package:flutter/cupertino.dart';

import '../themes/theme_data.dart';

class ListItem extends StatelessWidget {
  // Default value is empty, unless argument is set.
  const ListItem(this.title,
      {Key? key,
      this.value = '',
      this.subtitle = '',
      this.subtitleColor = kDarkNeutral7Color,
      this.chevron = false,
      this.icon})
      : super(key: key);

  final String title;
  final String subtitle;
  final Color subtitleColor;
  final String value;
  final bool chevron;
  final IconData? icon;

  String getSubString(String fullString) {
    String subtitleShort = fullString;
    int length = fullString.length;
    int nearEnd = length - 6;
    if (length > 40) {
      String sub1 = fullString.substring(0, 24);
      String sub2 = fullString.substring(nearEnd, length);
      subtitleShort = '$sub1...$sub2';
    }
    return subtitleShort;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.rectangle,
        color: kBlackColor,
      ),
      padding: const EdgeInsets.only(left: 16.0, right: 8.0),
      height: subtitle != '' ? 90 : 70,
      child: Row(
        children: [
          Visibility(
              visible: icon != null ? true : false,
              child: Row(
                children: [
                  Icon(icon),
                  const SizedBox(width: 16.0),
                ],
              )),
          Expanded(
            flex: 99,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle != ''
                    ? Text(
                        getSubString(subtitle),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: subtitleColor,
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8.0),
          Icon(CupertinoIcons.chevron_forward,
              color: chevron == true ? kWhiteColor : kTransparentColor),
        ],
      ),
    );
  }
}
