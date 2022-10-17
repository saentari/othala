import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';

import '../models/derivation_path.dart';
import '../services/wallet_manager.dart';
import '../themes/theme_data.dart';
import '../widgets/flat_button.dart';
import '../widgets/list_divider.dart';

class WalletNetworkScreen extends StatefulWidget {
  const WalletNetworkScreen({Key? key}) : super(key: key);

  @override
  WalletNetworkScreenState createState() => WalletNetworkScreenState();
}

class WalletNetworkScreenState extends State<WalletNetworkScreen> {
  @override
  Widget build(BuildContext context) {
    final walletIndex = ModalRoute.of(context)!.settings.arguments as int;

    return Container(
      color: kDarkBackgroundColor,
      child: SafeArea(
        child: Scaffold(
          body: Column(
            children: <Widget>[
              const SizedBox(height: 16.0),
              ListTileAsset(
                walletIndex: walletIndex,
                network: 'bitcoin',
                title: "Bitcoin mainnet",
              ),
              const ListDivider(),
              ListTileAsset(
                walletIndex: walletIndex,
                network: 'testnet',
                title: "Bitcoin testnet",
              ),
            ],
          ),
          bottomNavigationBar: GestureDetector(
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
      ),
    );
  }
}

class ListTileAsset extends StatefulWidget {
  const ListTileAsset({
    required this.walletIndex,
    required this.network,
    required this.title,
    Key? key,
  }) : super(key: key);

  final int walletIndex;
  final String network;
  final String title;

  @override
  State<ListTileAsset> createState() => _ListTileAssetState();
}

class _ListTileAssetState extends State<ListTileAsset> {
  @override
  Widget build(BuildContext context) {
    final box = Hive.box('walletBox');
    final walletManager = WalletManager(box);
    final wallet = box.getAt(widget.walletIndex);
    final dp = DerivationPath();
    final selectedCoinType = dp.getCoinType(wallet.derivationPath);
    final coinType = widget.network == 'testnet' ? 1 : 0;
    return Container(
      color: kDarkBackgroundColor,
      child: GestureDetector(
        onTap: () async {
          try {
            await EasyLoading.show(
              status: 'updating...',
              maskType: EasyLoadingMaskType.black,
              dismissOnTap: true,
            );
            await walletManager.setNetwork(widget.walletIndex, widget.network);
            await EasyLoading.dismiss();
          } catch (e) {
            await EasyLoading.showError(e.toString());
          }

          if (!mounted) return;
          Navigator.pop(context);
        },
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Visibility(
                visible: coinType == selectedCoinType ? true : false,
                child: const Icon(
                  CupertinoIcons.check_mark,
                  color: kYellowColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
