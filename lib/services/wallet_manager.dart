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
      {String? mnemonic,
      String? address,
      bool generated = false,
      int? purpose = 84}) async {
    String key = UniqueKey().toString();
    String secureData;
    String derivationPath;
    String type;
    int coinType = 0;
    String network = 'bitcoin';
    BitcoinClient bitcoinClient;
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
      btc_address.Address addressData = btc_address.validate(address);
      // Discover if address is testnet.
      if (addressData.network == btc_address.Network.testnet) {
        coinType = 1;
        network = 'testnet';
      }
      if (addressData.segwit == false) {
        purpose = 44;
      }
      if (addressData.type == btc_address.Type.p2sh) {
        purpose = 49;
      }
      derivationPath = "m/$purpose'/$coinType'/0'/0";
      bitcoinClient.setDerivationPath(derivationPath);
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
        [
          Address(
            bitcoinClient.address,
            transactions: transactions,
          ),
        ],
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

  /// Retrieve wallet balance.
  Future<double> getBalance(address) async {
    btc_address.Network? network = btc_address.validate(address).network;

    BitcoinClient bitcoinClient = BitcoinClient.readonly(address);
    if (network == btc_address.Network.testnet) {
      bitcoinClient.setNetwork(bitcoin.testnet);
    }
    List balances = await bitcoinClient.getBalance(bitcoinClient.address);
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

  Future<void> setTransactions([int? walletIndex]) async {
    // Add either one specific or all wallets.
    List walletIndexes = [];
    if (walletIndex != null) {
      walletIndexes.add(walletIndex);
    } else {
      for (int i = 0; i < value.length; i++) {
        walletIndexes.add(i);
      }
    }

    for (int index in walletIndexes) {
      Wallet wallet = value.getAt(index);
      BitcoinClient bitcoinClient;
      List<Address> addresses = [];
      String address = wallet.addresses.first.address;
      final dp = DerivationPath(wallet.derivationPath);

      // For multi-address wallets scan for tx history.
      if (wallet.type == 'mnemonic') {
        final seed = await getWalletSeed(index);
        bitcoinClient = BitcoinClient(seed);
        dp.setAddressIndex(0);
      } else {
        bitcoinClient = BitcoinClient.readonly(address);
      }

      bool hasTxHistory = true;
      while (hasTxHistory) {
        bitcoinClient.setDerivationPath(wallet.derivationPath);
        if (bitcoinClient.readOnlyClient == false) {
          address = bitcoinClient.getAddress(dp.addressIndex);
        }

        final data = await bitcoinClient.getTransactionAddressStats(address);
        Address addressObj = Address(
          address,
          chainStats: data['chain_stats'],
          mempoolStats: data['mempool_stats'],
        );

        final txCountNew = data['chain_stats']['tx_count'] +
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
          // Are there new tx on blockchain or mempool?
          if (txCountNew != txCountOld) {
            List<Transaction> txNew = [];
            List rawTxs =
                await bitcoinClient.getTransactions(addressObj.address);
            for (var rawTx in rawTxs) {
              String transactionId = rawTx['txid'];
              DateTime transactionBroadcast = rawTx['date'];
              int blockConf = rawTx['confirmations'];
              List<Map> from = rawTx['from'];
              List<Map> to = rawTx['to'];
              Transaction tx = Transaction(
                  transactionId, transactionBroadcast, blockConf, from, to);
              txNew.add(tx);
            }
            addressObj.transactions = txNew;
          } else {
            // Add old list to new AddressObj
            if (txCountNew != 0) {
              addressObj.transactions = txOld;
            }
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
        // Add updated addressObj to wallet address list
        addresses.add(addressObj);
      }
      // Update wallet in box with active addresses.
      wallet.derivationPath = dp.derivationPath;
      wallet.addresses = addresses;
      value.putAt(index, wallet);
    }
  }

  String getNetworkType(String derivationPath) {
    final dp = DerivationPath(derivationPath);
    if (dp.coinType == 0) {
      return 'bitcoin';
    } else if (dp.coinType == 1) {
      return 'testnet';
    } else {
      return 'unsupported';
    }
  }

  // returns a specific wallet
  getWalletSeed(int index) async {
    final wallet = value.getAt(index);
    final seed = await _storageService.readSecureData(wallet.key) ?? '';

    return seed;
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
    final dp = DerivationPath(wallet.derivationPath);
    final coinType = dp.coinType;

    // set wallet values
    wallet.derivationPath = "m/$purpose'/$coinType'/0'/0";
    bitcoinClient.setDerivationPath(wallet.derivationPath);
    wallet.addresses[0] = Address(bitcoinClient.address);

    // update box entry with new network & address.
    value.putAt(walletIndex, wallet);
  }

  Future<void> setNetwork(int walletIndex, String network) async {
    Wallet wallet = value.getAt(walletIndex);

    // Get the seed to update the address on the new network
    String? seed = await _storageService.readSecureData(wallet.key);
    BitcoinClient bitcoinClient = BitcoinClient(seed!);

    final dp = DerivationPath(wallet.derivationPath);
    final purpose = dp.purpose;

    if (network == 'bitcoin') {
      wallet.derivationPath = "m/$purpose'/0'/0'/0";
    } else if (network == 'testnet') {
      wallet.derivationPath = "m/$purpose'/1'/0'/0";
    }
    bitcoinClient.setDerivationPath(wallet.derivationPath);
    wallet.addresses[0] = Address(bitcoinClient.address);

    // update box entry with new network & address.
    value.putAt(walletIndex, wallet);
  }

  /// Update all wallet balances.
  Future<void> updateAllBalances() async {
    for (var index = 0; index < value.length; index++) {
      Wallet wallet = value.getAt(index);
      BitcoinClient bitcoinClient =
          BitcoinClient.readonly(wallet.addresses[0].address);
      bitcoinClient.setDerivationPath(wallet.derivationPath);
      List balances = await bitcoinClient.getBalance(bitcoinClient.address);
      wallet.balance = [balances[0]['amount']];
      value.putAt(index, wallet);
    }
  }

  /// Update a single wallet balance.
  Future<void> updateBalance(index) async {
    Wallet wallet = value.getAt(index);
    BitcoinClient bitcoinClient =
        BitcoinClient.readonly(wallet.addresses[0].address);
    bitcoinClient.setDerivationPath(wallet.derivationPath);

    List balances = await bitcoinClient.getBalance(bitcoinClient.address);
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
    BitcoinClient bitcoinClient =
        BitcoinClient.readonly(wallet.addresses[0].address);
    bitcoinClient.setDerivationPath(wallet.derivationPath);

    for (Address addressObj in wallet.addresses) {
      List<Transaction> transactions = [];
      List rawTxs = await bitcoinClient.getTransactions(addressObj.address);
      for (var rawTx in rawTxs) {
        String transactionId = rawTx['txid'];
        DateTime transactionBroadcast = rawTx['date'];
        int blockConf = rawTx['confirmations'];
        List<Map> from = rawTx['from'];
        List<Map> to = rawTx['to'];
        Transaction tx = Transaction(
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
