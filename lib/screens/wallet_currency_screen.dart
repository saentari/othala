import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../constants.dart';
import '../models/currency.dart';
import '../services/wallet_manager.dart';
import '../themes/theme_data.dart';
import '../widgets/flat_button.dart';
import '../widgets/list_divider.dart';

class WalletCurrencyScreen extends StatefulWidget {
  WalletCurrencyScreen(this.walletIndex, {Key? key}) : super(key: key);

  int walletIndex;

  @override
  _WalletCurrencyScreenState createState() => _WalletCurrencyScreenState();
}

final WalletManager _walletManager = WalletManager(Hive.box('walletBox'));

class _WalletCurrencyScreenState extends State<WalletCurrencyScreen> {
  final List<Currency> _fiatCurrencies = fiatCurrencies;
  late Currency _defaultFiatCurrency;

  @override
  Widget build(BuildContext context) {
    _defaultFiatCurrency =
        _walletManager.getDefaultFiatCurrency(widget.walletIndex);
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Column(
                    children: <Widget>[
                      ListTileAsset(
                        widget.walletIndex,
                        _fiatCurrencies[index],
                        _defaultFiatCurrency,
                      ),
                      const ListDivider(),
                    ],
                  );
                },
                childCount: _fiatCurrencies.length,
              ),
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
    );
  }
}

class ListTileAsset extends StatelessWidget {
  ListTileAsset(this.walletIndex, this.fiatCurrency, this.defaultFiatCurrency,
      {Key? key})
      : super(key: key);

  final int walletIndex;
  final Currency fiatCurrency;
  final Currency defaultFiatCurrency;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await _walletManager.setDefaultFiatCurrency(walletIndex, fiatCurrency);
        Navigator.pop(context);
      },
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Text(
              '${fiatCurrency.code}     ${fiatCurrency.name}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Visibility(
              visible:
                  fiatCurrency.code == defaultFiatCurrency.code ? true : false,
              child: const Icon(
                CupertinoIcons.check_mark,
                color: kYellowColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
