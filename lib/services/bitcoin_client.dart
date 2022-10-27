import 'dart:convert';
import 'dart:typed_data';

import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:bitcoin_dart/bitcoin_dart.dart';

import '../models/derivation_path.dart';
import 'network_helper.dart';

class BitcoinClient {
  late String address;
  late bool readOnlyClient;
  late String seed;

  NetworkType network = bitcoin;
  int purpose = 84;
  int coinType = 0;

  final NetworkHelper _networkHelper = NetworkHelper();
  static const _denominator = 100000000;

  BitcoinClient(this.seed) {
    readOnlyClient = false;
    var walletIndex = 0;
    address = getAddress(walletIndex);
  }

  BitcoinClient.readonly(this.address) {
    readOnlyClient = true;
    address = address;
  }

  String getAddress(int walletIndex) {
    if (walletIndex < 0) throw ('index must be greater than zero');

    late String address;
    var seedUint8List = bip39.mnemonicToSeed(seed);
    var root = bip32.BIP32.fromSeed(seedUint8List);
    var network = coinType == 1 ? testnet : bitcoin;

    // BIP44 - Multi-account hierarchy for deterministic wallets (Legacy).
    var node = root.derivePath("m/$purpose'/$coinType'/0'/0/$walletIndex");
    if (purpose == 44) {
      address =
          P2PKH(data: PaymentData(pubkey: node.publicKey), network: network)
              .data
              .address!;
    }
    // BIP49 - Derivation scheme for P2WPKH-nested-in-P2SH based accounts (Segwit).
    else if (purpose == 49) {
      address = P2SH(
              data: PaymentData(
                  redeem: P2WPKH(
                          data: PaymentData(pubkey: node.publicKey),
                          network: network)
                      .data),
              network: network)
          .data
          .address!;
    }
    // BIP84 - Derivation scheme for P2WPKH based accounts (native Segwit).
    else if (purpose == 84) {
      address =
          P2WPKH(data: PaymentData(pubkey: node.publicKey), network: network)
              .data
              .address!;
    }
    // Unsupported derivation scheme.
    else {
      throw ('unsupported derivation scheme');
    }
    return address;
  }

  Future<List> getBalance(String address) async {
    var balances = [];
    var uri = getExplorerAddressUrl(address);
    var responseBody = await _networkHelper.fetchData(uri);
    var funded = jsonDecode(responseBody)['chain_stats']['funded_txo_sum'];
    var spend = jsonDecode(responseBody)['chain_stats']['spent_txo_sum'];
    var amount = (funded - spend) / _denominator;
    balances.add({'amount': amount});
    return balances;
  }

  String getExplorerAddressUrl(String address) {
    return '${getExplorerUrl()}/address/$address';
  }

  String getExplorerTransactionUrl(String txId) {
    return '${getExplorerUrl()}/tx/$txId';
  }

  String getExplorerUrl() {
    if (network == bitcoin) {
      return 'https://blockstream.info/api';
    } else if (network == testnet) {
      return 'https://blockstream.info/testnet/api';
    } else {
      throw ArgumentError('Unsupported network');
    }
  }

  Future<Map> getFees() async {
    var uri = 'https://app.bitgo.com/api/v2/btc/tx/fee';
    var responseBody = await _networkHelper.fetchData(uri);
    var rawFeesPerKb = jsonDecode(responseBody);
    var feeByBlockTarget = rawFeesPerKb['feeByBlockTarget'];

    var fastest = rawFeesPerKb['feePerKb'];
    var slow = feeByBlockTarget['6'] ?? fastest;
    var average = feeByBlockTarget['3'] ?? ((fastest + slow) / 2).ceil();
    var fast = feeByBlockTarget['2'] ?? ((fastest + average) / 2).ceil();

    Map fees = {
      "type": "kilobyte",
      "fastest": fastest,
      "fast": fast,
      "average": average,
    };
    return fees;
  }

  NetworkType getNetwork() {
    return network;
  }

  Uint8List getSeed(String mnemonic, {String passphrase = ""}) {
    if (!validateMnemonic(mnemonic)) throw ArgumentError('Invalid mnemonic ');
    var seed = bip39.mnemonicToSeed(mnemonic, passphrase: passphrase);
    return seed;
  }

  String getSeedHex(String mnemonic, {String passphrase = ""}) {
    if (!validateMnemonic(mnemonic)) throw ArgumentError('Invalid mnemonic');
    var seedHex = bip39.mnemonicToSeedHex(mnemonic, passphrase: passphrase);
    return seedHex;
  }

