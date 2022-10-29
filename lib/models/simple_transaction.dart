import 'package:intl/intl.dart';

import 'transaction.dart';

class SimpleTransaction {
  String address;
  Transaction transaction;

  double amount = 0.0;
  String dateTime = '';
  String confirmations = '';

  SimpleTransaction(this.address, this.transaction) {
    dateTime =
        DateFormat('yyyy-MM-dd kk:mm').format(transaction.transactionBroadcast);

    List ioAmount = checkInputOutput(transaction, address);
    address = ioAmount.elementAt(0);
    amount = ioAmount.elementAt(1);

    int blockConf = transaction.confirmations;
    if (blockConf == 0) {
      confirmations = 'pending';
    } else if (blockConf < 6) {
      confirmations = '$blockConf conf.';
    }
  }

  List checkInputOutput(Transaction transaction, String address) {
    bool sender = false;
    bool receiver = false;
    double vinAmount = 0.0;
    double voutAmount = 0.0;
    String recipient = '';

    for (Map vin in transaction.from) {
      if (vin.values.elementAt(0).toString().toLowerCase() ==
          address.toLowerCase()) {
        sender = true;
        vinAmount = vinAmount + vin.values.elementAt(1);
      }
    }

    for (Map vout in transaction.to) {
      if (sender == false &&
          vout.values.elementAt(0).toString().toLowerCase() ==
              address.toLowerCase()) {
        recipient = vout.values.elementAt(0);
        voutAmount = vout.values.elementAt(1);
        break;
      }
      // Ignore empty OP_RETURN entries.
      if (vout.values.elementAt(0) != '' &&
          vout.values.elementAt(0).toString().toLowerCase() !=
              address.toLowerCase()) {
        recipient = vout.values.elementAt(0);
        voutAmount = voutAmount - vout.values.elementAt(1);
      } else {
        receiver = true;
      }
    }

    // Use tx outputs of sender instead of tx input of receiver
    if (sender == true && receiver == false) {
      voutAmount = 0 - vinAmount;
    }

    List ioAmount = [recipient, voutAmount];
    return ioAmount;
  }
}
