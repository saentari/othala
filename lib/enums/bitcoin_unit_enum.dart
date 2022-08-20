enum BitcoinUnit {
  btc,
  sats,
  msats,
}

extension ParseToString on BitcoinUnit {
  String toShortString() {
    return toString().split('.').last;
  }
}
