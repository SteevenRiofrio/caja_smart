// lib/models/receipt.dart
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
      'nro_transaccion': nroTransaccion,  // Cambiado de 'nroTransaccion'
      'nro_control': nroControl,          // Cambiado de 'nroControl'
      'local': local,
      'fecha_alternativa': fechaAlternativa,  // Cambiado de 'fechaAlternativa'
      'corresponsal': corresponsal,
      'tipo_cuenta': tipoCuenta,          // Cambiado de 'tipoCuenta'
      'valor_total': valorTotal,          // Cambiado de 'valorTotal'
      'full_text': fullText,              // Cambiado de 'fullText'
    };
  }

  // Crear objeto desde Map
  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      banco: json['banco'] ?? 'Banco del Barrio | Banco Guayaquil',
      fecha: json['fecha'] ?? '',
      hora: json['hora'] ?? '',
      tipo: json['tipo'] ?? 'Pago de Servicio',
      nroTransaccion: json['nro_transaccion'] ?? '',  // Cambiado de 'nroTransaccion'
      nroControl: json['nro_control'] ?? '',          // Cambiado de 'nroControl'
      local: json['local'] ?? '',
      fechaAlternativa: json['fecha_alternativa'] ?? '', // Cambiado de 'fechaAlternativa'
      corresponsal: json['corresponsal'] ?? '',
      tipoCuenta: json['tipo_cuenta'] ?? '',          // Cambiado de 'tipoCuenta'
      valorTotal: json['valor_total'] ?? 0.0,         // Cambiado de 'valorTotal'
      fullText: json['full_text'] ?? '',              // Cambiado de 'fullText'
    );
  }
}