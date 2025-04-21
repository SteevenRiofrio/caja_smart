class Receipt {
  final String banco;
  final String fecha;
  final String hora;
  final String tipo;
  final String nroTransaccion;
  final String nroControl;
  final String local;
  final String fechaAlternativa;
  final String corresponsal;
  final String tipoCuenta;
  final double valorTotal;
  final String fullText;

  Receipt({
    required this.banco,
    required this.fecha,
    required this.hora,
    required this.tipo,
    required this.nroTransaccion,
    required this.nroControl,
    required this.local,
    required this.fechaAlternativa,
    required this.corresponsal,
    required this.tipoCuenta,
    required this.valorTotal,
    required this.fullText,
  });

  // Convertir a Map para almacenamiento local o envío al backend
  Map<String, dynamic> toJson() {
    return {
      'banco': banco,
      'fecha': fecha,
      'hora': hora,
      'tipo': tipo,
      'nroTransaccion': nroTransaccion,
      'nroControl': nroControl,
      'local': local,
      'fechaAlternativa': fechaAlternativa,
      'corresponsal': corresponsal,
      'tipoCuenta': tipoCuenta,
      'valorTotal': valorTotal,
      'fullText': fullText,
    };
  }

  // Crear objeto desde Map
  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      banco: json['banco'] ?? 'Banco del Barrio | Banco Guayaquil',
      fecha: json['fecha'] ?? '',
      hora: json['hora'] ?? '',
      tipo: json['tipo'] ?? 'Pago de Servicio',
      nroTransaccion: json['nroTransaccion'] ?? '',
      nroControl: json['nroControl'] ?? '',
      local: json['local'] ?? '',
      fechaAlternativa: json['fechaAlternativa'] ?? '',
      corresponsal: json['corresponsal'] ?? '',
      tipoCuenta: json['tipoCuenta'] ?? '',
      valorTotal: json['valorTotal'] ?? 0.0,
      fullText: json['fullText'] ?? '',
    );
  }
}