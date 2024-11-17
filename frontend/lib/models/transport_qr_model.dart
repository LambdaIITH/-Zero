class TransactionQRModel {
  final String transactionId;
  final String paymentTime;
  final String travelDate;
  final String busTiming;

  TransactionQRModel({
    required this.transactionId,
    required this.paymentTime,
    required this.travelDate,
    required this.busTiming,
  });

  // Factory constructor to create a TransactionResponse from JSON
  factory TransactionQRModel.fromJson(Map<String, dynamic> json) {
    return TransactionQRModel(
      transactionId: json['transactionId'] as String,
      paymentTime: json['paymentTime'] as String,
      travelDate: json['travelDate'] as String,
      busTiming: json['busTiming'] as String,
    );
  }

  // Method to convert TransactionResponse to JSON (if needed for other purposes)
  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'paymentTime': paymentTime,
      'travelDate': travelDate,
      'busTiming': busTiming,
    };
  }

  TransactionQRModel parseTransaction(String input) {
    // Remove the curly braces and split by commas
    input = input.replaceAll(RegExp(r'[{}]'), '');
    List<String> parts = input.split(', ');

    // Initialize variables to store the parsed data
    String transactionId = '';
    String paymentTime = '';
    String travelDate = '';
    String busTiming = '';

    // Extract the key-value pairs
    for (String part in parts) {
      List<String> keyValue = part.split(': ');
      if (keyValue.length == 2) {
        String key = keyValue[0].trim();
        String value = keyValue[1].trim();

        switch (key) {
          case 'transactionId':
            transactionId = value;
            break;
          case 'paymentTime':
            paymentTime = value;
            break;
          case 'busTiming':
            busTiming = value;
            break;
          case 'travelDate':
            travelDate = value;
            break;
        }
      }
    }

    // Create and return the Transaction object
    return TransactionQRModel(
        transactionId: transactionId,
        paymentTime: paymentTime,
        busTiming: busTiming,
        travelDate: travelDate);
  }
}
