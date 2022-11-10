import 'dart:developer';
import 'dart:io';

import 'package:bitcoin_dart/bitcoin_dart.dart' as bitcoin;
import 'package:btc_address_validate/btc_address_validate.dart' as btc_address;
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;

import '../models/address.dart';
import '../models/currency.dart';
import '../models/derivation_path.dart';
import '../models/secure_item.dart';
import '../models/transaction.dart';
import '../models/unsplash_image.dart';
import '../models/wallet.dart';
import '../services/bitcoin_client.dart';
import '../services/exchange_manager.dart';
import '../services/secure_storage.dart';
import '../services/unsplash_image_provider.dart';
import '../utils/utils.dart';

class WalletManager extends ValueNotifier<Box> {
  WalletManager() : super(Hive.box('walletBox'));

  Future<void> setWalletBackground(
      int walletIndex, UnsplashImage imageData) async {
    var wallet = value.getAt(walletIndex);
    wallet.imageId = imageData.getId();

    // Delete any previous background files.
    try {
      _deleteFile(wallet.imagePath);
    } catch (e) {
      log('Unable to delete image ${wallet.imagePath}');
    }
    wallet.imagePath = await _downloadFile(imageData.getRegularUrl());
    value.putAt(walletIndex, wallet);
  }

  Future<void> deleteWallet(int walletIndex) async {
    var wallet = value.getAt(walletIndex);

    // Delete wallet from Secure storage.
    var storageService = StorageService();
    storageService.deleteSecureData(wallet.key);

    // Delete wallet from Hive box.
    value.deleteAt(walletIndex);
  }

  // Store the wallet in a Hive Box and the recovery in secure storage.
  encryptToKeyStore({
    String? mnemonic,
    String? address,
    bool generated = false,
    int? purpose = 84,
  }) async {
    late String secureData;
    late String derivationPath;
    late String type;
    late BitcoinClient bitcoinClient;

    var key = UniqueKey().toString();
    var coinType = 0;
    var network = 'bitcoin';

    if (mnemonic != null && mnemonic.isNotEmpty) {
      secureData = mnemonic;
      type = 'mnemonic';
      derivationPath = "m/$purpose'/$coinType'/0'/0";
      bitcoinClient = BitcoinClient(mnemonic);
      bitcoinClient.setDerivationPath(derivationPath);
      address = bitcoinClient.address;
    } else if (address != null && address.isNotEmpty) {
      secureData = address;
      type = 'address';
      bitcoinClient = BitcoinClient.readonly(address);
      var addressData = btc_address.validate(address);
      // Discover if address is on testnet.
      if (addressData.network == btc_address.Network.testnet) {
        coinType = 1;
        network = 'testnet';
      }
      if (addressData.segwit == false) purpose = 44;
      if (addressData.type == btc_address.Type.p2sh) purpose = 49;
      derivationPath = "m/$purpose'/$coinType'/0'/0";
      bitcoinClient.setDerivationPath(derivationPath);
    } else {
      throw ArgumentError('Missing input');
    }
    // Write the [secureData] to secure storage.
    StorageService().writeSecureData(SecureItem(key, secureData));

    // Retrieve balance and transactions when imported.
    List<Transaction> transactions = [];
    if (generated == false) {
      transactions = await getTransactions(bitcoinClient.address, network);
    }

    // Retrieve a random `nature` background image.
    var imageId = '';
    var localPath = '';
    try {
      UnsplashImage imageData = await _loadRandomImage(keyword: 'nature');
      imageId = imageData.getId();
      localPath = await _downloadFile(imageData.getRegularUrl());
    } catch (e) {
      // If it fails, use the default image.
      localPath = 'assets/images/geran-de-klerk-qzgN45hseN0-unsplash.jpeg';
    }

    Currency defaultFiatCurrency =
        Currency('USD', id: 'usd-us-dollars', name: 'US dollar', symbol: r'$');
    Currency defaultCurrency =
        Currency('BTC', id: 'btc-bitcoin', name: 'Bitcoin', priceUsd: 1.0);

    // Store in Hive Box.
    var walletBox = Hive.box('walletBox');
    var walletName = getAddressName(bitcoinClient.address);
    var walletAddress = [
      Address(bitcoinClient.address, transactions: transactions)
    ];

    walletBox.add(Wallet(key, walletName, type, derivationPath, walletAddress,
        imageId, localPath, defaultFiatCurrency, defaultCurrency));

    // Get BTC/USD price for imported wallet.
    if (generated == false) updateFiatPrices();
  }

  // Retrieve wallet balance.
  Future<double> getBalance(address) async {
    var bitcoinClient = BitcoinClient.readonly(address);
    var network = btc_address.validate(address).network;

    if (network == btc_address.Network.testnet) {
      bitcoinClient.setNetwork(bitcoin.testnet);
    }

    var balances = await bitcoinClient.getBalance(bitcoinClient.address);
    var balance = balances[0]['amount'];
    return balance;
  }

  Currency getDefaultCurrency(int walletIndex) {
    Wallet wallet = value.getAt(walletIndex);
    return wallet.defaultCurrency;
  }

