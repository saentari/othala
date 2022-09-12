import 'package:bip39/bip39.dart';
import 'package:btc_address_validate/btc_address_validate.dart' as btc_address;
import 'package:dart_lnurl/dart_lnurl.dart';
import 'package:flutter/foundation.dart';

import '../enums/input_type.dart';

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
