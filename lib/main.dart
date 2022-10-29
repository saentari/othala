import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/address.dart';
import 'models/currency.dart';
import 'models/transaction.dart';
import 'models/wallet.dart';
import 'themes/theme_data.dart';
import 'ui/camera/camera_view.dart';
import 'ui/camera_error/camera_error_view.dart';
import 'ui/home/home_view.dart';
import 'ui/import_address/import_address_view.dart';
import 'ui/import_phrase/import_phrase_view.dart';
import 'ui/lnurl/lnurl_view.dart';
import 'ui/lnurl_confirmation/lnurl_confirmation_view.dart';
import 'ui/lnurl_error/lnurl_error_view.dart';
import 'ui/loading/loading_view.dart';
import 'ui/send_payment_confirmation/send_payment_confirmation_view.dart';
import 'ui/wallet/wallet_view.dart';
import 'ui/wallet_background/wallet_background_view.dart';
import 'ui/wallet_creation/wallet_creation_view.dart';
import 'ui/wallet_currency/wallet_currency_view.dart';
import 'ui/wallet_derivation/wallet_derivation_view.dart';
import 'ui/wallet_discovery/wallet_discovery_view.dart';
import 'ui/wallet_import/wallet_import_view.dart';
import 'ui/wallet_name/wallet_name_view.dart';
import 'ui/wallet_network/wallet_network_view.dart';
import 'ui/wallet_settings/wallet_settings_view.dart';

Future<void> main() async {
  Hive.registerAdapter(WalletAdapter());
  Hive.registerAdapter(AddressAdapter());
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(CurrencyAdapter());
  await Hive.initFlutter();
  await Hive.openBox('walletBox');
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Othala',
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      initialRoute: '/loading_screen',
      builder: EasyLoading.init(),
      routes: {
        '/camera_error_screen': (context) => const CameraErrorView(),
        '/camera_screen': (context) => const CameraView(),
        '/home_screen': (context) => const HomeView(),
        '/import_address_screen': (context) => const ImportAddressView(),
        '/import_phrase_screen': (context) => const ImportPhraseView(),
        '/lnurl_confirmation_screen': (context) =>
            const LnUrlConfirmationView(),
        '/lnurl_error_screen': (context) => const LnUrlErrorView(),
        '/lnurl_screen': (context) => const LnurlView(),
        '/loading_screen': (context) => const LoadingView(),
        '/send_payment_confirmation_screen': (context) =>
            const SendPaymentConfirmationView(),
        '/wallet_background_screen': (context) => const WalletBackgroundView(),
        '/wallet_creation_screen': (context) => const WalletCreationView(),
        '/wallet_currency_screen': (context) => const WalletCurrencyView(),
        '/wallet_discovery_screen': (context) => const WalletDiscoveryView(),
        '/wallet_derivation_screen': (context) => const WalletDerivationView(),
        '/wallet_import_screen': (context) => const WalletImportView(),
        '/wallet_name_screen': (context) => const WalletNameView(),
        '/wallet_network_screen': (context) => const WalletNetworkView(),
        '/wallet_settings_screen': (context) => const WalletSettingsView(),
        '/wallet_screen': (context) => const WalletView(),
      },
    );
  }
}
