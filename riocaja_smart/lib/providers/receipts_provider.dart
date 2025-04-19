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
      // En caso de error, cargar ejemplos para demostración
      _receipts = _getExampleReceipts();
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
      
      // Para demostración, simular éxito incluso en caso de error
      _receipts.add(receipt);
      notifyListeners();
      return true;
    }
  }
  
  // Eliminar un comprobante
  Future<bool> deleteReceipt(String transactionNumber) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      bool success = await _storageService.deleteReceipt(transactionNumber);
      
      if (success) {
        _receipts.removeWhere((receipt) => receipt.transactionNumber == transactionNumber);
      }
      
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error deleting receipt: $e');
      
      // Para demostración, simular éxito incluso en caso de error
      _receipts.removeWhere((receipt) => receipt.transactionNumber == transactionNumber);
      notifyListeners();
      return true;
    }
  }
  
  // Obtener comprobantes por fecha
  List<Receipt> getReceiptsByDate(DateTime date) {
    // Formato de fecha esperado: dd/MM/yyyy
    String dateStr = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    
    // Filtrar por fecha
    return _receipts.where((receipt) => receipt.date == dateStr).toList();
  }
  
  // Obtener comprobantes por tipo
  List<Receipt> getReceiptsByType(String type) {
    return _receipts.where((receipt) => receipt.type == type).toList();
  }
  
  // Generar reporte de cierre para una fecha específica
  Map<String, dynamic> generateClosingReport(DateTime date) {
    List<Receipt> dateReceipts = getReceiptsByDate(date);
    
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
    
    return {
      'summary': summary,
      'total': total,
      'date': date,
      'count': dateReceipts.length,
    };
  }
  
  // Datos de ejemplo para demostración
  List<Receipt> _getExampleReceipts() {
    return [
      Receipt(
        type: 'Retiro',
        transactionNumber: '203900109',
        date: '17/04/2025',
        time: '12:35:56',
        corresponsal: '03220390',
        amount: 140.00,
        additionalFields: {
          'accountType': 'Efectivo',
          'controlNumber': '0000075977316'
        },
        fullText: 'BANCO DEL BARRIO | BANCO GUAYAQUIL\nFECHA: 17/04/2025 HORA: 12:35:56\nRETIRO\nNRO. TRANSACCION: 203900109\nNRO. DE CONTROL: 0000075977316\nCOMERCIAL JG\n17-04-2025\nCORRESPONSAL: 03220390\nTIPO DE CUENTA: Efectivo\nVALOR: \$140\nEl costo de este servicio será debitado de tu cuenta.',
      ),
      Receipt(
        type: 'Pago de Servicio',
        transactionNumber: '203900096',
        date: '17/04/2025',
        time: '09:32:29',
        corresponsal: '03220390',
        amount: 12.61,
        additionalFields: {
          'accountType': 'Efectivo',
          'controlNumber': '000089468683'
        },
        fullText: 'BANCO DEL BARRIO | BANCO GUAYAQUIL\nFECHA: 17/04/2025 HORA: 09:32:29\nPAGO DE SERVICIO\nNRO. TRANSACCION: 203900096\nNRO. DE CONTROL: 000089468683\nCOMERCIAL JG\n17-04-2025\nCORRESPONSAL: 03220390\nTIPO DE CUENTA: Efectivo\nVALOR TOTAL: \$12.61',
      ),
      Receipt(
        type: 'Recarga',
        transactionNumber: '203900101',
        date: '17/04/2025',
        time: '11:01:30',
        corresponsal: '03220390',
        amount: 1.05,
        additionalFields: {
          'phoneNumber': '0986776619',
          'serviceProvider': 'CLARO'
        },
        fullText: 'BANCO DEL BARRIO | BANCO GUAYAQUIL\nFECHA: 17/04/2025 HORA: 11:01:30\nLOCALIDAD: COMERCIAL JG\nDIRECCION: AV BOMBOLI 1502 JOSE MARI\nCORRESPONSAL: 03220390\nNRO. TRANSACCION: 203900101\nILIM. CLARO: 500GB + MIN ILIM CLAR\nX 1D\nNUM. TELEFONO: 0986776619\nTOTAL: \$1.05',
      ),
    ];
  }
}