  Currency getDefaultFiatCurrency(int walletIndex) {
    Wallet wallet = value.getAt(walletIndex);
    return wallet.defaultFiatCurrency;
  }

  Future<List<Transaction>> getTransactions(address, network) async {
    var bitcoinClient = BitcoinClient.readonly(address);
    if (network == 'testnet') bitcoinClient.setNetwork(bitcoin.testnet);

    List<Transaction> transactions = [];
    List rawTxs = await bitcoinClient.getTransactions(address);
    for (var rawTx in rawTxs) {
      var transactionId = rawTx['txid'];
      var transactionBroadcast = rawTx['date'];
      var blockConf = rawTx['confirmations'];
      var from = rawTx['from'];
      var to = rawTx['to'];
      var tx =
          Transaction(transactionId, transactionBroadcast, blockConf, from, to);
      transactions.add(tx);
    }
    return transactions;
  }

  Future<void> setTransactions([int? walletIndex]) async {
    // Add either one specific or all wallets.
    var walletIndexes = [];
    if (walletIndex != null && !walletIndex.isNegative) {
      walletIndexes.add(walletIndex);
    } else {
      for (int i = 0; i < value.length; i++) {
        walletIndexes.add(i);
      }
    }

    for (int index in walletIndexes) {
      BitcoinClient bitcoinClient;
      List<Address> addresses = [];

      var wallet = value.getAt(index);
      var address = wallet.addresses.first.address;
      var dp = DerivationPath(wallet.derivationPath);

      // For multi-address wallets scan for tx history.
      if (wallet.type == 'mnemonic') {
        var seed = await getWalletSeed(index);
        bitcoinClient = BitcoinClient(seed);
        dp.setAddressIndex(0);
      } else {
        bitcoinClient = BitcoinClient.readonly(address);
      }

      var hasTxHistory = true;
      while (hasTxHistory) {
        bitcoinClient.setDerivationPath(wallet.derivationPath);
        if (bitcoinClient.readOnlyClient == false) {
          address = bitcoinClient.getAddress(dp.addressIndex);
        }

        var data = await bitcoinClient.getTransactionAddressStats(address);
        var addressObj = Address(
          address,
          chainStats: data['chain_stats'],
          mempoolStats: data['mempool_stats'],
        );

        var txCountNew = data['chain_stats']['tx_count'] +
                data['mempool_stats']['tx_count'] ??
            0;
        if (txCountNew > 0) {
          int txCountOld;
          List<Transaction>? txOld;
          // Check if old wallet has txs.
          try {
            txOld = wallet.addresses[dp.addressIndex].transactions;
            txCountOld = txOld!.length;
          } catch (e) {
            txCountOld = 0;
          }
          // Check for new txs on blockchain and mempool.
          if (txCountNew != txCountOld) {
            List<Transaction> txNew = [];
            List rawTxs =
                await bitcoinClient.getTransactions(addressObj.address);
            for (var rawTx in rawTxs) {
              var transactionId = rawTx['txid'];
              var transactionBroadcast = rawTx['date'];
              var blockConf = rawTx['confirmations'];
              var from = rawTx['from'];
              var to = rawTx['to'];
              var tx = Transaction(
                  transactionId, transactionBroadcast, blockConf, from, to);
              txNew.add(tx);
            }
            addressObj.transactions = txNew;
          } else {
            // Add old list to new AddressObj.
            if (txCountNew != 0) addressObj.transactions = txOld;
          }

          if (bitcoinClient.readOnlyClient == true) {
            // Read-only clients only have one address.
            hasTxHistory = false;
          } else {
            // Increment derivation path by one.
            dp.setAddressIndex(dp.addressIndex + 1);
          }
        } else {
          // If an address has no tx history, then break the loop.
          hasTxHistory = false;
        }
        // Add updated addressObj to wallet address list.
        addresses.add(addressObj);
      }
      // Update wallet in box with active addresses.
      wallet.derivationPath = dp.derivationPath;
      wallet.addresses = addresses;
      value.putAt(index, wallet);
    }
  }

  String getNetworkType(String derivationPath) {
    var dp = DerivationPath(derivationPath);
    if (dp.coinType == 0) {
      return 'bitcoin';
    } else if (dp.coinType == 1) {
      return 'testnet';
    } else {
      return 'unsupported';
    }
  }

  // Returns the recovery phrase if a [Wallet] has one.
  getWalletSeed(int index) async {
    var wallet = value.getAt(index);
    var storageService = StorageService();
    var phrase = await storageService.readSecureData(wallet.key) ?? '';
    return phrase;
  }

  // Returns a list of [Wallet] (of a certain type).
  List getWallets(List<String> walletTypes) {
    var wallets = [];
    for (Wallet wallet in value.values) {
      if (walletTypes.contains(wallet.type)) wallets.add(wallet);
    }
    return wallets;
  }

  setWalletValue(int walletIndex, {String? name}) {
    var wallet = value.getAt(walletIndex);
    if (name != null && name.isNotEmpty) wallet.name = name;
    value.putAt(walletIndex, wallet);
  }

