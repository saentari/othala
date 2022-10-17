class DerivationPath {
  DerivationPath(
      {this.purpose = 0,
      this.coinType = 0,
      this.account = 0,
      this.change = 0,
      this.addressIndex = 0});

  int purpose;
  int coinType;
  int account;
  int change;
  int addressIndex;

  String getDerivationPath() {
    return "m/$purpose'/$coinType'/$account'/$change/$addressIndex";
  }

  int getPurpose(String derivationPath) {
    derivationPath = derivationPath.replaceAll('m/', '');
    derivationPath = derivationPath.replaceAll('\'', '');
    List elements = derivationPath.split('/');
    return elements.isNotEmpty ? int.parse(elements[0]) : 0;
  }

  int getCoinType(String derivationPath) {
    derivationPath = derivationPath.replaceAll('m/', '');
    derivationPath = derivationPath.replaceAll('\'', '');
    List elements = derivationPath.split('/');
    return elements.length > 1 ? int.parse(elements[1]) : 0;
  }

  int getAccount(String derivationPath) {
    derivationPath = derivationPath.replaceAll('m/', '');
    derivationPath = derivationPath.replaceAll('\'', '');
    List elements = derivationPath.split('/');
    return elements.length > 2 ? int.parse(elements[2]) : 0;
  }

  int getChange(String derivationPath) {
    derivationPath = derivationPath.replaceAll('m/', '');
    derivationPath = derivationPath.replaceAll('\'', '');
    List elements = derivationPath.split('/');
    return elements.length > 3 ? int.parse(elements[3]) : 0;
  }

  int getAddressIndex(String derivationPath) {
    derivationPath = derivationPath.replaceAll('m/', '');
    derivationPath = derivationPath.replaceAll('\'', '');
    List elements = derivationPath.split('/');
    return elements.length > 4 ? int.parse(elements[4]) : 0;
  }
}
