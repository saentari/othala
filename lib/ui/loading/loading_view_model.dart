import 'package:flutter/cupertino.dart';

import '../../services/wallet_manager.dart';
import '../home/home_view.dart';

class LoadingViewModel extends ChangeNotifier {
  void initialise(BuildContext context) {
    // Fetches prices and updates transactions at start-up.
    fetchData();

    // Show a placeholder when data is being retrieved.
    Future<void>.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => const HomeView(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    });
  }

  Future<void> fetchData() async {
    // Get bitcoin prices in fiat currencies.
    await WalletManager().updateFiatPrices();

    // Check for new blockchain transactions.
    await WalletManager().setTransactions();
  }
}
