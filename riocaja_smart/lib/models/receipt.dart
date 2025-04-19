class Receipt {
  final String type;
  final String transactionNumber;
  final String date;
  final String time;
  final String corresponsal;
  final double amount;
  final Map<String, dynamic> additionalFields;
  final String fullText;

  Receipt({
    required this.type,
    required this.transactionNumber,
    required this.date,
    required this.time,
    required this.corresponsal,
    required this.amount,
    required this.additionalFields,
    required this.fullText,
  });

  // Convertir a Map para almacenamiento local o envío al backend
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'transactionNumber': transactionNumber,
      'date': date,
      'time': time,
      'corresponsal': corresponsal,
      'amount': amount,
      'additionalFields': additionalFields,
      'fullText': fullText,
    };
  }

  // Crear objeto desde Map
  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      type: json['type'] ?? 'Desconocido',
      transactionNumber: json['transactionNumber'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      corresponsal: json['corresponsal'] ?? '',
      amount: json['amount'] ?? 0.0,
      additionalFields: json['additionalFields'] ?? {},
      fullText: json['fullText'] ?? '',
    );
  }
}