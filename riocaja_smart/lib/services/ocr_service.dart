import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final _textRecognizer = TextRecognizer();
  
  // Extrae todo el texto de la imagen
  Future<String> extractText(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      // Devuelve el texto completo sin filtrar
      return recognizedText.text;
    } catch (e) {
      print('Error extracting text: $e');
      return "Error al extraer texto: $e";
    }
  }
  
  // Analiza el texto para identificar el tipo de comprobante y extraer datos clave
  Future<Map<String, dynamic>> analyzeReceipt(String text) async {
    try {
      // Determinar tipo de transacción
      String type = _identifyTransactionType(text);
      
      // Extraer campos comunes
      String transactionNumber = _extractTransactionNumber(text);
      String date = _extractDate(text);
      String time = _extractTime(text);
      String corresponsal = _extractCorresponsal(text);
      double amount = _extractAmount(text);
      
      // Extraer campos específicos según el tipo
      Map<String, dynamic> specificFields = _extractSpecificFields(text, type);
      
      // Consolidar todos los datos
      Map<String, dynamic> result = {
        'type': type,
        'transactionNumber': transactionNumber,
        'date': date,
        'time': time,
        'corresponsal': corresponsal,
        'amount': amount,
        'fullText': text,
      };
      
      // Añadir campos específicos
      result.addAll(specificFields);
      
      return result;
    } catch (e) {
      print('Error analyzing receipt: $e');
      // En caso de error, devolvemos el texto completo de todas formas
      return {
        'type': 'Desconocido',
        'transactionNumber': '',
        'date': '',
        'time': '',
        'corresponsal': '',
        'amount': 0.0,
        'fullText': text,
      };
    }
  }
  
  // Identifica el tipo de transacción basado en el texto
  String _identifyTransactionType(String text) {
    final lowerText = text.toLowerCase();
    
    if (text.contains('RETIRO')) return 'Retiro';
    if (text.contains('DEPOSITO') || text.contains('DEPÓSITO')) return 'Depósito';
    if (text.contains('PAGO DE SERVICIO')) return 'Pago de Servicio';
    if (lowerText.contains('recarga') || lowerText.contains('claro') || lowerText.contains('movistar')) return 'Recarga';
    if (lowerText.contains('transferencia')) return 'Transferencia';
    if (lowerText.contains('giro')) return 'Giro';
    
    return 'Otro';
  }
  
  // Extrae el número de transacción
  String _extractTransactionNumber(String text) {
    final RegExp regex = RegExp(r'NRO\.?\s*TRANSACCI[OÓ]N\s*:?\s*(\d+)', caseSensitive: false);
    final match = regex.firstMatch(text);
    return match?.group(1)?.trim() ?? '';
  }
  
  // Extrae la fecha
  String _extractDate(String text) {
    // Buscar formato "FECHA: dd/mm/yyyy" 
    final RegExp regexFecha = RegExp(r'FECHA\s*:?\s*(\d{1,2}/\d{1,2}/\d{4})', caseSensitive: false);
    final matchFecha = regexFecha.firstMatch(text);
    if (matchFecha != null) {
      return matchFecha.group(1)?.trim() ?? '';
    }
    
    // Buscar formato alternativo "dd-mm-yyyy"
    final RegExp regexAlternativa = RegExp(r'(\d{1,2}-\d{1,2}-\d{4})', caseSensitive: false);
    final matchAlternativa = regexAlternativa.firstMatch(text);
    return matchAlternativa?.group(1)?.trim() ?? '';
  }
  
  // Extrae la hora
  String _extractTime(String text) {
    final RegExp regex = RegExp(r'HORA\s*:?\s*(\d{1,2}:\d{1,2}:\d{1,2})', caseSensitive: false);
    final match = regex.firstMatch(text);
    return match?.group(1)?.trim() ?? '';
  }
  
  // Extrae el corresponsal
  String _extractCorresponsal(String text) {
    final RegExp regex = RegExp(r'CORRESPONSAL\s*:?\s*(\d+)', caseSensitive: false);
    final match = regex.firstMatch(text);
    return match?.group(1)?.trim() ?? '';
  }
  
  // Extrae el monto
  double _extractAmount(String text) {
    // Buscar "VALOR" o "TOTAL" seguido por un valor monetario
    List<RegExp> regexes = [
      RegExp(r'VALOR\s*:?\s*\$?\s*(\d+[\.,]?\d*)', caseSensitive: false),
      RegExp(r'VALOR TOTAL\s*:?\s*\$?\s*(\d+[\.,]?\d*)', caseSensitive: false),
      RegExp(r'TOTAL\s*:?\s*\$?\s*(\d+[\.,]?\d*)', caseSensitive: false),
      // Para casos donde solo hay un valor monetario sin etiqueta clara
      RegExp(r'\$\s*(\d+[\.,]?\d*)', caseSensitive: false),
    ];
    
    for (var regex in regexes) {
      final match = regex.firstMatch(text);
      if (match != null) {
        String amountStr = match.group(1) ?? '0';
        amountStr = amountStr.replaceAll(',', '.');
        return double.tryParse(amountStr) ?? 0.0;
      }
    }
    
    return 0.0;
  }
  
  // Extrae campos específicos según el tipo de transacción
  Map<String, dynamic> _extractSpecificFields(String text, String type) {
    Map<String, dynamic> fields = {};
    
    switch (type) {
      case 'Retiro':
        fields['accountType'] = _extractAccountType(text);
        fields['controlNumber'] = _extractControlNumber(text);
        break;
        
      case 'Pago de Servicio':
        fields['controlNumber'] = _extractControlNumber(text);
        fields['serviceType'] = _extractServiceType(text);
        break;
        
      case 'Recarga':
        fields['phoneNumber'] = _extractPhoneNumber(text);
        fields['serviceProvider'] = _extractServiceProvider(text);
        break;
        
      default:
        // Campos adicionales generales que podrían estar en cualquier tipo
        final locationType = _extractLocationType(text);
        if (locationType.isNotEmpty) {
          fields['locationType'] = locationType;
        }
        
        final direction = _extractDirection(text);
        if (direction.isNotEmpty) {
          fields['direction'] = direction;
        }
        break;
    }
    
    return fields;
  }
  
  // Métodos auxiliares para extraer campos específicos
  
  String _extractAccountType(String text) {
    final RegExp regex = RegExp(r'TIPO DE CUENTA\s*:?\s*([A-Za-z]+)', caseSensitive: false);
    final match = regex.firstMatch(text);
    return match?.group(1)?.trim() ?? '';
  }
  
  String _extractControlNumber(String text) {
    final RegExp regex = RegExp(r'NRO\.\s*DE CONTROL\s*:?\s*(\d+)', caseSensitive: false);
    final match = regex.firstMatch(text);
    return match?.group(1)?.trim() ?? '';
  }
  
  String _extractServiceType(String text) {
    if (text.contains('ILIM. CLARO')) return 'Recarga Claro';
    if (text.contains('PAGO DE SERVICIO')) {
      // Intentar encontrar palabras clave después de "PAGO DE SERVICIO"
      final lines = text.split('\n');
      int servicioIndex = -1;
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].contains('PAGO DE SERVICIO')) {
          servicioIndex = i;
          break;
        }
      }
      
      if (servicioIndex >= 0 && servicioIndex + 1 < lines.length) {
        return lines[servicioIndex + 1].trim();
      }
    }
    return '';
  }
  
  String _extractPhoneNumber(String text) {
    final RegExp regex = RegExp(r'NUM\.\s*TELEFONO\s*:?\s*(\d+)', caseSensitive: false);
    final match = regex.firstMatch(text);
    return match?.group(1)?.trim() ?? '';
  }
  
  String _extractServiceProvider(String text) {
    if (text.contains('CLARO')) return 'CLARO';
    if (text.contains('MOVISTAR')) return 'MOVISTAR';
    if (text.contains('CNT')) return 'CNT';
    return '';
  }
  
  String _extractLocationType(String text) {
    final RegExp regex = RegExp(r'LOCALIDAD\s*:?\s*([A-Za-z\s]+)', caseSensitive: false);
    final match = regex.firstMatch(text);
    return match?.group(1)?.trim() ?? '';
  }
  
  String _extractDirection(String text) {
    final RegExp regex = RegExp(r'DIRECCION\s*:?\s*([A-Za-z0-9\s]+)', caseSensitive: false);
    final match = regex.firstMatch(text);
    return match?.group(1)?.trim() ?? '';
  }
  
  // Cierra el recognizer cuando ya no se necesite
  void dispose() {
    _textRecognizer.close();
  }
}