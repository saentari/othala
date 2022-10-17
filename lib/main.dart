import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/currency.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';
import '../screens/camera_error_screen.dart';
import '../screens/camera_screen.dart';
import '../screens/home_screen.dart';
import '../screens/import_address_screen.dart';
import '../screens/import_phrase_screen.dart';
import '../screens/lnurl_confirmation_screen.dart';
import '../screens/lnurl_error_screen.dart';
import '../screens/lnurl_screen.dart';
import '../screens/loading_screen.dart';
import '../screens/send_payment_confirmation_screen.dart';
import '../screens/wallet_background_screen.dart';
import '../screens/wallet_creation_screen.dart';
import '../screens/wallet_currency_screen.dart';
import '../screens/wallet_derivation_screen.dart';
import '../screens/wallet_discovery_screen.dart';
import '../screens/wallet_import_screen.dart';
import '../screens/wallet_name_screen.dart';
import '../screens/wallet_network_screen.dart';
import '../screens/wallet_screen.dart';
import '../screens/wallet_settings_screen.dart';
import '../themes/theme_data.dart';

Future<void> main() async {
  Hive.registerAdapter(WalletAdapter());
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
        '/camera_error_screen': (context) => const CameraErrorScreen(),
        '/camera_screen': (context) => const CameraScreen(),
        '/home_screen': (context) => const HomeScreen(),
        '/import_address_screen': (context) => const ImportAddressScreen(),
        '/import_phrase_screen': (context) => const ImportPhraseScreen(),
        '/lnurl_confirmation_screen': (context) =>
            const LnUrlConfirmationScreen(),
        '/lnurl_error_screen': (context) => const LnUrlErrorScreen(),
        '/lnurl_screen': (context) => const LnurlScreen(),
        '/loading_screen': (context) => const LoadingScreen(),
        '/send_payment_confirmation_screen': (context) =>
            const SendPaymentConfirmationScreen(),
        '/wallet_background_screen': (context) =>
            const WalletBackgroundScreen(),
        '/wallet_creation_screen': (context) => const WalletCreationScreen(),
        '/wallet_currency_screen': (context) => const WalletCurrencyScreen(),
        '/wallet_discovery_screen': (context) => const WalletDiscoveryScreen(),
        '/wallet_derivation_screen': (context) =>
            const WalletDerivationScreen(),
        '/wallet_import_screen': (context) => const WalletImportScreen(),
        '/wallet_name_screen': (context) => const WalletNameScreen(),
        '/wallet_network_screen': (context) => const WalletNetworkScreen(),
        '/wallet_settings_screen': (context) => const WalletSettingsScreen(),
        '/wallet_screen': (context) => const WalletScreen(),
      },
    );
  }
}
