class DerivationPath {
  String derivationPath = "m/0'/0'/0'/0/0";
  int purpose = 0;
  int coinType = 0;
  int account = 0;
  int change = 0;
  int addressIndex = 0;

  DerivationPath(String dp) {
    dp = dp.replaceAll('m/', '');
    dp = dp.replaceAll('\'', '');
    List elements = dp.split('/');

    purpose = elements.isNotEmpty ? int.parse(elements[0]) : 0;
    coinType = elements.length > 1 ? int.parse(elements[1]) : 0;
    account = elements.length > 2 ? int.parse(elements[2]) : 0;
    change = elements.length > 3 ? int.parse(elements[3]) : 0;
    addressIndex = elements.length > 4 ? int.parse(elements[4]) : 0;
    derivationPath = "m/$purpose'/$coinType'/$account'/$change/$addressIndex";
  }

  setDerivationPath(int prp, int cnt, int acc, int chng, int addr) {
    derivationPath = "m/$prp'/$cnt'/$acc'/$chng/$addr";
  }

  setPurpose(int value) {
    addressIndex = value;
    setDerivationPath(purpose, coinType, account, change, addressIndex);
  }

  setCoinType(int value) {
    addressIndex = value;
    setDerivationPath(purpose, coinType, account, change, addressIndex);
  }

  setAccount(int value) {
    addressIndex = value;
    setDerivationPath(purpose, coinType, account, change, addressIndex);
  }

  setChange(int value) {
    addressIndex = value;
    setDerivationPath(purpose, coinType, account, change, addressIndex);
  }

  setAddressIndex(int value) {
    addressIndex = value;
    setDerivationPath(purpose, coinType, account, change, addressIndex);
  }
}
