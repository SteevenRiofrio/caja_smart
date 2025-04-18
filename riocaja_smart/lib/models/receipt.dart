class Receipt {
  final String type;
  final String number;
  final String date;
  final double amount;
  final String accountNumber;
  final String reference;

  Receipt({
    required this.type,
    required this.number,
    required this.date,
    required this.amount,
    required this.accountNumber,
    required this.reference,
  });

  // Convertir a Map para almacenamiento local o envío al backend
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'number': number,
      'date': date,
      'amount': amount,
      'accountNumber': accountNumber,
      'reference': reference,
    };
  }

  // Crear objeto desde Map (para recuperación de datos)
  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      type: json['type'],
      number: json['number'],
      date: json['date'],
      amount: json['amount'],
      accountNumber: json['accountNumber'],
      reference: json['reference'],
    );
  }
}