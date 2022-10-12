import 'dart:convert';
import 'dart:io';

import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:dart_lnurl/dart_lnurl.dart' as lnurl;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hex/hex.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:othala/services/network_helper.dart';
import 'package:othala/services/secure_storage.dart';
import 'package:othala/widgets/list_divider.dart';

import '../models/wallet.dart';
import '../services/wallet_manager.dart';
import '../themes/theme_data.dart';
import '../widgets/flat_button.dart';

class LnurlScreen extends StatefulWidget {
  const LnurlScreen({Key? key}) : super(key: key);

  @override
  LnurlScreenState createState() => LnurlScreenState();
}

class LnurlScreenState extends State<LnurlScreen> {
  final WalletManager _walletManager = WalletManager(Hive.box('walletBox'));
  int signed = -1;
  String domain = '';
  String callBackUrl = '';

  @override
  Widget build(BuildContext context) {
    final lnURL = ModalRoute.of(context)!.settings.arguments as String;
    _getLnAuth(lnURL);
    final List<Wallet> wallets = _walletManager.getWallets(['mnemonic']);
    return Container(
      color: kDarkBackgroundColor,
      child: SafeArea(
        child: Scaffold(
          body: Container(
            padding: const EdgeInsets.only(
              bottom: 16.0,
              left: 8.0,
              right: 8.0,
            ),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/logo.svg',
                      color: kYellowColor,
                      height: 40.0,
                    ),
                  ],
                ),
                Row(
                  children: const [
                    Text(
                      'Website',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: kDarkNeutral5Color,
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
                        color: kDarkNeutral5Color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            childAspectRatio: 3 / 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20),
                    itemCount: wallets.length,
                    itemBuilder: (BuildContext ctx, index) {
                      Wallet wallet = wallets[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            signed = index;
                            _sign(wallet, lnURL);
                          });
                        },
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: _showImage(wallet.imagePath,
                                  signed == index || signed == -1 ? 1.0 : 0.5),
                            ),
                            Visibility(
                              visible: signed == index ? true : false,
                              child: const Positioned(
                                top: 8.0,
                                right: 8.0,
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  color: kYellowColor,
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
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _authenticate(callBackUrl),
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
                          buttonColor: kDarkBackgroundColor,
                          fontColor: kWhiteColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _authenticate(callBackUrl) async {
    NetworkHelper networkHelper = NetworkHelper();
    try {
      final resBody = await networkHelper.getData(callBackUrl);
      if (!mounted) return;
      final res = jsonDecode(resBody);
      final status = res['status'];

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

  _getLnAuth(url) async {
    if (domain.isEmpty) {
      final res = await lnurl.getParams(url);
      lnurl.LNURLAuthParams? auth = res.authParams;
      domain = auth!.domain;
      setState(() {});
    }
  }

  _showImage(String path, double opacity) {
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

  _sign(Wallet wallet, url) async {
    StorageService storageService = StorageService();
    final mnemonic = await storageService.readSecureData(wallet.key);
    final seed = bip39.mnemonicToSeed(mnemonic!);
    final masterKey = bip32.BIP32.fromSeed(seed);
    final linkingKey = await lnurl.deriveLinkingKey(url, masterKey);
    final key = HEX.encode(linkingKey.publicKey);
    final sig = await lnurl.signK1(url, linkingKey);
    final decodedUrl = lnurl.decodeLnUri(url);
    callBackUrl = '$decodedUrl&sig=$sig&key=$key';
  }
}
