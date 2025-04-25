// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riocaja_smart/models/receipt.dart';

class ApiService {
  // URL base de la API - Ajustar según tu entorno
  //final String baseUrl = 'http://10.0.2.2:8000/api/v1'; // Para emulador Android
  // final String baseUrl = 'http://localhost:8000/api/v1'; // Para iOS
  // Si estás probando en un dispositivo físico, usa la IP de tu computadora
   final String baseUrl = 'http://192.168.100.216:8000/api/v1';
  
  // Obtener todos los comprobantes
  Future<List<Receipt>> getAllReceipts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/receipts/'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> receiptsJson = responseData['data'];
        
        return receiptsJson.map((json) => Receipt.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener comprobantes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getAllReceipts: $e');
      throw Exception('Error de conexión: $e');
    }
  }
  
  // Guardar un nuevo comprobante
  Future<bool> saveReceipt(Receipt receipt) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/receipts/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(receipt.toJson()),
      );
      
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Error al guardar comprobante: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en saveReceipt: $e');
      throw Exception('Error de conexión: $e');
    }
  }
  
  // Eliminar un comprobante
  Future<bool> deleteReceipt(String transactionNumber) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/receipts/$transactionNumber'),
      );
      
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Error al eliminar comprobante: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en deleteReceipt: $e');
      throw Exception('Error de conexión: $e');
    }
  }
  
  // Obtener reporte de cierre
  Future<Map<String, dynamic>> getClosingReport(DateTime date) async {
    // Formato de fecha esperado: dd/MM/yyyy
    String dateStr = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/receipts/report/$dateStr'),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener reporte: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getClosingReport: $e');
      throw Exception('Error de conexión: $e');
    }
  }
}