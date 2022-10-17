import 'dart:io';

import 'package:bitcoin_dart/bitcoin_dart.dart' as bitcoin;
import 'package:btc_address_validate/btc_address_validate.dart' as btc_address;
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;

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
  final StorageService _storageService = StorageService();
  final ExchangeManager _exchangeManager = ExchangeManager();

  WalletManager(Box value) : super(value);

  changeWalletBackgroundImage(int walletIndex, UnsplashImage imageData) async {
    Wallet wallet = value.getAt(walletIndex);
    wallet.imageId = imageData.getId();
    // delete any previous background files.
    if (wallet.imagePath.isNotEmpty) {
      _deleteFile(wallet.imagePath);
    }
    wallet.imagePath = await _downloadFile(imageData.getRegularUrl());
    value.putAt(walletIndex, wallet);
  }

  Future<void> deleteWallet(int walletIndex) async {
    Wallet wallet = value.getAt(walletIndex);

    // Delete wallet from Secure storage.
    StorageService storageService = StorageService();
    storageService.deleteSecureData(wallet.key);

    // Delete wallet from Hive box.
    value.deleteAt(walletIndex);
  }

  /// Secure store wallet
  encryptToKeyStore(
      {String? mnemonic, String? address, bool generated = false}) async {
    String key = UniqueKey().toString();
    String secureData;
    String derivationPath;
    String type;
    int coinType = 0;
    int purpose = 84;
    String network = 'bitcoin';
    BitcoinClient bitcoinClient;
    if (mnemonic != null && mnemonic.isNotEmpty) {
      secureData = mnemonic;
      type = 'mnemonic';
      bitcoinClient = BitcoinClient(mnemonic);
      derivationPath = "m/84'/0'/0'/0";
      address = bitcoinClient.address;
    } else if (address != null && address.isNotEmpty) {
      secureData = address;
      type = 'address';
      bitcoinClient = BitcoinClient.readonly(address);

      btc_address.Address addressData = btc_address.validate(address);

      // Discover if address is testnet.
      if (addressData.network == btc_address.Network.testnet) {
        coinType = 1;
      }

      if (addressData.segwit == false) {
        purpose = 44;
      }
      if (addressData.type == btc_address.Type.p2sh) {
        purpose = 49;
      }
      derivationPath = "m/$purpose'/$coinType'/0'/0";
    } else {
      throw ArgumentError('Missing input');
    }

    // Secure storage
    _storageService.writeSecureData(SecureItem(key, secureData));

    num balance = 0;
    List<Transaction> transactions = [];
    // Retrieve balance and transactions when imported
    if (generated == false) {
      balance = await getBalance(bitcoinClient.address);
      transactions = await getTransactions(bitcoinClient.address, network);
    }

    // Random background image
    String imageId = '';
    String localPath = '';

    try {
      UnsplashImage imageData = await _loadRandomImage(keyword: 'nature');
      imageId = imageData.getId();
      localPath = await _downloadFile(imageData.getRegularUrl());
    } catch (e) {
      // Use default image
      localPath = 'assets/images/andreas-gucklhorn-mawU2PoJWfU-unsplash.jpeg';
    }

    Currency defaultFiatCurrency =
        Currency('USD', id: 'usd-us-dollars', name: 'US dollar', symbol: r'$');
    Currency defaultCurrency =
        Currency('BTC', id: 'btc-bitcoin', name: 'Bitcoin', priceUsd: 1.0);

    String walletName = getAddressName(bitcoinClient.address);

    // Store in Hive Box
    var walletBox = Hive.box('walletBox');
    walletBox.add(Wallet(
        key,
        walletName,
        type,
        derivationPath,
        [bitcoinClient.address],
        [balance],
        transactions,
        imageId,
        localPath,
        defaultFiatCurrency,
        defaultCurrency));

    // Get BTC/USD price for imported wallet
    if (generated == false) {
      updateFiatPrices();
    }
  }

  /// Check if there are missing transactions
  Future<bool> isSynced(index) async {
    Wallet wallet = value.getAt(index);
    BitcoinClient bitcoinClient = BitcoinClient.readonly(wallet.address[0]);
    if (getNetworkType(wallet.derivationPath) == 'testnet') {
      bitcoinClient.setNetwork(bitcoin.testnet);
    }

    final stats =
        await bitcoinClient.getTransactionAddressStats(bitcoinClient.address);

    // compare the number of transactions
    int blockExplorerTx =
        stats['chain_stats']['tx_count'] + stats['mempool_stats']['tx_count'];
    int walletBoxTx = wallet.transactions.length;

    // check if last saved tx is still pending
    bool pendingTx = false;
    if (walletBoxTx > 0 && wallet.transactions[0].confirmations < 6) {
      pendingTx = true;
    }

    // consider synced if nothing is pending and same amount of tx
    if (blockExplorerTx == walletBoxTx && pendingTx == false) {
      return true;
    }
    return false;
  }

  /// Retrieve wallet balance.
  Future<double> getBalance(address) async {
    btc_address.Network? network = btc_address.validate(address).network;

    BitcoinClient bitcoinClient = BitcoinClient.readonly(address);
    String asset = 'BTC';
    if (network == btc_address.Network.testnet) {
      bitcoinClient.setNetwork(bitcoin.testnet);
      asset = 'tBTC';
    }
    List balances =
        await bitcoinClient.getBalance(bitcoinClient.address, 'BTC.$asset');
    double balance = balances[0]['amount'];
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
    BitcoinClient bitcoinClient = BitcoinClient.readonly(address);
    if (network == 'testnet') {
      bitcoinClient.setNetwork(bitcoin.testnet);
    }
    List<Transaction> transactions = [];
    List rawTxs = await bitcoinClient.getTransactions(address);
    for (var rawTx in rawTxs) {
      String transactionId = rawTx['txid'];
      DateTime transactionBroadcast = rawTx['date'];
      int blockConf = rawTx['confirmations'];
      List<Map> from = rawTx['from'];
      List<Map> to = rawTx['to'];
      Transaction tx =
          Transaction(transactionId, transactionBroadcast, blockConf, from, to);
      transactions.add(tx);
    }
    return transactions;
  }

  String getNetworkType(String derivationPath) {
    final dp = DerivationPath();
    if (dp.getCoinType(derivationPath) == 0) {
      return 'bitcoin';
    } else if (dp.getCoinType(derivationPath) == 1) {
      return 'testnet';
    } else {
      return 'unsupported';
    }
  }

  /// Returns a list of wallets (of a certain type)
  getWallets(List<String> walletTypes) {
    List<Wallet> wallets = [];
    for (Wallet wallet in value.values) {
      if (walletTypes.contains(wallet.type)) {
        wallets.add(wallet);
      }
    }
    return wallets;
  }

  setWalletValue(int walletIndex, {String? name}) {
    Wallet wallet = value.getAt(walletIndex);
    if (name != null) {
      wallet.name = name;
    }
    value.putAt(walletIndex, wallet);
  }

  setDefaultCurrency(int walletIndex, Currency currency) {
    Wallet wallet = value.getAt(walletIndex);
    wallet.defaultCurrency = currency;
    value.putAt(walletIndex, wallet);
  }

  setDefaultFiatCurrency(int walletIndex, Currency currency) async {
    Wallet wallet = value.getAt(walletIndex);
    wallet.defaultFiatCurrency = currency;
    double price =
        await _exchangeManager.getPrice(wallet.defaultFiatCurrency.code);
    wallet.defaultFiatCurrency.priceUsd = price;
    value.putAt(walletIndex, wallet);
  }

  Future<void> setPurpose(int walletIndex, int purpose) async {
    Wallet wallet = value.getAt(walletIndex);

    // Get the seed to update the address on the new network
    String? seed = await _storageService.readSecureData(wallet.key);
    BitcoinClient bitcoinClient = BitcoinClient(seed!);

    // fetch stored network/cointype
    final derivationPath = DerivationPath();
    final coinType = derivationPath.getCoinType(wallet.derivationPath);

    // set wallet values
    wallet.derivationPath = "m/$purpose'/$coinType'/0'/0";
    bitcoinClient.setDerivationPath(wallet.derivationPath);
    wallet.address = [bitcoinClient.address];

    // update box entry with new network & address.
    value.putAt(walletIndex, wallet);
  }

  Future<void> setNetwork(int walletIndex, String network) async {
    Wallet wallet = value.getAt(walletIndex);

    // Get the seed to update the address on the new network
    String? seed = await _storageService.readSecureData(wallet.key);
    BitcoinClient bitcoinClient = BitcoinClient(seed!);

    final dp = DerivationPath();
    final purpose = dp.getPurpose(wallet.derivationPath);

    if (network == 'bitcoin') {
      wallet.derivationPath = "m/$purpose'/0'/0'/0";
    } else if (network == 'testnet') {
      wallet.derivationPath = "m/$purpose'/1'/0'/0";
    }
    bitcoinClient.setDerivationPath(wallet.derivationPath);
    wallet.address = [bitcoinClient.getAddress(0)];

    // update box entry with new network & address.
    value.putAt(walletIndex, wallet);
  }

  /// Update all wallet balances.
  Future<void> updateAllBalances() async {
    for (var index = 0; index < value.length; index++) {
      Wallet wallet = value.getAt(index);
      BitcoinClient bitcoinClient = BitcoinClient.readonly(wallet.address[0]);
      if (wallet.derivationPath == 'testnet') {
        bitcoinClient.setNetwork(bitcoin.testnet);
      }
      List balances =
          await bitcoinClient.getBalance(bitcoinClient.address, 'BTC.BTC');
      wallet.balance = [balances[0]['amount']];
      value.putAt(index, wallet);
    }
  }

  /// Update a single wallet balance.
  Future<void> updateBalance(index) async {
    Wallet wallet = value.getAt(index);
    BitcoinClient bitcoinClient = BitcoinClient.readonly(wallet.address[0]);
    bitcoinClient.setDerivationPath(wallet.derivationPath);
    // if (wallet.derivationPath == 'testnet') {
    //   bitcoinClient.setNetwork(bitcoin.testnet);
    // }
    List balances =
        await bitcoinClient.getBalance(bitcoinClient.address, 'BTC.BTC');
    wallet.balance = [balances[0]['amount']];
    value.putAt(index, wallet);
  }

  updateFiatPrices() async {
    // Avoids fetching duplicate prices
    var walletBox = Hive.box('walletBox');
    Map prices = {};
    for (int index = 0; index < walletBox.length; index++) {
      Wallet wallet = value.getAt(index);
      String code = wallet.defaultFiatCurrency.code;
      if (prices.keys.contains(code)) {
        wallet.defaultFiatCurrency.priceUsd = prices[code];
      } else {
        double price =
            await _exchangeManager.getPrice(wallet.defaultFiatCurrency.code);
        wallet.defaultFiatCurrency.priceUsd = price;
        prices.putIfAbsent(code, () => price);
      }
      value.putAt(index, wallet);
    }
  }

  Future<void> updateTransactions(index) async {
    Wallet wallet = value.getAt(index);
    BitcoinClient bitcoinClient = BitcoinClient.readonly(wallet.address[0]);
    bitcoinClient.setDerivationPath(wallet.derivationPath);
    // if (wallet.derivationPath == 'testnet') {
    //   bitcoinClient.setNetwork(bitcoin.testnet);
    // }
    List<Transaction> transactions = [];
    List rawTxs = await bitcoinClient.getTransactions(wallet.address[0]);
    for (var rawTx in rawTxs) {
      String transactionId = rawTx['txid'];
      DateTime transactionBroadcast = rawTx['date'];
      int blockConf = rawTx['confirmations'];
      List<Map> from = rawTx['from'];
      List<Map> to = rawTx['to'];
      Transaction tx =
          Transaction(transactionId, transactionBroadcast, blockConf, from, to);
      transactions.add(tx);
    }
    wallet.transactions = transactions;
    value.putAt(index, wallet);
  }

  bool isValidPhrase(String input) {
    return validateMnemonic(input);
  }

  /// Requests a [UnsplashImage] for a given [keyword] query.
  /// If the given [keyword] is null, any random image is loaded.
  Future<UnsplashImage> _loadRandomImage({String? keyword}) async {
    UnsplashImage imageData =
        await UnsplashImageProvider.loadRandomImage(keyword: keyword);

    return imageData;
  }

  Future<String> _downloadFile(String url) async {
    // Default background image
    String localPath =
        'assets/images/andreas-gucklhorn-mawU2PoJWfU-unsplash.jpeg';

    final response = await http.get(Uri.parse(url));

    // Get the image name
    final imageName = path.basename(url);

    // Get the document directory path
    final appDir = await path_provider.getApplicationDocumentsDirectory();
    // This is the saved image path
    localPath = path.join(appDir.path, imageName);

    // Downloading
    final imageFile = File(localPath);
    await imageFile.writeAsBytes(response.bodyBytes);
    return localPath;
  }

  Future<void> _deleteFile(String localPath) async {
    try {
      await File(localPath).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Unable to delete file.');
      }
    }
  }
}
