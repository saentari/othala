import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:othala/screens/camera_error_screen.dart';
import 'package:othala/screens/lnurl_screen.dart';

import '../models/currency.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';
import '../screens/camera_screen.dart';
import '../screens/home_screen.dart';
import '../screens/import_address_screen.dart';
import '../screens/import_phrase_screen.dart';
import '../screens/lnurl_confirmation_screen.dart';
import '../screens/loading_screen.dart';
import '../screens/send_payment_confirmation_screen.dart';
import '../screens/wallet_creation_screen.dart';
import '../screens/wallet_import_screen.dart';
import '../themes/theme_data.dart';

Future<void> main() async {
  Hive.registerAdapter(WalletAdapter());
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(CurrencyAdapter());
  await Hive.initFlutter();
  await Hive.openBox('walletBox');
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Othala',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      initialRoute: '/loading_screen',
      routes: {
        '/camera_error_screen': (context) => const CameraErrorScreen(),
        '/home_screen': (context) => const HomeScreen(),
        '/loading_screen': (context) => const LoadingScreen(),
        '/wallet_creation_screen': (context) => const WalletCreationScreen(),
        '/wallet_import_screen': (context) => const WalletImportScreen(),
        '/import_phrase_screen': (context) => const ImportPhraseScreen(),
        '/import_address_screen': (context) => const ImportAddressScreen(),
        '/camera_screen': (context) => const CameraScreen(),
        '/lnurl_confirmation_screen': (context) =>
            const LnUrlConfirmationScreen(),
        '/lnurl_screen': (context) => const LnurlScreen(),
        '/send_payment_confirmation_screen': (context) =>
            const SendPaymentConfirmationScreen(),
      },
    );
  }
}
