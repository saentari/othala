import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../themes/custom_icons.dart';
import '../../themes/theme_data.dart';
import '../../widgets/flat_button.dart';
import '../../widgets/list_divider.dart';
import '../../widgets/list_item.dart';
import '../../widgets/safe_area.dart';
import 'wallet_settings_view_model.dart';

class WalletSettingsView extends StatelessWidget {
  const WalletSettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<WalletSettingsViewModel>.reactive(
      viewModelBuilder: () => WalletSettingsViewModel(),
      onModelReady: (viewModel) => viewModel.initialise(context),
      builder: (context, model, child) => SafeAreaX(
        appBar: AppBar(
          centerTitle: true,
          title: titleIcon,
          backgroundColor: customBlack,
          automaticallyImplyLeading: false,
        ),
        bottomBar: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const CustomFlatButton(
            textLabel: 'Close',
            buttonColor: customDarkBackground,
            fontColor: customWhite,
          ),
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(
                  context,
                  '/wallet_name_screen',
                  arguments: model.walletIndex,
                );
              },
              child: ListItem(
                'Description',
                subtitle: model.wallet.name,
                chevron: true,
              ),
            ),
            const ListDivider(),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/wallet_currency_screen',
                  arguments: model.walletIndex,
                );
              },
              child: ListItem(
                'Local currency',
                subtitle: model.defaultFiatCurrency,
                chevron: true,
              ),
            ),
            const ListDivider(),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/wallet_background_screen',
                  arguments: model.walletIndex,
                );
              },
              child: const ListItem(
                'Background image',
                subtitle: 'Select a new background image',
                chevron: true,
              ),
            ),
            const ListDivider(),
            GestureDetector(
              onTap: () {
                model.deleteWalletDialog(context, model.walletIndex);
              },
              child: const ListItem(
                'Delete',
                subtitle: 'Warning: may cause loss of funds',
                subtitleColor: customRed,
                chevron: true,
              ),
            ),
            Visibility(
              visible: model.wallet.type == 'mnemonic' ? true : false,
              child: const ListDivider(),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/wallet_network_screen',
                  arguments: model.walletIndex,
                );
              },
              child: Visibility(
                visible: model.wallet.type == 'mnemonic' ? true : false,
                child: ListItem(
                  'Toggle network',
                  subtitle:
                      'Selected network: ${model.walletManager.getNetworkType(model.wallet.derivationPath)}',
                  chevron: true,
                ),
              ),
            ),
            Visibility(
              visible: model.wallet.type == 'mnemonic' ? true : false,
              child: const ListDivider(),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/wallet_derivation_screen',
                  arguments: model.walletIndex,
                );
              },
              child: Visibility(
                visible: model.wallet.type == 'mnemonic' ? true : false,
                child: ListItem(
                  'Change derivation path',
                  subtitle: model.wallet.derivationPath,
                  chevron: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class WalletSettingsScreen extends StatefulWidget {
//   const WalletSettingsScreen({Key? key}) : super(key: key);
//
//   @override
//   WalletSettingsScreenState createState() => WalletSettingsScreenState();
// }
//
// class WalletSettingsScreenState extends State<WalletSettingsScreen> {
//   var walletManager = WalletManager();
//   var defaultFiatCurrency = 'US dollar';
//
//   late Wallet wallet;
//
//   @override
//   Widget build(BuildContext context) {
//     var walletIndex = ModalRoute.of(context)!.settings.arguments as int;
//     return ValueListenableBuilder(
//       valueListenable: Hive.box('walletBox').listenable(),
//       builder: (context, Box box, widget2) {
//         if (walletIndex < box.length) {
//           wallet = box.getAt(walletIndex);
//           defaultFiatCurrency =
//               walletManager.getDefaultFiatCurrency(walletIndex).name;
//         }
//         return SafeAreaX(
//           appBar: AppBar(
//             centerTitle: true,
//             title: titleIcon,
//             backgroundColor: customBlack,
//             automaticallyImplyLeading: false,
//           ),
//           bottomBar: GestureDetector(
//             onTap: () => Navigator.pop(context),
//             child: const CustomFlatButton(
//               textLabel: 'Close',
//               buttonColor: customDarkBackground,
//               fontColor: customWhite,
//             ),
//           ),
//           child: Column(
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   Navigator.pushReplacementNamed(
//                     context,
//                     '/wallet_name_screen',
//                     arguments: walletIndex,
//                   );
//                 },
//                 child: ListItem(
//                   'Description',
//                   subtitle: wallet.name,
//                   chevron: true,
//                 ),
//               ),
//               const ListDivider(),
//               GestureDetector(
//                 onTap: () {
//                   Navigator.pushNamed(
//                     context,
//                     '/wallet_currency_screen',
//                     arguments: walletIndex,
//                   );
//                 },
//                 child: ListItem(
//                   'Local currency',
//                   subtitle: defaultFiatCurrency,
//                   chevron: true,
//                 ),
//               ),
//               const ListDivider(),
//               GestureDetector(
//                 onTap: () {
//                   Navigator.pushNamed(
//                     context,
//                     '/wallet_background_screen',
//                     arguments: walletIndex,
//                   );
//                 },
//                 child: const ListItem(
//                   'Background image',
//                   subtitle: 'Select a new background image',
//                   chevron: true,
//                 ),
//               ),
//               const ListDivider(),
//               GestureDetector(
//                 onTap: () {
//                   deleteWalletDialog(walletIndex);
//                 },
//                 child: const ListItem(
//                   'Delete',
//                   subtitle: 'Warning: may cause loss of funds',
//                   subtitleColor: customRed,
//                   chevron: true,
//                 ),
//               ),
//               Visibility(
//                 visible: wallet.type == 'mnemonic' ? true : false,
//                 child: const ListDivider(),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   Navigator.pushNamed(
//                     context,
//                     '/wallet_network_screen',
//                     arguments: walletIndex,
//                   );
//                 },
//                 child: Visibility(
//                   visible: wallet.type == 'mnemonic' ? true : false,
//                   child: ListItem(
//                     'Toggle network',
//                     subtitle:
//                         'Selected network: ${walletManager.getNetworkType(wallet.derivationPath)}',
//                     chevron: true,
//                   ),
//                 ),
//               ),
//               Visibility(
//                 visible: wallet.type == 'mnemonic' ? true : false,
//                 child: const ListDivider(),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   Navigator.pushNamed(
//                     context,
//                     '/wallet_derivation_screen',
//                     arguments: walletIndex,
//                   );
//                 },
//                 child: Visibility(
//                   visible: wallet.type == 'mnemonic' ? true : false,
//                   child: ListItem(
//                     'Change derivation path',
//                     subtitle: wallet.derivationPath,
//                     chevron: true,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   void deleteWalletDialog(int walletIndex) {
//     showDialog(
//       barrierDismissible: true,
//       context: context,
//       builder: (context) {
//         return Dialog(
//           backgroundColor: customDarkNeutral1,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: SizedBox(
//             height: 200,
//             child: Column(
//               children: [
//                 Expanded(
//                   flex: 3,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                         child: const Center(
//                           child: Text(
//                             "Are you sure?",
//                             style: TextStyle(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 22.0,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                       ),
//                       Container(
//                         alignment: Alignment.center,
//                         padding: const EdgeInsets.all(16.0),
//                         child: const Center(
//                           child: Text(
//                             "Warning: Deleting without a backup, may result in permanent loss of your funds.",
//                             style: TextStyle(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 16.0,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   flex: 1,
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: GestureDetector(
//                           child: Container(
//                             decoration: const BoxDecoration(
//                               borderRadius: BorderRadius.only(
//                                 bottomLeft: Radius.circular(16),
//                               ),
//                               color: customYellow,
//                             ),
//                             child: const Center(
//                               child: Text(
//                                 "Delete",
//                                 style: TextStyle(
//                                     color: customDarkBackground,
//                                     fontSize: 18.0,
//                                     fontWeight: FontWeight.w600),
//                               ),
//                             ),
//                           ),
//                           onTap: () => deleteWallet(walletIndex),
//                         ),
//                       ),
//                       Expanded(
//                         child: GestureDetector(
//                           child: Container(
//                             decoration: const BoxDecoration(
//                               borderRadius: BorderRadius.only(
//                                 bottomRight: Radius.circular(16),
//                               ),
//                             ),
//                             child: const Center(
//                               child: Text(
//                                 "Cancel",
//                                 style: TextStyle(
//                                     color: customDarkForeground,
//                                     fontSize: 18.0,
//                                     fontWeight: FontWeight.w600),
//                               ),
//                             ),
//                           ),
//                           onTap: () {
//                             Navigator.pop(context);
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Future<void> deleteWallet(int walletIndex) async {
//     await walletManager.deleteWallet(walletIndex);
//     if (!mounted) return;
//     Navigator.of(context).pushNamedAndRemoveUntil(
//         '/home_screen', (Route<dynamic> route) => false);
//   }
// }
