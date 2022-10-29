import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomeViewModel extends ChangeNotifier {
  PageController? pageController;
  final currentPageNotifier = ValueNotifier<int>(0);
  final walletBox = Hive.box('walletBox');

  void initialise(BuildContext context) {
    var initialPage = ModalRoute.of(context)!.settings.arguments ?? 0;
    pageController = PageController(initialPage: initialPage as int);
    currentPageNotifier.value = initialPage;
    notifyListeners();
  }
}
