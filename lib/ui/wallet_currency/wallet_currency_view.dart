import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../constants/constants.dart' as constants;
import '../../models/currency.dart';
import '../../services/wallet_manager.dart';
import '../../themes/custom_icons.dart';
import '../../themes/theme_data.dart';
import '../../widgets/flat_button.dart';
import '../../widgets/list_divider.dart';
import '../../widgets/safe_area.dart';
import 'wallet_currency_view_model.dart';

class WalletCurrencyView extends StatelessWidget {
  const WalletCurrencyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<WalletCurrencyViewModel>.reactive(
      viewModelBuilder: () => WalletCurrencyViewModel(),
      onModelReady: (viewModel) => viewModel.initialise(context),
      builder: (context, model, child) => SafeAreaX(
        appBar: AppBar(
          centerTitle: true,
          title: titleIcon,
          backgroundColor: customBlack,
          automaticallyImplyLeading: false,
        ),
        bottomBar: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const CustomFlatButton(
            textLabel: 'Cancel',
            buttonColor: customDarkBackground,
            fontColor: customWhite,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Column(
                    children: <Widget>[
                      ListTileAsset(
                        model.walletIndex,
                        constants.fiatCurrencies[index],
                        model.defaultFiatCurrency,
                      ),
                      const ListDivider(),
                    ],
                  );
                },
                childCount: constants.fiatCurrencies.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ListTileAsset extends StatefulWidget {
  const ListTileAsset(
      this.walletIndex, this.fiatCurrency, this.defaultFiatCurrency,
      {Key? key})
      : super(key: key);

  final int walletIndex;
  final Currency fiatCurrency;
  final Currency defaultFiatCurrency;

  @override
  State<ListTileAsset> createState() => _ListTileAssetState();
}

class _ListTileAssetState extends State<ListTileAsset> {
  var walletManager = WalletManager();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: customDarkBackground,
      child: GestureDetector(
        onTap: () async {
          await walletManager.setDefaultFiatCurrency(
              widget.walletIndex, widget.fiatCurrency);
          await walletManager.setDefaultCurrency(
              widget.walletIndex, widget.fiatCurrency);
          if (!mounted) return;
          Navigator.pop(context);
        },
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Text(
                '${widget.fiatCurrency.code}     ${widget.fiatCurrency.name}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Visibility(
                visible:
                    widget.fiatCurrency.code == widget.defaultFiatCurrency.code
                        ? true
                        : false,
                child: const Icon(
                  CupertinoIcons.check_mark,
                  color: customYellow,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
