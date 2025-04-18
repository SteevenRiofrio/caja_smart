import 'package:flutter/foundation.dart';
import 'package:riocaja_smart/models/receipt.dart';
import 'package:riocaja_smart/services/storage_service.dart';

class ReceiptsProvider with ChangeNotifier {
  List<Receipt> _receipts = [];
  bool _isLoading = false;
  final StorageService _storageService = StorageService();
  
  List<Receipt> get receipts => _receipts;
  bool get isLoading => _isLoading;
  
  // Cargar todos los comprobantes
  Future<void> loadReceipts() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _receipts = await _storageService.getAllReceipts();
    } catch (e) {
      print('Error loading receipts: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  // Añadir un nuevo comprobante
  Future<bool> addReceipt(Receipt receipt) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      bool success = await _storageService.saveReceipt(receipt);
      
      if (success) {
        _receipts.add(receipt);
      }
      
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error adding receipt: $e');
      return false;
    }
  }
  
  // Eliminar un comprobante
  Future<bool> deleteReceipt(String number) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      bool success = await _storageService.deleteReceipt(number);
      
      if (success) {
        _receipts.removeWhere((receipt) => receipt.number == number);
      }
      
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error deleting receipt: $e');
      return false;
    }
  }
  
  // Obtener comprobantes por fecha
  Future<List<Receipt>> getReceiptsByDate(DateTime date) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      List<Receipt> filteredReceipts = await _storageService.getReceiptsByDate(date);
      
      _isLoading = false;
      notifyListeners();
      return filteredReceipts;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error getting receipts by date: $e');
      return [];
    }
  }
  
  // Generar reporte de cierre
  Future<Map<String, dynamic>> generateClosingReport(DateTime date) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      List<Receipt> dateReceipts = await getReceiptsByDate(date);
      
      // Categorizar por tipo
      Map<String, double> summary = {};
      
      for (var receipt in dateReceipts) {
        if (summary.containsKey(receipt.type)) {
          summary[receipt.type] = summary[receipt.type]! + receipt.amount;
        } else {
          summary[receipt.type] = receipt.amount;
        }
      }
      
      // Calcular total
      double total = summary.values.fold(0, (sum, amount) => sum + amount);
      
      _isLoading = false;
      notifyListeners();
      
      return {
        'summary': summary,
        'total': total,
        'date': date,
        'count': dateReceipts.length,
      };
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error generating report: $e');
      return {};
    }
  }
}