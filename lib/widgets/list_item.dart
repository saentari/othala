import 'package:flutter/cupertino.dart';

import '../themes/theme_data.dart';

class ListItem extends StatelessWidget {
  // default value is empty, unless argument is set.
  ListItem(this.title,
      {Key? key,
      this.value = '',
      this.subtitle = '',
      this.subtitleColor = kDarkNeutral7Color,
      this.chevron = false,
      this.icon})
      : super(key: key);

  final String title;
  String subtitle;
  Color subtitleColor;
  String value;
  bool chevron;
  IconData? icon;

  String getSubString(String fullString) {
    String subtitleShort = fullString;
    int _length = fullString.length;
    int _nearEnd = _length - 6;
    if (_length > 40) {
      String _sub1 = fullString.substring(0, 24);
      String _sub2 = fullString.substring(_nearEnd, _length);
      subtitleShort = _sub1 + '...' + _sub2;
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
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
