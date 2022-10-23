import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';

import '../models/derivation_path.dart';
import '../services/wallet_manager.dart';
import '../themes/custom_icons.dart';
import '../themes/theme_data.dart';
import '../widgets/flat_button.dart';
import '../widgets/list_divider.dart';
import '../widgets/safe_area.dart';

class WalletDerivationScreen extends StatefulWidget {
  const WalletDerivationScreen({Key? key}) : super(key: key);

  @override
  WalletDerivationScreenState createState() => WalletDerivationScreenState();
}

class WalletDerivationScreenState extends State<WalletDerivationScreen> {
  @override
  Widget build(BuildContext context) {
    final walletIndex = ModalRoute.of(context)!.settings.arguments as int;

    return SafeAreaX(
      appBar: AppBar(
        centerTitle: true,
        title: titleIcon,
        backgroundColor: kBlackColor,
        automaticallyImplyLeading: false,
      ),
      bottomBar: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const CustomFlatButton(
          textLabel: 'Cancel',
          buttonColor: kDarkBackgroundColor,
          fontColor: kWhiteColor,
        ),
      ),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 16.0),
          ListTileAsset(
            walletIndex: walletIndex,
            purpose: 44,
            subtitle: "Legacy (P2PKH)",
          ),
          const ListDivider(),
          ListTileAsset(
            walletIndex: walletIndex,
            purpose: 49,
            subtitle: "SegWit (P2WPKH-in-P2SH)",
          ),
          const ListDivider(),
          ListTileAsset(
            walletIndex: walletIndex,
            purpose: 84,
            subtitle: "Native SegWit (P2WPKH)",
          ),
        ],
      ),
    );
  }
}

class ListTileAsset extends StatefulWidget {
  const ListTileAsset({
    required this.walletIndex,
    required this.purpose,
    required this.subtitle,
    Key? key,
  }) : super(key: key);

  final int walletIndex;
  final int purpose;
  final String subtitle;

  @override
  State<ListTileAsset> createState() => _ListTileAssetState();
}

class _ListTileAssetState extends State<ListTileAsset> {
  @override
  Widget build(BuildContext context) {
    final box = Hive.box('walletBox');
    final walletManager = WalletManager(box);
    final wallet = box.getAt(widget.walletIndex);
    final dp = DerivationPath(wallet.derivationPath);
    final selectedIndex = dp.purpose;
    final selectedCoinType = dp.coinType;
    return Container(
      color: kDarkBackgroundColor,
      child: GestureDetector(
        onTap: () async {
          EasyLoading.show(
            status: 'updating...',
            maskType: EasyLoadingMaskType.black,
            dismissOnTap: true,
          );
          await walletManager.setPurpose(widget.walletIndex, widget.purpose);
          if (EasyLoading.isShow) {
            EasyLoading.dismiss();
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
                    "m/${widget.purpose}'/$selectedCoinType'/0'/0",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: kDarkNeutral7Color,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Visibility(
                visible: widget.purpose == selectedIndex ? true : false,
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
