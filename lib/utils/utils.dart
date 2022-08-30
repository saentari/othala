substractAddress(String source) {
  String address;

  // Start with empty list
  List<AssetAddress> addresses = [];

  // If source is empty or null
  if (source.isEmpty) {
    throw ArgumentError('Input is empty');
  }

  // Matches on spaces
  RegExp regExpSpaces = new RegExp(r' ');
  bool hasIllegalChars = regExpSpaces.hasMatch(source);
  if (hasIllegalChars) {
    throw ArgumentError('Illegal character');
  }

  // Starts with chain prefix
  RegExp regExpPrefix = new RegExp(r':');
  bool hasPrefix = regExpPrefix.hasMatch(source);

  if (hasPrefix) {
    RegExp regex2 = RegExp(r'^(.+):(.+)');
    var matches2 = regex2.firstMatch(source);
    String prefix = matches2!.group(1)!.toLowerCase();
    if (prefix == 'bitcoin') {
      // Strip prefix
      address = matches2.group(2)!;
      addresses = _identifyChain(address, prefix);
    } else {
      throw ArgumentError('Unsupported prefix');
    }
  } else {
    address = source;
    // Identify chain and assets
    addresses = _identifyChain(address);
  }

  return addresses;
}

_identifyChain(String address, [String? prefix]) {
  List<AssetAddress> _addresses = [];

  // Bitcoin Legacy address starts with 1 and has 34 or less characters
  if (address.startsWith(RegExp(r'(^1[A-z,0-9]{33})', caseSensitive: false))) {
    _addresses.add(AssetAddress(address, 32, 'mainnet'));
  }
  // Bitcoin & Litecoin Segwit address starts with 3 and has 34 characters
  else if (address
      .startsWith(RegExp(r'(^3[A-z,0-9]{33})', caseSensitive: false))) {
    _addresses.add(AssetAddress(address, 49, 'mainnet'));
  }
  // Bitcoin Native-Segwit address starts with bc1 and has 42 characters
  else if (address
      .startsWith(RegExp(r'(^bc1[A-z,0-9]{39})', caseSensitive: false))) {
    _addresses.add(AssetAddress(address, 84, 'mainnet'));
  }
  // Bitcoin Native-Segwit testnet address starts with tb1 and has 42 characters
  else if (address
      .startsWith(RegExp(r'(^tb1[A-z,0-9]{39})', caseSensitive: false))) {
    _addresses.add(AssetAddress(address, 84, 'testnet'));
  } else {
    throw ArgumentError('Unsupported chain');
  }
  return _addresses;
}

class AssetAddress {
  String address;
  int bip;
  String networkType;

  AssetAddress(this.address, this.bip, this.networkType);
}
