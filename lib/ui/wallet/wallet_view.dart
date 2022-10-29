import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../constants/constants.dart';
import '../../models/currency.dart';
import '../../services/wallet_manager.dart';
import '../../themes/custom_icons.dart';
import '../../themes/theme_data.dart';
import '../../utils/utils.dart';
import '../../widgets/flat_button.dart';
import '../../widgets/list_divider.dart';
import '../../widgets/list_item_transaction.dart';
import '../../widgets/safe_area.dart';
import 'wallet_view_model.dart';

class WalletView extends StatelessWidget {
  const WalletView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<WalletViewModel>.reactive(
      viewModelBuilder: () => WalletViewModel(),
      onModelReady: (viewModel) => viewModel.initialise(context),
      builder: (context, model, child) => SafeAreaX(
        appBar: AppBar(
          centerTitle: true,
          title: titleIcon,
          backgroundColor: customBlack,
          automaticallyImplyLeading: false,
        ),
        child: Column(
          children: <Widget>[
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Hero(
                  tag: 'imageHero',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: model.showImage(context, model.wallet.imagePath),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/wallet_settings_screen',
                        arguments: model.walletIndex,
                      );
                    },
                    icon: const Icon(Icons.more_vert),
                  ),
                ),
                Positioned(
                  top: 20.0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        model.wallet.name,
                        style: const TextStyle(
                          color: customWhite,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 60.0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        getNumberFormat(
                            currency: Currency('BTC'),
                            amount: model.amount,
                            decimalDigits: 8,
                            symbol: unicodeBitcoin),
                        style: const TextStyle(
                          color: customWhite,
                          fontSize: 32.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 110.0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        getNumberFormat(
                            currency: model.wallet.defaultFiatCurrency,
                            amount: model.balance),
                        style: const TextStyle(
                          color: customWhite,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            Expanded(
              child: RefreshIndicator(
                color: customBlack,
                backgroundColor: customYellow,
                onRefresh: () async {
                  final wm = WalletManager();
                  await wm.setTransactions(model.walletIndex);
                },
                child: ListView.separated(
                  separatorBuilder: (BuildContext context, int index) =>
                      const ListDivider(),
                  itemCount: model.transactions.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListItemTransaction(
                      model.transactions[index].address,
                      subtitle: model.transactions[index].dateTime,
                      value: model.transactions[index].amount,
                      subtitleValue: model.transactions[index].confirmations,
                    );
                  },
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const CustomFlatButton(
                      textLabel: 'Cancel',
                      buttonColor: customDarkBackground,
                      fontColor: customWhite,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
