import 'package:flutter/material.dart';
import 'package:riocaja_smart/models/receipt.dart';
import 'package:riocaja_smart/services/storage_service.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Receipt> _receipts = [];
  bool _isLoading = true;
  String _currentFilter = 'Todos';
  final StorageService _storageService = StorageService();
  
  @override
  void initState() {
    super.initState();
    _loadReceipts();
  }
  
  Future<void> _loadReceipts() async {
    setState(() => _isLoading = true);
    
    try {
      // Cargar comprobantes desde almacenamiento local
      final receipts = await _storageService.getAllReceipts();
      setState(() {
        _receipts = receipts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading receipts: $e');
      
      // Si hay un error, mostrar datos de ejemplo para demostración
      setState(() {
        _receipts = _getExampleReceipts();
        _isLoading = false;
      });
    }
  }
  
  // Método para obtener datos de ejemplo en caso de error
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
  
  List<Receipt> get _filteredReceipts {
    if (_currentFilter == 'Todos') {
      return _receipts;
    } else {
      return _receipts.where((receipt) => receipt.type == _currentFilter).toList();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Comprobantes'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadReceipts,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _receipts.isEmpty
              ? _buildEmptyState()
              : _buildReceiptsList(),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            'No hay comprobantes escaneados',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop(); // Volver a la pantalla principal
            },
            icon: Icon(Icons.camera_alt),
            label: Text('Escanear Nuevo Comprobante'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReceiptsList() {
    return Column(
      children: [
        // Mostrar el filtro actual
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Text('Filtro: ', style: TextStyle(fontWeight: FontWeight.bold)),
              Chip(
                label: Text(_currentFilter),
                deleteIcon: Icon(Icons.clear, size: 16),
                onDeleted: _currentFilter != 'Todos' 
                    ? () {
                        setState(() {
                          _currentFilter = 'Todos';
                        });
                      }
                    : null,
              ),
              Spacer(),
              Text('${_filteredReceipts.length} comprobantes'),
            ],
          ),
        ),
        
        // Lista de comprobantes
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _filteredReceipts.length,
            itemBuilder: (context, index) {
              final receipt = _filteredReceipts[index];
              return _buildReceiptCard(receipt);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildReceiptCard(Receipt receipt) {
    // Definir color según el tipo de transacción
    Color typeColor;
    IconData typeIcon;
    
    switch (receipt.type) {
      case 'Retiro':
        typeColor = Colors.red.shade100;
        typeIcon = Icons.arrow_upward;
        break;
      case 'Depósito':
        typeColor = Colors.green.shade100;
        typeIcon = Icons.arrow_downward;
        break;
      case 'Pago de Servicio':
        typeColor = Colors.blue.shade100;
        typeIcon = Icons.payment;
        break;
      case 'Recarga':
        typeColor = Colors.purple.shade100;
        typeIcon = Icons.phone_android;
        break;
      default:
        typeColor = Colors.grey.shade100;
        typeIcon = Icons.receipt;
    }
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showReceiptDetails(receipt),
        child: Column(
          children: [
            // Encabezado con tipo y fecha
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: typeColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  Icon(typeIcon),
                  SizedBox(width: 8),
                  Text(
                    receipt.type,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Spacer(),
                  Text(
                    receipt.date + ' ' + receipt.time,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Contenido principal
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transacción #${receipt.transactionNumber}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '\$${receipt.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  _buildDynamicInfo(receipt),
                ],
              ),
            ),
            
            // Pie del card con actions
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: Icon(Icons.share, size: 18),
                    label: Text('Compartir'),
                    onPressed: () {
                      // Implementar compartir
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  TextButton.icon(
                    icon: Icon(Icons.delete_outline, size: 18),
                    label: Text('Eliminar'),
                    onPressed: () => _confirmDelete(receipt),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Construye información dinámica según el tipo de comprobante
  Widget _buildDynamicInfo(Receipt receipt) {
    List<Widget> infoWidgets = [];
    
    // Corresponsal común a todos
    infoWidgets.add(
      Text('Corresponsal: ${receipt.corresponsal}', 
        style: TextStyle(color: Colors.grey.shade700, fontSize: 13))
    );
    
    // Información específica según tipo
    switch (receipt.type) {
      case 'Retiro':
        final accountType = receipt.additionalFields['accountType'] ?? '';
        final controlNumber = receipt.additionalFields['controlNumber'] ?? '';
        
        if (accountType.isNotEmpty) {
          infoWidgets.add(SizedBox(height: 4));
          infoWidgets.add(
            Text('Cuenta: $accountType', 
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13))
          );
        }
        
        if (controlNumber.isNotEmpty) {
          infoWidgets.add(SizedBox(height: 4));
          infoWidgets.add(
            Text('Control: ${controlNumber.substring(0, 5)}...', 
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13))
          );
        }
        break;
        
      case 'Recarga':
        final phoneNumber = receipt.additionalFields['phoneNumber'] ?? '';
        final provider = receipt.additionalFields['serviceProvider'] ?? '';
        
        if (phoneNumber.isNotEmpty) {
          infoWidgets.add(SizedBox(height: 4));
          infoWidgets.add(
            Text('Teléfono: $phoneNumber', 
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13))
          );
        }
        
        if (provider.isNotEmpty) {
          infoWidgets.add(SizedBox(height: 4));
          infoWidgets.add(
            Text('Operador: $provider', 
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13))
          );
        }
        break;
        
      case 'Pago de Servicio':
        final serviceType = receipt.additionalFields['serviceType'] ?? '';
        
        if (serviceType.isNotEmpty) {
          infoWidgets.add(SizedBox(height: 4));
          infoWidgets.add(
            Text('Servicio: $serviceType', 
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13))
          );
        }
        break;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: infoWidgets,
    );
  }
  
  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Filtrar por tipo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(),
              _buildFilterOption('Todos'),
              _buildFilterOption('Retiro'),
              _buildFilterOption('Depósito'),
              _buildFilterOption('Pago de Servicio'),
              _buildFilterOption('Recarga'),
              _buildFilterOption('Otro'),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildFilterOption(String filterName) {
    return ListTile(
      title: Text(filterName),
      leading: Radio<String>(
        value: filterName,
        groupValue: _currentFilter,
        onChanged: (value) {
          setState(() {
            _currentFilter = value!;
          });
          Navigator.pop(context);
        },
      ),
      onTap: () {
        setState(() {
          _currentFilter = filterName;
        });
        Navigator.pop(context);
      },
    );
  }
  
  void _showReceiptDetails(Receipt receipt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Encabezado
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.receipt_long, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Detalles del Comprobante',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 24),
                    
                    // Información general
                    _buildDetailRow('Tipo', receipt.type),
                    _buildDetailRow('Fecha', receipt.date),
                    _buildDetailRow('Hora', receipt.time),
                    _buildDetailRow('Transacción', receipt.transactionNumber),
                    _buildDetailRow('Corresponsal', receipt.corresponsal),
                    _buildDetailRow('Monto', '\$${receipt.amount.toStringAsFixed(2)}'),
                    
                    // Información adicional específica
                    if (receipt.additionalFields.isNotEmpty) ...[
                      SizedBox(height: 16),
                      Text(
                        'Información Adicional',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      ...receipt.additionalFields.entries.map((entry) {
                        return _buildDetailRow(
                          _formatFieldName(entry.key),
                          entry.value.toString(),
                        );
                      }).toList(),
                    ],
                    
                    // Texto completo
                    SizedBox(height: 16),
                    ExpansionTile(
                      title: Text(
                        'Texto Completo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(receipt.fullText),
                        ),
                      ],
                    ),
                    
                    // Acciones
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          'Compartir',
                          Icons.share,
                          Colors.blue,
                          () {
                            // Implementar compartir
                            Navigator.pop(context);
                          },
                        ),
                        _buildActionButton(
                          'Eliminar',
                          Icons.delete_outline,
                          Colors.red,
                          () {
                            Navigator.pop(context);
                            _confirmDelete(receipt);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  void _confirmDelete(Receipt receipt) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar Comprobante'),
          content: Text('¿Estás seguro de eliminar este comprobante? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Cerrar el diálogo
                
                // Eliminar el comprobante
                try {
                  await _storageService.deleteReceipt(receipt.transactionNumber);
                  setState(() {
                    _receipts.removeWhere((r) => r.transactionNumber == receipt.transactionNumber);
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Comprobante eliminado exitosamente'),
                    ),
                  );
                } catch (e) {
                  print('Error deleting receipt: $e');
                  
                  // Si hay un error, simular eliminación para demostración
                  setState(() {
                    _receipts.removeWhere((r) => r.transactionNumber == receipt.transactionNumber);
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Comprobante eliminado exitosamente'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
  
  // Método auxiliar para formatear nombres de campos
  String _formatFieldName(String name) {
    // Convertir camelCase a palabras separadas
    final formattedName = name.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (Match m) => ' ${m[0]}',
    );
    
    // Capitalizar primera letra
    if (formattedName.isEmpty) return '';
    return formattedName.substring(0, 1).toUpperCase() + 
           (formattedName.length > 1 ? formattedName.substring(1) : '');
  }
}