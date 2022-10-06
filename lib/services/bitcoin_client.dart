import 'dart:convert';
import 'dart:typed_data';

import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:bitcoin_dart/bitcoin_dart.dart';

import 'network_helper.dart';

class BitcoinClient {
  late String address;
  late bool readOnlyClient;
  late String seed;

  NetworkType network = bitcoin;

  final NetworkHelper _networkHelper = NetworkHelper();

  static const _denominator = 100000000;

  BitcoinClient(this.seed) {
    readOnlyClient = false;
    int walletIndex = 0;
    address = getAddress(walletIndex);
  }

  BitcoinClient.readonly(this.address) {
    readOnlyClient = true;
    address = address;
  }

  getAddress(walletIndex) {
    if (walletIndex < 0) {
      throw ('index must be greater than zero');
    }

    final String? address;
    final seedUint8List = bip39.mnemonicToSeed(seed);
    final root = bip32.BIP32.fromSeed(seedUint8List);

    // BIP84 (BIP44 for native segwit)
    if (network == testnet) {
      final node = root.derivePath("m/84'/1'/0'/0/$walletIndex");
      address =
          P2WPKH(data: PaymentData(pubkey: node.publicKey), network: testnet)
              .data
              .address;
    } else {
      final node = root.derivePath("m/84'/0'/0'/0/$walletIndex");
      address = P2WPKH(data: PaymentData(pubkey: node.publicKey)).data.address;
    }

    return address;
  }

  getBalance(address, assets) async {
    List balances = [];

    String uri = '${getExplorerAddressUrl(address)}';
    String responseBody = await _networkHelper.getData(uri);
    num funded = jsonDecode(responseBody)['chain_stats']['funded_txo_sum'];
    num spend = jsonDecode(responseBody)['chain_stats']['spent_txo_sum'];
    num amount = (funded - spend) / _denominator;

    String asset;
    network == testnet ? asset = 'tBTC' : asset = 'BTC';

    balances.add({
      'asset': 'BTC.$asset',
      'amount': amount,
      'image': 'https://s2.coinmarketcap.com/static/img/coins/64x64/1.png'
    });

    return balances;
  }

  getExplorerAddressUrl(address) {
    return '${getExplorerUrl()}/address/$address';
  }

  getExplorerTransactionUrl(txId) {
    return '${getExplorerUrl()}/tx/$txId';
  }

  getExplorerUrl() {
    if (network == bitcoin) {
      return 'https://blockstream.info/api';
    } else if (network == testnet) {
      return 'https://blockstream.info/testnet/api';
    } else {
      throw ArgumentError('Unsupported network');
    }
  }

  getFees() async {
    String uri = 'https://app.bitgo.com/api/v2/btc/tx/fee';
    String responseBody = await _networkHelper.getData(uri);
    Map rawFeesPerKb = jsonDecode(responseBody);
    Map feeByBlockTarget = rawFeesPerKb['feeByBlockTarget'];

    int fastest = rawFeesPerKb['feePerKb'];
    int slow = feeByBlockTarget['6'] ?? fastest;
    int average = feeByBlockTarget['3'] ?? ((fastest + slow) / 2).ceil();
    int fast = feeByBlockTarget['2'] ?? ((fastest + average) / 2).ceil();

    Map fees = {
      "type": "kilobyte",
      "fastest": fastest,
      "fast": fast,
      "average": average,
    };
    return fees;
  }

  getNetwork() {
    return network;
  }

  getSeed(String mnemonic, {String passphrase = ""}) {
    // if (!validateMnemonic(mnemonic)) {
    //   throw new ArgumentError(_INVALID_MNEMONIC);
    // }
    Uint8List seed = bip39.mnemonicToSeed(mnemonic, passphrase: passphrase);
    return seed;
  }

  getSeedHex(String mnemonic, {String passphrase = ""}) {
    if (!validateMnemonic(mnemonic)) {
      throw ArgumentError('Invalid BIP39 phrase');
    }
    String seedHex = bip39.mnemonicToSeedHex(mnemonic, passphrase: passphrase);

    return seedHex;
  }

