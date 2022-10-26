import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

import '../themes/theme_data.dart';

// The Svg logo is used in every [AppBar], wrapped by [Hero] to keep it in
// place when navigating between screens.
final titleIcon = Hero(
  tag: 'logoHero',
  child: SvgPicture.asset(
    'assets/icons/logo.svg',
    color: customYellow,
    height: 40.0,
  ),
);

// The logo + text Svg is shown during the loading screen.
final logoTextIcon = SvgPicture.asset(
  'assets/icons/logo-text.svg',
  height: 40.0,
);
