import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:othala/models/currency.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:xchain_dart/xchaindart.dart';

import '../constants.dart';
import '../models/secure_item.dart';
import '../models/unsplash_image.dart';
import '../models/wallet.dart';
import '../services/secure_storage.dart';
import '../services/unsplash_image_provider.dart';
import '../themes/theme_data.dart';
import '../widgets/flat_button.dart';

class WalletCreationScreen extends StatefulWidget {
  const WalletCreationScreen({Key? key}) : super(key: key);

  @override
  _WalletCreationScreenState createState() => _WalletCreationScreenState();
}

class _WalletCreationScreenState extends State<WalletCreationScreen> {
  // Random mnemonic phrase
  bool _confirmed = false;
  String _randomMnemonic = '';
  String _imageId = '';

  // Default background image
  String _localPath =
      'assets/images/andreas-gucklhorn-mawU2PoJWfU-unsplash.jpeg';

  List<String> _randomMnemonicList = [
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    ''
  ];

  @override
  void initState() {
    super.initState();
    _createMnemonic();
    _loadRandomImage(keyword: 'nature');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.only(
            bottom: 16.0,
            left: 8.0,
            right: 8.0,
          ),
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: SvgPicture.asset(
                  'assets/icons/logo.svg',
                  color: kYellowColor,
                  height: 40.0,
                ),
              ),
              const Text(
                'Write down these words in the right order and store them safely. Without these words, you will not be able to recover your funds.',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 48.0),
              Column(
                children: [
                  Table(
                    columnWidths: const {
                      0: FixedColumnWidth(24.0),
                      2: FixedColumnWidth(24.0),
                      4: FixedColumnWidth(24.0),
                    },
                    children: [
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              '1',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: kGreyColor,
                              ),
                            ),
                          ),
                          Text(
                            _randomMnemonicList[0],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(
                            '2',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: kGreyColor,
                            ),
                          ),
                          Text(
                            _randomMnemonicList[1],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(
                            '3',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: kGreyColor,
                            ),
                          ),
                          Text(
                            _randomMnemonicList[2],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              '4',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: kGreyColor,
                              ),
                            ),
                          ),
                          Text(
                            _randomMnemonicList[3],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(
                            '5',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: kGreyColor,
                            ),
                          ),
                          Text(
                            _randomMnemonicList[4],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(
                            '6',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: kGreyColor,
                            ),
                          ),
                          Text(
                            _randomMnemonicList[5],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              '7',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: kGreyColor,
                              ),
                            ),
                          ),
                          Text(
                            _randomMnemonicList[6],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(
                            '8',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: kGreyColor,
                            ),
                          ),
                          Text(
                            _randomMnemonicList[7],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(
                            '9',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: kGreyColor,
                            ),
                          ),
                          Text(
                            _randomMnemonicList[8],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              '10',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: kGreyColor,
                              ),
                            ),
                          ),
                          Text(
                            _randomMnemonicList[9],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(
                            '11',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: kGreyColor,
                            ),
                          ),
                          Text(
                            _randomMnemonicList[10],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(
                            '12',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: kGreyColor,
                            ),
                          ),
                          Text(
                            _randomMnemonicList[11],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  GestureDetector(
                    onTap: () {
                      _setClipboard();
                    },
                    child: const Text(
                      'Copy to clipboard',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: kYellowColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _toggleConfirmation(),
                child: Row(
                  children: [
                    _confirmed
                        ? const Icon(CupertinoIcons.checkmark_square_fill,
                            color: kWhiteColor)
                        : const Icon(CupertinoIcons.square, color: kWhiteColor),
                    const SizedBox(width: 16.0),
                    const Expanded(
                      child: Text(
                        'I wrote down my recovery phrase and I am aware of the risks of losing it.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          _confirmed == true ? _encryptToKeyStore() : null,
                      child: _confirmed == true
                          ? const CustomFlatButton(
                              textLabel: 'Create',
                            )
                          : const CustomFlatButton(
                              textLabel: 'Create',
                              enabled: false,
                            ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const CustomFlatButton(
                        textLabel: 'Cancel',
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
    );
  }

  void _toggleConfirmation() {
    setState(() {
      _confirmed == false ? _confirmed = true : _confirmed = false;
    });
  }

  String? _createMnemonic() {
    // BIP39 English word list
    _randomMnemonic = generateMnemonic();
    _randomMnemonicList = _randomMnemonic.split(" ");

    setState(() {});
  }

  _encryptToKeyStore() async {
    String _key = UniqueKey().toString();

    final StorageService _storageService = StorageService();
    _storageService.writeSecureData(SecureItem(_key, _randomMnemonic));

    XChainClient _client = BitcoinClient(_randomMnemonic);
    var _walletBox = Hive.box('walletBox');
    Currency _defaultFiatCurrency =
        Currency('USD', id: 'usd-us-dollars', name: 'US dollar', symbol: r'$');
    Currency _defaultCurrency = Currency('btc',
        id: 'btc-bitcoin', name: 'Bitcoin', symbol: unicodeBitcoin);
    _walletBox.add(Wallet(_key, '', 'phrase', 'bitcoin', [_client.address], [],
        [], _imageId, _localPath, _defaultFiatCurrency, _defaultCurrency));

    Navigator.pushReplacementNamed(context, '/home_screen');
  }

  void _setClipboard() async {
    // clipboard
    ClipboardData data = ClipboardData(text: _randomMnemonic);
    await Clipboard.setData(data);

    // emoji
    var parser = EmojiParser();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          // returns: 'Copied to clipboard 👍'
          parser.emojify('Copied to clipboard :thumbsup:'),
          style: const TextStyle(color: kWhiteColor, fontSize: 16.0),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: kDarkGreyColor,
      ),
    );
  }

  /// Requests a [UnsplashImage] for a given [keyword] query.
  /// If the given [keyword] is null, any random image is loaded.
  _loadRandomImage({String? keyword}) async {
    UnsplashImage _imageData =
        await UnsplashImageProvider.loadRandomImage(keyword: keyword);
    _imageId = _imageData.getId();
    _download(_imageData.getRegularUrl());
  }

  Future<void> _download(String url) async {
    final response = await http.get(Uri.parse(url));

    // Get the image name
    final imageName = path.basename(url);

    // Get the document directory path
    final appDir = await pathProvider.getApplicationDocumentsDirectory();
    // This is the saved image path
    _localPath = path.join(appDir.path, imageName);

    // Downloading
    final imageFile = File(_localPath);
    await imageFile.writeAsBytes(response.bodyBytes);
  }
}
