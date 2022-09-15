import 'package:bip39/bip39.dart';
import 'package:btc_address_validate/btc_address_validate.dart' as btc_address;
import 'package:dart_lnurl/dart_lnurl.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../enums/input_type.dart';
import '../models/currency.dart';

String getNumberFormat(
    {required Currency currency,
    required num amount,
    String symbol = "",
    int decimalDigits = 2}) {
  NumberFormat numberFormat;

  if (currency.code == 'BTC') {
    amount == 0 ? decimalDigits = 0 : decimalDigits = 5;
    numberFormat = NumberFormat.currency(
        locale: "en_US", symbol: symbol, decimalDigits: decimalDigits);
  } else if (currency.code == 'SATS') {
    numberFormat = NumberFormat.currency(symbol: "", decimalDigits: 0);
    return numberFormat.format(amount).replaceAll(',', ' ');
  } else {
    if (amount > 10000 || amount < -10000) {
      decimalDigits = 0;
    }
    numberFormat = NumberFormat.currency(
        symbol: currency.symbol,
        locale: currency.locale != '' ? currency.locale : 'en_US',
        decimalDigits: decimalDigits);
  }
  return numberFormat.format(amount);
}

InputType? getInputType(String input, {String? language}) {
  String defaultLanguage = language ?? 'english';

  // Strip any bitcoin prefix
  input = input.replaceFirst(RegExp(r'bitcoin:', caseSensitive: false), '');

  // Check if valid mnemonic
  if (validateMnemonic(input, language: defaultLanguage)) {
    return InputType.mnemonic;
  }
  // Check if valid address
  else if (isValidAddress(input)) {
    return InputType.address;
  }
  // Check if valid lnurl
  else if (validateLnUrl(input)) {
    return InputType.lnurl;
  } else {
    return null;
  }
}

bool isValidAddress(String address) {
  try {
    btc_address.validate(address);
    return true;
  } catch (e) {
    return false;
  }
}

// walletDescriptor
String getAddressName(String address) {
  btc_address.Address _addressData = btc_address.validate(address);
  String _description = 'Wallet';
  String _type = describeEnum(_addressData.type as Enum);

  if (_addressData.network == btc_address.Network.testnet) {
    _description = 'Testnet $_description';
  }

  if (_addressData.segwit) {
    _description = 'Native Segwit $_description';
  } else {
    _description = 'Legacy $_description';
  }

  _description = '$_description (${_type.toLowerCase()})';
  return _description;
}