  Future<Map> getTransactionData(String txId) async {
    var txData = {};

    var uri = getExplorerTransactionUrl(txId);
    var responseBody = await _networkHelper.fetchData(uri);
    var rawTx = jsonDecode(responseBody);

    var confirmed = rawTx['status']['confirmed'];
    var hash = rawTx['status']['block_hash'];
    var date = DateTime.now();
    if (confirmed == true) {
      var epoch = rawTx['status']['block_time'];
      date = DateTime.fromMillisecondsSinceEpoch(epoch * 1000, isUtc: false);
    }

    List<Map> from = [];
    for (Map txMap in rawTx['vin']) {
      txMap.forEach((key, value) {
        if (key == 'prevout') {
          Map prevoutMap = value;
          late String address;
          late double amount;
          prevoutMap.forEach((subkey, subvalue) {
            if (subkey == 'scriptpubkey_address') address = subvalue;
            if (subkey == 'value') amount = subvalue / _denominator;
          });
          if (address.isNotEmpty) {
            var map = {'address': address, 'amount': amount};
            from.add(map);
          }
        }
      });
    }

    List<Map> to = [];
    for (Map txMap in rawTx['vout']) {
      late String address;
      late double amount;
      txMap.forEach((key, value) {
        if (key == 'scriptpubkey_address') address = value;
        if (key == 'value') amount = value / _denominator;
      });
      if (address.isNotEmpty) {
        var map = {'address': address, 'amount': amount};
        to.add(map);
      }
    }

    if (rawTx != null) {
      txData.addAll({
        'from': from,
        'to': to,
        'date': date,
        'type': "transfer",
        'hash': hash,
        'confirmations': confirmed,
      });
    }
    return txData;
  }

  Future getTransactionAddressStats(String address) async {
    // Returns mempool and chain transaction stats.
    var addressUri = getExplorerAddressUrl(address);
    var addrResponseBody = await _networkHelper.fetchData(addressUri);
    return jsonDecode(addrResponseBody);
  }

