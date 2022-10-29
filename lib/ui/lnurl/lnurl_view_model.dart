import 'dart:convert';
import 'dart:io';

import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:dart_lnurl/dart_lnurl.dart' as lnurl;
import 'package:flutter/material.dart';
import 'package:hex/hex.dart';

import '../../models/wallet.dart';
import '../../services/network_helper.dart';
import '../../services/secure_storage.dart';
import '../../services/wallet_manager.dart';

class LnurlViewModel extends ChangeNotifier {
  var walletManager = WalletManager();
  var signed = -1;
  var domain = '';
  var callBackUrl = '';

  late List wallets;
  late String lnURL;

  void initialise(BuildContext context) {
    wallets = walletManager.getWallets(['mnemonic']);
    lnURL = ModalRoute.of(context)!.settings.arguments as String;
    getLnAuth(lnURL);
    notifyListeners();
  }

  authenticate(BuildContext context, String callBackUrl) async {
    try {
      final resBody = await NetworkHelper().fetchData(callBackUrl);
      var res = jsonDecode(resBody);
      var status = res['status'];

      if (status == 'OK') {
        Navigator.pushNamed(context, '/lnurl_confirmation_screen',
            arguments: domain);
      } else {
        Navigator.pushNamed(context, '/lnurl_error_screen', arguments: domain);
      }
    } catch (e) {
      Navigator.pushNamed(context, '/lnurl_error_screen', arguments: domain);
    }
  }

  getLnAuth(String url) async {
    if (domain.isEmpty) {
      var res = await lnurl.getParams(url);
      lnurl.LNURLAuthParams? auth = res.authParams;
      domain = auth!.domain;
      notifyListeners();
    }
  }

  showImage(BuildContext context, String path, double opacity) {
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      return Image.asset(
        'assets/images/andreas-gucklhorn-mawU2PoJWfU-unsplash.jpeg',
        fit: BoxFit.cover,
        color: Colors.white.withOpacity(opacity),
        colorBlendMode: BlendMode.modulate,
        height: 160,
        width: MediaQuery.of(context).size.width,
      );
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        color: Colors.white.withOpacity(opacity),
        colorBlendMode: BlendMode.modulate,
        height: 160,
        width: MediaQuery.of(context).size.width,
      );
    }
  }

  sign(Wallet wallet, String url) async {
    var mnemonic = await StorageService().readSecureData(wallet.key);
    var seed = bip39.mnemonicToSeed(mnemonic!);
    var masterKey = bip32.BIP32.fromSeed(seed);
    var linkingKey = await lnurl.deriveLinkingKey(url, masterKey);
    var key = HEX.encode(linkingKey.publicKey);
    var sig = await lnurl.signK1(url, linkingKey);
    var decodedUrl = lnurl.decodeLnUri(url);
    callBackUrl = '$decodedUrl&sig=$sig&key=$key';
    notifyListeners();
  }
}
