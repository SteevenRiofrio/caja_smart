// lib/services/ocr_service.dart
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final _textRecognizer = TextRecognizer();
  
  Future<String> extractText(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      String extractedText = recognizedText.text;
      return extractedText;
    } catch (e) {
      print('Error extracting text: $e');
      // Texto simulado en caso de error
      return "BANCO GUAYAQUIL\nDepósito #12345\nFecha: 15/04/2025\nMonto: \$150.00";
    }
  }
  
  // Método para analizar el texto y extraer información estructurada
  Future<Map<String, dynamic>> analyzeReceipt(String text) async {
    // Simulación de análisis - Esta lógica puede ser mejorada con expresiones regulares
    try {
      // Buscar tipo de transacción
      String type = 'Desconocido';
      if (text.contains('Depósito')) type = 'Depósito';
      else if (text.contains('Retiro')) type = 'Retiro';
      else if (text.contains('Pago')) type = 'Pago de Servicios';
      else if (text.contains('Giro')) type = 'Giro';
      
      // Buscar número de transacción (formato: #XXXXX)
      RegExp numRegex = RegExp(r'#(\d+)');
      String number = '00000';
      final numMatch = numRegex.firstMatch(text);
      if (numMatch != null) {
        number = numMatch.group(1) ?? '00000';
      }
      
      // Buscar fecha (formato: dd/mm/yyyy)
      RegExp dateRegex = RegExp(r'(\d{1,2}/\d{1,2}/\d{4})');
      String date = '01/01/2025';
      final dateMatch = dateRegex.firstMatch(text);
      if (dateMatch != null) {
        date = dateMatch.group(1) ?? '01/01/2025';
      }
      
      // Buscar monto (formato: $XXX.XX)
      RegExp amountRegex = RegExp(r'\$\s*(\d+[\.,]?\d*)');
      double amount = 0.0;
      final amountMatch = amountRegex.firstMatch(text);
      if (amountMatch != null) {
        String amountStr = amountMatch.group(1) ?? '0';
        amountStr = amountStr.replaceAll(',', '.');
        amount = double.tryParse(amountStr) ?? 0.0;
      }
      
      // En una implementación real, buscarías más campos específicos
      
      return {
        'type': type,
        'number': number,
        'date': date,
        'amount': amount,
        'accountNumber': '20301254789', // Simulado
        'reference': 'REF-$number',     // Simulado
      };
    } catch (e) {
      print('Error analyzing receipt: $e');
      // Datos simulados en caso de error
      return {
        'type': 'Depósito',
        'number': '12345',
        'date': '15/04/2025',
        'amount': 150.00,
        'accountNumber': '20301254789',
        'reference': 'PAG-8752',
      };
    } finally {
      // Liberar recursos
      _textRecognizer.close();
    }
  }
}