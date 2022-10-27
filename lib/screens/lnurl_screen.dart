import 'dart:convert';
import 'dart:io';

import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:dart_lnurl/dart_lnurl.dart' as lnurl;
import 'package:flutter/material.dart';
import 'package:hex/hex.dart';

import '../models/wallet.dart';
import '../services/network_helper.dart';
import '../services/secure_storage.dart';
import '../services/wallet_manager.dart';
import '../themes/custom_icons.dart';
import '../themes/theme_data.dart';
import '../widgets/flat_button.dart';
import '../widgets/list_divider.dart';
import '../widgets/safe_area.dart';

class LnurlScreen extends StatefulWidget {
  const LnurlScreen({Key? key}) : super(key: key);

  @override
  LnurlScreenState createState() => LnurlScreenState();
}

class LnurlScreenState extends State<LnurlScreen> {
  var walletManager = WalletManager();
  var signed = -1;
  var domain = '';
  var callBackUrl = '';

  @override
  Widget build(BuildContext context) {
    var wallets = walletManager.getWallets(['mnemonic']);
    var lnURL = ModalRoute.of(context)!.settings.arguments as String;
    getLnAuth(lnURL);

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
              onTap: () => signed != -1 ? authenticate(callBackUrl) : null,
              child: CustomFlatButton(
                textLabel: 'Sign in',
                enabled: signed != -1 ? true : false,
              ),
            ),
          ),
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
          Row(
            children: const [
              Text(
                'Website',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: customDarkNeutral5,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                domain,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: ListDivider(),
          ),
          Row(
            children: [
              Text(
                wallets.isNotEmpty ? 'Sign in with keys from:' : '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: customDarkNeutral5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20),
              itemCount: wallets.length,
              itemBuilder: (BuildContext ctx, index) {
                var wallet = wallets[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      signed = index;
                      sign(wallet, lnURL);
                    });
                  },
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: showImage(wallet.imagePath,
                            signed == index || signed == -1 ? 1.0 : 0.5),
                      ),
                      Visibility(
                        visible: signed == index ? true : false,
                        child: const Positioned(
                          top: 8.0,
                          right: 8.0,
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: customYellow,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  authenticate(String callBackUrl) async {
    try {
      final resBody = await NetworkHelper().fetchData(callBackUrl);
      if (!mounted) return;
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
      setState(() {});
    }
  }

  showImage(String path, double opacity) {
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
  }
}
