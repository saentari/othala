import 'package:flutter/material.dart';

import '../themes/custom_icons.dart';
import '../themes/theme_data.dart';
import '../widgets/flat_button.dart';
import '../widgets/safe_area.dart';

class CameraErrorScreen extends StatefulWidget {
  const CameraErrorScreen({Key? key}) : super(key: key);

  @override
  CameraErrorScreenState createState() => CameraErrorScreenState();
}

class CameraErrorScreenState extends State<CameraErrorScreen> {
  @override
  Widget build(BuildContext context) {
    final res = ModalRoute.of(context)!.settings.arguments;
    return SafeAreaX(
      appBar: AppBar(
        centerTitle: true,
        title: titleIcon,
        backgroundColor: customBlack,
        automaticallyImplyLeading: false,
      ),
      bottomBar: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/home_screen', (Route<dynamic> route) => false);
              },
              child: const CustomFlatButton(
                textLabel: 'Close',
                buttonColor: customDarkBackground,
                fontColor: customWhite,
              ),
            ),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          const Text(
            'No match found for',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            '$res',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: customDarkNeutral5,
            ),
          ),
        ],
      ),
    );
  }
}