  getTransactionData(txId) async {
    var txData = {};

    String uri = '${getExplorerTransactionUrl(txId)}';
    String responseBody = await _networkHelper.getData(uri);
    var rawTx = jsonDecode(responseBody);

    var confirmed = rawTx['status']['confirmed'];
    var hash = rawTx['status']['block_hash'];
    var date = DateTime.now();
    if (confirmed == true) {
      var epoch = rawTx['status']['block_time'];
      date = DateTime.fromMillisecondsSinceEpoch(epoch * 1000, isUtc: false);
    }

    List<Map> from = [];
    rawTx['vin'].forEach((tx) {
      Map txMap = tx;
      txMap.forEach((key, value) {
        if (key == 'prevout') {
          Map prevoutMap = value;
          late String address;
          late double amount;
          prevoutMap.forEach((subkey, subvalue) {
            if (subkey == 'scriptpubkey_address') {
              address = subvalue;
            }
            if (subkey == 'value') {
              amount = subvalue / _denominator;
            }
          });
          if (address.isNotEmpty) {
            var map = {'address': address, 'amount': amount};
            from.add(map);
          }
        }
      });
    });

    List<Map> to = [];
    rawTx['vout'].forEach((tx) {
      Map txMap = tx;
      late String address;
      late double amount;
      txMap.forEach((key, value) {
        if (key == 'scriptpubkey_address') {
          address = value;
        }

        if (key == 'value') {
          amount = value / _denominator;
        }
      });
      if (address.isNotEmpty) {
        var map = {'address': address, 'amount': amount};
        to.add(map);
      }
    });

    String asset;
    network == testnet ? asset = 'tBTC' : asset = 'BTC';

    if (rawTx != null) {
      txData.addAll({
        'asset': 'BTC.$asset',
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

  getTransactionAddressStats(address) async {
    // Returns mempool and chain transaction stats
    String addressUri = '${getExplorerAddressUrl(address)}';
    String addrResponseBody = await _networkHelper.getData(addressUri);

    return jsonDecode(addrResponseBody);
  }

  getTransactions(address, [limit]) async {
    // Current block
    String blockHeightUri = '${getExplorerUrl()}/blocks/tip/height';
    String blockResponseBody = await _networkHelper.getData(blockHeightUri);
    int rawBlockHeight = jsonDecode(blockResponseBody);

    String addressUri = '${getExplorerAddressUrl(address)}';
    String addrResponseBody = await _networkHelper.getData(addressUri);
    var rawAddressStats = jsonDecode(addrResponseBody);

    // Retrieve the number of (mempool) transactions for an address.
    int txCount = rawAddressStats['chain_stats']['tx_count'] ?? 0;
    int mtxCount = rawAddressStats['mempool_stats']['tx_count'] ?? 0;

    // Blockstream api limits tx results to 25 per page.
    int pages = (txCount / 25).ceil();

    // Avoid retrieving more data then explicitly requested.
    if (limit != null) {
      int pageLimit = (limit / 25).ceil();
      if (pageLimit < pages) {
        pages = pageLimit;
      }
    }

    List txData = [];

    if (txCount > 0) {
      // Confirmed transactions
      String lastTx = '';
      for (int i = 0; i < pages; i++) {
        String txUri = '$addressUri/txs/chain/$lastTx';
        String txResponseBody = await _networkHelper.getData(txUri);
        var rawTxs = jsonDecode(txResponseBody);
        lastTx = rawTxs.last['txid'];

        for (var rawTx in rawTxs) {
          int block = rawTx['status']['block_height'];
          String txid = rawTx['txid'];
          var epoch = rawTx['status']['block_time'];
          int blockConf = rawBlockHeight - block + 1;
          var date =
              DateTime.fromMillisecondsSinceEpoch(epoch * 1000, isUtc: false);

          List<Map> from = [];
          rawTx['vin'].forEach((tx) {
            Map txMap = tx;
            txMap.forEach((key, value) {
              if (key == 'prevout') {
                Map prevOutMap = value ?? {};
                if (prevOutMap.isNotEmpty) {
                  String address = '';
                  double amount = 0.0;
                  prevOutMap.forEach((subkey, subvalue) {
                    if (subkey == 'scriptpubkey_address') {
                      address = subvalue;
                    }
                    if (subkey == 'value') {
                      amount = subvalue / _denominator;
                    }
                  });
                  if (address.isNotEmpty) {
                    var map = {'address': address, 'amount': amount};
                    from.add(map);
                  }
                }
              }
            });
          });

          List<Map> to = [];
          rawTx['vout'].forEach((tx) {
            Map txMap = tx;
            String address = '';
            double amount = 0.0;
            txMap.forEach((key, value) {
              if (key == 'scriptpubkey_address') {
                address = value;
              }
              if (key == 'value') {
                amount = value / _denominator;
              }
            });
            var map = {'address': address, 'amount': amount};
            to.add(map);
          });

          String asset;
          network == testnet ? asset = 'tBTC' : asset = 'BTC';

          txData.add({
            'asset': 'BTC.$asset',
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
      String mempoolUri = '${getExplorerAddressUrl(address)}/txs/mempool';
      String txmResponseBody = await _networkHelper.getData(mempoolUri);
      var rawTxs = jsonDecode(txmResponseBody);

      for (var rawTx in rawTxs) {
        var confirmed = rawTx['status']['confirmed'];
        String txid = rawTx['txid'];
        var date = DateTime.now();
        if (confirmed == true) {
          var epoch = rawTx['status']['block_time'];
          date =
              DateTime.fromMillisecondsSinceEpoch(epoch * 1000, isUtc: false);
        }

        List<Map> from = [];
        rawTx['vin'].forEach((tx) {
          Map txMap = tx;
          txMap.forEach((key, value) {
            if (key == 'prevout') {
              Map prevoutMap = value ?? {};
              if (prevoutMap.isNotEmpty) {
                String address = '';
                double amount = 0.0;
                prevoutMap.forEach((subkey, subvalue) {
                  if (subkey == 'scriptpubkey_address') {
                    address = subvalue;
                  }
                  if (subkey == 'value') {
                    amount = subvalue / _denominator;
                  }
                });
                if (address.isNotEmpty) {
                  var map = {'address': address, 'amount': amount};
                  from.add(map);
                }
              }
            }
          });
        });

        List<Map> to = [];
        rawTx['vout'].forEach((tx) {
          Map txMap = tx;
          String address = '';
          double amount = 0.0;
          txMap.forEach((key, value) {
            if (key == 'scriptpubkey_address') {
              address = value;
            }
            if (key == 'value') {
              amount = value / _denominator;
            }
          });
          var map = {'address': address, 'amount': amount};
          to.add(map);
        });

        String asset;
        network == testnet ? asset = 'tBTC' : asset = 'BTC';

        txData.add({
          'asset': 'BTC.$asset',
          'from': from,
          'to': to,
          'date': date,
          'type': "transfer",
          'txid': txid,
          'confirmations': 0,
        });
      }
    }

    if (limit == null) {
      return txData;
    } else {
      return txData.sublist(0, limit);
    }
  }

  purgeClient() {
    // When a wallet is "locked" the private key should be purged in each client by setting it back to null.
  }

  setNetwork(newNetwork) {
    network = newNetwork;
    if (readOnlyClient == false) {
      address = getAddress(0);
    }
  }

  setPhrase(mnemonic, walletIndex) {
    seed = mnemonic;
    address = getAddress(walletIndex);
    return address;
  }

  transfer(params) {
    String txHash =
        '59bbb95bbe740ad6acf24509d38f13f83ca49d6f11207f6a162999ffc5863b77';
    return txHash;
  }

  validateAddress(address) {
    bool result = Address.validateAddress(address, network);
    return result;
  }
}

generateMnemonic({int size = 12}) {
  // Generate a random mnemonic (uses crypto.randomBytes under the hood), defaults to 128-bits of entropy.

  int entropy = size == 24 ? 256 : 128;
  String mnemonic = bip39.generateMnemonic(strength: entropy);
  return mnemonic;
}

validateMnemonic(String mnemonic) {
  bool result = bip39.validateMnemonic(mnemonic);
  return result;
}
