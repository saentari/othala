import 'dart:io';

import 'package:bitcoin_dart/bitcoin_dart.dart' as bitcoin;
import 'package:btc_address_validate/btc_address_validate.dart' as btc_address;
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;

import '../models/currency.dart';
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

  // Wallet client can be either read-only or full.
  late BitcoinClient _bitcoinClient;

  WalletManager(Box value) : super(value);

  changeWalletBackgroundImage(int walletIndex, UnsplashImage imageData) async {
    Wallet _wallet = value.getAt(walletIndex);
    _wallet.imageId = imageData.getId();
    // delete any previous background files.
    if (_wallet.imagePath.isNotEmpty) {
      _deleteFile(_wallet.imagePath);
    }
    _wallet.imagePath = await _downloadFile(imageData.getRegularUrl());
    value.putAt(walletIndex, _wallet);
  }

  Future<void> deleteWallet(int walletIndex) async {
    Wallet _wallet = value.getAt(walletIndex);

    // Delete wallet from Secure storage.
    StorageService _storageService = StorageService();
    _storageService.deleteSecureData(_wallet.key);

    // Delete wallet from Hive box.
    value.deleteAt(walletIndex);
  }

  /// Secure store wallet
  encryptToKeyStore(
      {String? mnemonic, String? address, bool generated = false}) async {
    String _key = UniqueKey().toString();
    String _secureData;

    String _type;
    if (mnemonic != null && mnemonic.isNotEmpty) {
      _secureData = mnemonic;
      _type = 'mnemonic';
      _bitcoinClient = BitcoinClient(mnemonic);
      address = _bitcoinClient.address;
    } else if (address != null && address.isNotEmpty) {
      _secureData = address;
      _type = 'address';
      _bitcoinClient = BitcoinClient.readonly(address);
    } else {
      throw ArgumentError('Missing input');
    }

    // Discover if address is testnet.
    String _network = getNetworkType(address);

    // Secure storage
    _storageService.writeSecureData(SecureItem(_key, _secureData));

    num _balance = 0;
    List<Transaction> _transactions = [];
    // Retrieve balance and transactions when imported
    if (generated == false) {
      _balance = await getBalance(_bitcoinClient.address);
      _transactions = await getTransactions(_bitcoinClient.address, _network);
    }

    // Random background image
    UnsplashImage _imageData = await _loadRandomImage(keyword: 'nature');
    String _imageId = _imageData.getId();
    String _localPath = await _downloadFile(_imageData.getRegularUrl());

    Currency _defaultFiatCurrency =
        Currency('USD', id: 'usd-us-dollars', name: 'US dollar', symbol: r'$');
    Currency _defaultCurrency =
        Currency('BTC', id: 'btc-bitcoin', name: 'Bitcoin', priceUsd: 1.0);

    String _walletName = getAddressName(address);

    // Store in Hive Box
    var _walletBox = Hive.box('walletBox');
    _walletBox.add(Wallet(
        _key,
        _walletName,
        _type,
        _network,
        [address],
        [_balance],
        _transactions,
        _imageId,
        _localPath,
        _defaultFiatCurrency,
        _defaultCurrency));

    // Get BTC/USD price for imported wallet
    if (generated == false) {
      updateFiatPrices();
    }
  }

  /// Check if there are missing transactions
  Future<bool> isSynced(index) async {
    Wallet _wallet = value.getAt(index);
    BitcoinClient _bitcoinClient = BitcoinClient.readonly(_wallet.address[0]);
    if (_wallet.network == 'testnet') {
      _bitcoinClient.setNetwork(bitcoin.testnet);
    }

    var _stats =
        await _bitcoinClient.getTransactionAddressStats(_bitcoinClient.address);

    int _blockExplorerTx =
        _stats['chain_stats']['tx_count'] + _stats['mempool_stats']['tx_count'];
    int _walletBoxTx = _wallet.transactions.length;

    if (_blockExplorerTx == _walletBoxTx) {
      return true;
    }
    return false;
  }

  /// Retrieve wallet balance.
  Future<double> getBalance(address) async {
    btc_address.Network? _network = btc_address.validate(address).network;

    _bitcoinClient = BitcoinClient.readonly(address);
    String _asset = 'BTC';
    if (_network == btc_address.Network.testnet) {
      _bitcoinClient.setNetwork(bitcoin.testnet);
      _asset = 'tBTC';
    }
    List _balances =
        await _bitcoinClient.getBalance(_bitcoinClient.address, 'BTC.$_asset');
    double _balance = _balances[0]['amount'];
    return _balance;
  }

  Currency getDefaultCurrency(int walletIndex) {
    Wallet _wallet = value.getAt(walletIndex);
    return _wallet.defaultCurrency;
  }

  Currency getDefaultFiatCurrency(int walletIndex) {
    Wallet _wallet = value.getAt(walletIndex);
    return _wallet.defaultFiatCurrency;
  }

  Future<List<Transaction>> getTransactions(address, network) async {
    BitcoinClient _bitcoinClient = BitcoinClient.readonly(address);
    if (network == 'testnet') {
      _bitcoinClient.setNetwork(bitcoin.testnet);
    }
    List<Transaction> _transactions = [];
    List _rawTxs = await _bitcoinClient.getTransactions(address);
    for (var _rawTx in _rawTxs) {
      String _transactionId = _rawTx['txid'];
      DateTime _transactionBroadcast = _rawTx['date'];
      int _blockConf = _rawTx['confirmations'];
      List<Map> _from = _rawTx['from'];
      List<Map> _to = _rawTx['to'];
      Transaction _tx = Transaction(
          _transactionId, _transactionBroadcast, _blockConf, _from, _to);
      _transactions.add(_tx);
    }
    return _transactions;
  }

  String getNetworkType(String address) {
    BitcoinClient _bitcoinClient = BitcoinClient.readonly(address);
    _bitcoinClient.setNetwork(bitcoin.testnet);
    if (_bitcoinClient.validateAddress(address) == true) {
      return 'testnet';
    } else {
      return 'bitcoin';
    }
  }

  setDefaultCurrency(int walletIndex, Currency currency) {
    Wallet _wallet = value.getAt(walletIndex);
    _wallet.defaultCurrency = currency;
    value.putAt(walletIndex, _wallet);
  }

  setDefaultFiatCurrency(int walletIndex, Currency currency) async {
    Wallet _wallet = value.getAt(walletIndex);
    _wallet.defaultFiatCurrency = currency;
    double price =
        await _exchangeManager.getPrice(_wallet.defaultFiatCurrency.code);
    _wallet.defaultFiatCurrency.priceUsd = price;
    value.putAt(walletIndex, _wallet);
  }

  Future<void> setNetwork(int walletIndex, String network) async {
    Wallet _wallet = value.getAt(walletIndex);

    // Get the seed to update the address on the new network
    String? _seed = await _storageService.readSecureData(_wallet.key);
    BitcoinClient _bitcoinClient = BitcoinClient(_seed!);

    if (network == 'bitcoin') {
      _wallet.network = 'bitcoin';
      _bitcoinClient.setNetwork(bitcoin.bitcoin);
    } else if (network == 'testnet') {
      _wallet.network = 'testnet';
      _bitcoinClient.setNetwork(bitcoin.testnet);
    }
    _wallet.address = [_bitcoinClient.getAddress(0)];

    // update box entry with new network & address.
    value.putAt(walletIndex, _wallet);
  }

  /// Update all wallet balances.
  Future<void> updateAllBalances() async {
    for (var index = 0; index < value.length; index++) {
      Wallet _wallet = value.getAt(index);
      BitcoinClient _bitcoinClient = BitcoinClient.readonly(_wallet.address[0]);
      if (_wallet.network == 'testnet') {
        _bitcoinClient.setNetwork(bitcoin.testnet);
      }
      List _balances =
          await _bitcoinClient.getBalance(_bitcoinClient.address, 'BTC.BTC');
      _wallet.balance = [_balances[0]['amount']];
      value.putAt(index, _wallet);
    }
  }

  /// Update a single wallet balance.
  Future<void> updateBalance(index) async {
    Wallet _wallet = value.getAt(index);
    BitcoinClient _bitcoinClient = BitcoinClient.readonly(_wallet.address[0]);
    if (_wallet.network == 'testnet') {
      _bitcoinClient.setNetwork(bitcoin.testnet);
    }
    List _balances =
        await _bitcoinClient.getBalance(_bitcoinClient.address, 'BTC.BTC');
    _wallet.balance = [_balances[0]['amount']];
    value.putAt(index, _wallet);
  }

  updateFiatPrices() async {
    // Avoids fetching duplicate prices
    var _walletBox = Hive.box('walletBox');
    Map _prices = {};
    for (int index = 0; index < _walletBox.length; index++) {
      Wallet _wallet = value.getAt(index);
      String _code = _wallet.defaultFiatCurrency.code;
      if (_prices.keys.contains(_code)) {
        _wallet.defaultFiatCurrency.priceUsd = _prices[_code];
      } else {
        double _price =
            await _exchangeManager.getPrice(_wallet.defaultFiatCurrency.code);
        _wallet.defaultFiatCurrency.priceUsd = _price;
        _prices.putIfAbsent(_code, () => _price);
      }
      value.putAt(index, _wallet);
    }
  }

  Future<void> updateTransactions(index) async {
    Wallet _wallet = value.getAt(index);
    BitcoinClient _bitcoinClient = BitcoinClient.readonly(_wallet.address[0]);
    if (_wallet.network == 'testnet') {
      _bitcoinClient.setNetwork(bitcoin.testnet);
    }
    List<Transaction> _transactions = [];
    List _rawTxs = await _bitcoinClient.getTransactions(_wallet.address[0]);
    for (var _rawTx in _rawTxs) {
      String _transactionId = _rawTx['txid'];
      DateTime _transactionBroadcast = _rawTx['date'];
      int _blockConf = _rawTx['confirmations'];
      List<Map> _from = _rawTx['from'];
      List<Map> _to = _rawTx['to'];
      Transaction _tx = Transaction(
          _transactionId, _transactionBroadcast, _blockConf, _from, _to);
      _transactions.add(_tx);
    }
    _wallet.transactions = _transactions;
    value.putAt(index, _wallet);
  }

  bool isValidPhrase(String input) {
    return validateMnemonic(input);
  }

  /// Requests a [UnsplashImage] for a given [keyword] query.
  /// If the given [keyword] is null, any random image is loaded.
  Future<UnsplashImage> _loadRandomImage({String? keyword}) async {
    UnsplashImage _imageData =
        await UnsplashImageProvider.loadRandomImage(keyword: keyword);

    return _imageData;
  }

  Future<String> _downloadFile(String url) async {
    // Default background image
    String _localPath =
        'assets/images/andreas-gucklhorn-mawU2PoJWfU-unsplash.jpeg';

    final response = await http.get(Uri.parse(url));

    // Get the image name
    final imageName = path.basename(url);

    // Get the document directory path
    final appDir = await path_provider.getApplicationDocumentsDirectory();
    // This is the saved image path
    _localPath = path.join(appDir.path, imageName);

    // Downloading
    final imageFile = File(_localPath);
    await imageFile.writeAsBytes(response.bodyBytes);
    return _localPath;
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
