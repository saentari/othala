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

  // Strip any bitcoin prefix.
  input = input.replaceFirst(RegExp(r'bitcoin:', caseSensitive: false), '');

  // Check if valid mnemonic.
  if (validateMnemonic(input, language: defaultLanguage)) {
    return InputType.mnemonic;
  }
  // Check if valid address.
  else if (isValidAddress(input)) {
    return InputType.address;
  }
  // Check if valid lnurl.
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

// Returns a generated wallet name.
String getAddressName(String address) {
  String description;

  btc_address.Address addressData = btc_address.validate(address);
  if (addressData.segwit) {
    description = 'Native Segwit';
  } else {
    description = 'Legacy';
  }

  if (addressData.network == btc_address.Network.testnet) {
    description = 'Testnet';
  }

  String type = describeEnum(addressData.type as Enum);
  return '$description (${type.toLowerCase()})';
}