  setDefaultCurrency(int walletIndex, Currency currency) {
    var wallet = value.getAt(walletIndex);
    wallet.defaultCurrency = currency;
    value.putAt(walletIndex, wallet);
  }

  setDefaultFiatCurrency(int walletIndex, Currency currency) async {
    var wallet = value.getAt(walletIndex);
    wallet.defaultFiatCurrency = currency;
    var price = await ExchangeManager().price(wallet.defaultFiatCurrency.code);
    wallet.defaultFiatCurrency.priceUsd = price;
    value.putAt(walletIndex, wallet);
  }

  Future<void> setPurpose(int walletIndex, int purpose) async {
    var wallet = value.getAt(walletIndex);

    // Get the seed to update the address on the new network.
    String? seed = await StorageService().readSecureData(wallet.key);
    var bitcoinClient = BitcoinClient(seed!);

    // Fetch stored network/cointype.
    var dp = DerivationPath(wallet.derivationPath);
    var coinType = dp.coinType;

    // Set wallet values.
    wallet.derivationPath = "m/$purpose'/$coinType'/0'/0";
    bitcoinClient.setDerivationPath(wallet.derivationPath);
    wallet.addresses[0] = Address(bitcoinClient.address);

    // Update box entry with new network & address.
    value.putAt(walletIndex, wallet);
  }

  Future<void> setNetwork(int walletIndex, String network) async {
    var wallet = value.getAt(walletIndex);

    // Get the seed to update the address on the new network
    String? seed = await StorageService().readSecureData(wallet.key);
    var bitcoinClient = BitcoinClient(seed!);

    var dp = DerivationPath(wallet.derivationPath);
    var purpose = dp.purpose;

    if (network == 'bitcoin') {
      wallet.derivationPath = "m/$purpose'/0'/0'/0";
    } else if (network == 'testnet') {
      wallet.derivationPath = "m/$purpose'/1'/0'/0";
    }
    bitcoinClient.setDerivationPath(wallet.derivationPath);
    wallet.addresses[0] = Address(bitcoinClient.address);

    // Update box entry with new network & address.
    value.putAt(walletIndex, wallet);
  }

  Future<void> updateFiatPrices() async {
    // Avoids fetching duplicate prices.
    var walletBox = Hive.box('walletBox');
    Map prices = {};
    for (int index = 0; index < walletBox.length; index++) {
      var wallet = value.getAt(index);
      var code = wallet.defaultFiatCurrency.code;
      if (prices.keys.contains(code)) {
        wallet.defaultFiatCurrency.priceUsd = prices[code];
      } else {
        var exchangeManager = ExchangeManager();
        var price =
            await exchangeManager.price(wallet.defaultFiatCurrency.code);
        wallet.defaultFiatCurrency.priceUsd = price;
        prices.putIfAbsent(code, () => price);
      }
      value.putAt(index, wallet);
    }
  }

  Future<void> updateTransactions(index) async {
    var wallet = value.getAt(index);
    var bitcoinClient = BitcoinClient.readonly(wallet.addresses[0].address);
    bitcoinClient.setDerivationPath(wallet.derivationPath);

    for (Address addressObj in wallet.addresses) {
      List<Transaction> transactions = [];
      List rawTxs = await bitcoinClient.getTransactions(addressObj.address);
      for (var rawTx in rawTxs) {
        var transactionId = rawTx['txid'];
        var transactionBroadcast = rawTx['date'];
        var blockConf = rawTx['confirmations'];
        var from = rawTx['from'];
        var to = rawTx['to'];
        var tx = Transaction(
            transactionId, transactionBroadcast, blockConf, from, to);
        transactions.add(tx);
      }
      addressObj.transactions = transactions;
    }

    value.putAt(index, wallet);
  }

  bool isValidPhrase(String input) {
    return validateMnemonic(input);
  }

  // Requests a [UnsplashImage] for a given [keyword] query.
  //
  // If the given [keyword] is null, any random image is loaded.
  Future<UnsplashImage> _loadRandomImage({String? keyword}) async {
    var imageData =
        await UnsplashImageProvider.loadRandomImage(keyword: keyword);
    return imageData;
  }

  Future<String> _downloadFile(String url) async {
    // Default background image.
    var localPath = 'assets/images/geran-de-klerk-qzgN45hseN0-unsplash.jpeg';
    var response = await http.get(Uri.parse(url));

    // Get the image name.
    var imageName = path.basename(url);

    // Get the document directory path.
    var appDir = await path_provider.getApplicationDocumentsDirectory();
    // This is the saved image path.
    localPath = path.join(appDir.path, imageName);

    // Download locally.
    var imageFile = File(localPath);
    await imageFile.writeAsBytes(response.bodyBytes);
    return localPath;
  }

  Future<void> _deleteFile(String localPath) async {
    try {
      await File(localPath).delete();
    } catch (e) {
      if (kDebugMode) print('Unable to delete file.');
    }
  }
}
