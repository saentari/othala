substractAddress(String source) {
  String address;

  // start with empty list
  List<AssetAddress> addresses = [];

  // If source is empty or null
  if (source.isEmpty) {
    throw ArgumentError('Input is empty');
  }

  // matches on spaces
  RegExp regExpSpaces = new RegExp(r' ');
  bool hasIllegalChars = regExpSpaces.hasMatch(source);
  if (hasIllegalChars) {
    throw ArgumentError('Illegal character');
  }

  // starts with chain prefix
  RegExp regExpPrefix = new RegExp(r':');
  bool hasPrefix = regExpPrefix.hasMatch(source);

  if (hasPrefix) {
    RegExp regex2 = RegExp(r'^(.+):(.+)');
    var matches2 = regex2.firstMatch(source);
    String prefix = matches2!.group(1)!.toLowerCase();
    if (prefix == 'bitcoin') {
      address = matches2.group(2)!;
      // identify chain and assets
      addresses = _identifyChain(address, prefix);
    } else {
      throw ArgumentError('Unsupported prefix');
    }
  } else {
    address = source;
    // identify chain and assets
    addresses = _identifyChain(address);
  }

  return addresses;
}

_identifyChain(String address, [String? prefix]) {
  List<AssetAddress> _addresses = [];

  if (prefix == 'bitcoin') {
    _addresses.add(AssetAddress(address, 'BTC.BTC', 'mainnet'));
  }
  // Bitcoin Legacy address starts with 1 and has 34 or less characters
  else if (address.startsWith(new RegExp(r'(^1[A-z,0-9]{33})'))) {
    _addresses.add(AssetAddress(address, 'BTC.BTC', 'mainnet'));
  }
  // Bitcoin & Litecoin Segwit address starts with 3 and has 34 characters
  else if (address.startsWith(new RegExp(r'(^3[A-z,0-9]{33})'))) {
    _addresses.add(AssetAddress(address, 'BTC.BTC', 'mainnet'));
  }
  // Bitcoin Native-Segwit address starts with bc1 and has 42 characters
  else if (address.startsWith(new RegExp(r'(^bc1[A-z,0-9]{39})'))) {
    _addresses.add(AssetAddress(address, 'BTC.BTC', 'mainnet'));
  }
  // Bitcoin Native-Segwit testnet address starts with tb1 and has 42 characters
  else if (address.startsWith(new RegExp(r'(^tb1[A-z,0-9]{39})'))) {
    _addresses.add(AssetAddress(address, 'BTC.tBTC', 'testnet'));
  } else {
    throw ArgumentError('Unsupported chain');
  }
  return _addresses;
}

class AssetAddress {
  String address;
  String asset;
  String networkType;

  AssetAddress(this.address, this.asset, this.networkType);
}