  Future<List> getTransactions(String address, [int? limit]) async {
    // Current block.
    var blockHeightUri = '${getExplorerUrl()}/blocks/tip/height';
    var blockResponseBody = await _networkHelper.fetchData(blockHeightUri);
    var rawBlockHeight = jsonDecode(blockResponseBody);

    var addressUri = getExplorerAddressUrl(address);
    var addrResponseBody = await _networkHelper.fetchData(addressUri);
    var rawAddressStats = jsonDecode(addrResponseBody);

    // Retrieve the number of (mempool) transactions for an address.
    var txCount = rawAddressStats['chain_stats']['tx_count'] ?? 0;
    var mtxCount = rawAddressStats['mempool_stats']['tx_count'] ?? 0;

    // Blockstream api limits tx results to 25 per page.
    var pages = (txCount / 25).ceil();

    // Avoid retrieving more data then explicitly requested.
    if (limit != null && !limit.isNegative) {
      var pageLimit = (limit / 25).ceil();
      if (pageLimit < pages) pages = pageLimit;
    }

    List txData = [];

    if (txCount > 0) {
      // Confirmed transactions.
      var lastTx = '';
      for (int i = 0; i < pages; i++) {
        var txUri = '$addressUri/txs/chain/$lastTx';
        var txResponseBody = await _networkHelper.fetchData(txUri);
        var rawTxs = jsonDecode(txResponseBody);
        lastTx = rawTxs.last['txid'];

        for (var rawTx in rawTxs) {
          var block = rawTx['status']['block_height'];
          var txid = rawTx['txid'];
          var epoch = rawTx['status']['block_time'];
          var blockConf = rawBlockHeight - block + 1;
          var date =
              DateTime.fromMillisecondsSinceEpoch(epoch * 1000, isUtc: false);

          List<Map> from = [];
          for (Map txMap in rawTx['vin']) {
            txMap.forEach((key, value) {
              if (key == 'prevout') {
                Map prevOutMap = value ?? {};
                if (prevOutMap.isNotEmpty) {
                  var address = '';
                  var amount = 0.0;
                  prevOutMap.forEach((subkey, subvalue) {
                    if (subkey == 'scriptpubkey_address') address = subvalue;
                    if (subkey == 'value') amount = subvalue / _denominator;
                  });
                  if (address.isNotEmpty) {
                    var map = {'address': address, 'amount': amount};
                    from.add(map);
                  }
                }
              }
            });
          }

          List<Map> to = [];
          for (Map txMap in rawTx['vout']) {
            var address = '';
            var amount = 0.0;
            txMap.forEach((key, value) {
              if (key == 'scriptpubkey_address') address = value;
              if (key == 'value') amount = value / _denominator;
            });
            var map = {'address': address, 'amount': amount};
            to.add(map);
          }

          txData.add({
            'from': from,
            'to': to,
            'date': date,
            'type': "transfer",
            'txid': txid,
            'confirmations': blockConf,
          });
        }
      }
    }

    // Unconfirmed transactions (mempool)
    if (mtxCount > 0) {
      var mempoolUri = '${getExplorerAddressUrl(address)}/txs/mempool';
      var txmResponseBody = await _networkHelper.fetchData(mempoolUri);
      var rawTxs = jsonDecode(txmResponseBody);

      for (var rawTx in rawTxs) {
        var confirmed = rawTx['status']['confirmed'];
        var txid = rawTx['txid'];
        var date = DateTime.now();
        if (confirmed == true) {
          var epoch = rawTx['status']['block_time'];
          date =
              DateTime.fromMillisecondsSinceEpoch(epoch * 1000, isUtc: false);
        }

        List<Map> from = [];
        for (Map txMap in rawTx['vin']) {
          txMap.forEach((key, value) {
            if (key == 'prevout') {
              Map prevoutMap = value ?? {};
              if (prevoutMap.isNotEmpty) {
                var address = '';
                var amount = 0.0;
                prevoutMap.forEach((subkey, subvalue) {
                  if (subkey == 'scriptpubkey_address') address = subvalue;
                  if (subkey == 'value') amount = subvalue / _denominator;
                });
                if (address.isNotEmpty) {
                  var map = {'address': address, 'amount': amount};
                  from.add(map);
                }
              }
            }
          });
        }

        List<Map> to = [];
        for (Map txMap in rawTx['vout']) {
          var address = '';
          var amount = 0.0;
          txMap.forEach((key, value) {
            if (key == 'scriptpubkey_address') address = value;
            if (key == 'value') amount = value / _denominator;
          });
          var map = {'address': address, 'amount': amount};
          to.add(map);
        }

        txData.add({
          'from': from,
          'to': to,
          'date': date,
          'type': "transfer",
          'txid': txid,
          'confirmations': 0,
        });
      }
    }

    if (limit != null && !limit.isNegative) {
      return txData.sublist(0, limit);
    } else {
      return txData;
    }
  }

  void purgeClient() {
    // TODO: implement clearing sensitive data when done.
    //
    // When a wallet is "locked" the private key should be purged in each
    // client by setting it back to null.
  }

  void setDerivationPath(String derivationPath) {
    var dp = DerivationPath(derivationPath);
    var purpose = dp.purpose;
    var coinType = dp.coinType;
    var walletIndex = dp.addressIndex;

    // Sets the purpose.
    setPurpose(purpose);

    // Sets the network.
    if (coinType == 0) {
      setNetwork(bitcoin);
    } else if (coinType == 1) {
      setNetwork(testnet);
    }

    // Sets the address.
    if (readOnlyClient == false) address = getAddress(walletIndex);
  }

  void setNetwork(NetworkType network) {
    this.network = network;
    coinType = network == testnet ? 1 : 0;
    if (readOnlyClient == false) address = getAddress(0);
  }

  void setPurpose(int purpose) {
    // Only support BIP44, BIP49, and BIP84.
    if (purpose == 44 || purpose == 49 || purpose == 84) {
      this.purpose = purpose;
    }
  }

  void setPhrase(String mnemonic, int walletIndex) {
    seed = mnemonic;
    address = getAddress(walletIndex);
  }

  // TODO: implement function.
  String transfer(params) {
    var txHash =
        '59bbb95bbe740ad6acf24509d38f13f83ca49d6f11207f6a162999ffc5863b77';
    return txHash;
  }

  bool validateAddress(address) {
    var result = Address.validateAddress(address, network);
    return result;
  }
}

String generateMnemonic({int size = 12}) {
  // Generate a random mnemonic, defaults to 128-bits of entropy.
  var entropy = size == 24 ? 256 : 128;
  var mnemonic = bip39.generateMnemonic(strength: entropy);
  return mnemonic;
}

bool validateMnemonic(String mnemonic) {
  var result = bip39.validateMnemonic(mnemonic);
  return result;
}
