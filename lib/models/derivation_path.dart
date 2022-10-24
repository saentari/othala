class DerivationPath {
  String derivationPath = "m/0'/0'/0'/0/0";
  int purpose = 0;
  int coinType = 0;
  int account = 0;
  int change = 0;
  int addressIndex = 0;

  DerivationPath(String dp) {
    // Splits the [String] input into smaller elements.
    dp = dp.replaceAll('m/', '');
    dp = dp.replaceAll('\'', '');
    List elements = dp.split('/');

    // Parses each element or assigns a `0` when not specified.
    purpose = elements.isNotEmpty ? int.parse(elements[0]) : 0;
    coinType = elements.length > 1 ? int.parse(elements[1]) : 0;
    account = elements.length > 2 ? int.parse(elements[2]) : 0;
    change = elements.length > 3 ? int.parse(elements[3]) : 0;
    addressIndex = elements.length > 4 ? int.parse(elements[4]) : 0;
    derivationPath = "m/$purpose'/$coinType'/$account'/$change/$addressIndex";
  }

  // Sets the derivation path.
  setDerivationPath(int prp, int cnt, int acc, int chng, int addr) {
    derivationPath = "m/$prp'/$cnt'/$acc'/$chng/$addr";
  }

  // Assigns the purpose (e.g. `84` for native SegWit).
  setPurpose(int value) {
    addressIndex = value;
    setDerivationPath(purpose, coinType, account, change, addressIndex);
  }

  // Assigns the cointype (e.g. `1` for testnet).
  setCoinType(int value) {
    addressIndex = value;
    setDerivationPath(purpose, coinType, account, change, addressIndex);
  }

  // Assigns the account value.
  setAccount(int value) {
    addressIndex = value;
    setDerivationPath(purpose, coinType, account, change, addressIndex);
  }

  // Assigns the change value.
  setChange(int value) {
    addressIndex = value;
    setDerivationPath(purpose, coinType, account, change, addressIndex);
  }

  // Assigns the address index value (e.g. `1` for the second address).
  setAddressIndex(int value) {
    addressIndex = value;
    setDerivationPath(purpose, coinType, account, change, addressIndex);
  }
}
