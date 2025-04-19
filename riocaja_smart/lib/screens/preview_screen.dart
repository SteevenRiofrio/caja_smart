import 'package:flutter/material.dart';
import 'dart:io';
import 'package:riocaja_smart/services/ocr_service.dart';
import 'package:riocaja_smart/models/receipt.dart';

class PreviewScreen extends StatefulWidget {
  final String imagePath;

  PreviewScreen({required this.imagePath});

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  bool _isProcessing = true;
  String _extractedText = '';
  Receipt? _receipt;

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    try {
      setState(() => _isProcessing = true);
      
      // Usar el servicio OCR
      final ocrService = OcrService();
      
      // Extraer texto de la imagen
      final extractedText = await ocrService.extractText(widget.imagePath);
      
      // Analizar el texto para obtener datos estructurados
      final receiptData = await ocrService.analyzeReceipt(extractedText);
      
      // Extraer campos adicionales para crear el map de additionalFields
      Map<String, dynamic> additionalFields = {};
      receiptData.forEach((key, value) {
        if (!['type', 'transactionNumber', 'date', 'time', 'corresponsal', 'amount', 'fullText'].contains(key)) {
          additionalFields[key] = value;
        }
      });
      
      setState(() {
        _extractedText = extractedText;
        
        // Crear el objeto Receipt con los datos extraídos
        _receipt = Receipt(
          type: receiptData['type'] ?? 'Desconocido',
          transactionNumber: receiptData['transactionNumber'] ?? '',
          date: receiptData['date'] ?? '',
          time: receiptData['time'] ?? '',
          corresponsal: receiptData['corresponsal'] ?? '',
          amount: receiptData['amount'] ?? 0.0,
          additionalFields: additionalFields,
          fullText: extractedText,
        );
        
        _isProcessing = false;
      });
    } catch (e) {
      print('Error processing image: $e');
      setState(() {
        _isProcessing = false;
        _extractedText = 'Error al procesar la imagen: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Revisar Comprobante'),
      ),
      body: _isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Procesando imagen...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen capturada
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(widget.imagePath),
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // Datos extraídos
                  Text(
                    'Información Extraída',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildExtractionResult(),
                  
                  SizedBox(height: 24),
                  
                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Volver a Capturar'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Aquí se guardaría en la base de datos local
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Comprobante guardado exitosamente'),
                              ),
                            );
                            Navigator.of(context).pop();
                            Navigator.of(context).pop(); // Volver a la pantalla de inicio
                          },
                          child: Text('Guardar'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildExtractionResult() {
    if (_receipt == null) {
      return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(_extractedText),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Tipo', _receipt!.type),
            _buildInfoRow('Transacción', _receipt!.transactionNumber),
            _buildInfoRow('Fecha', _receipt!.date),
            _buildInfoRow('Hora', _receipt!.time),
            _buildInfoRow('Corresponsal', _receipt!.corresponsal),
            _buildInfoRow('Monto', '\$${_receipt!.amount.toStringAsFixed(2)}'),
            
            // Mostrar campos adicionales específicos del tipo
            if (_receipt!.additionalFields.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                'Información Adicional',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4),
              ..._receipt!.additionalFields.entries.map((entry) {
                return _buildInfoRow(
                  _formatFieldName(entry.key), 
                  entry.value.toString()
                );
              }).toList(),
            ],
            
            // Opción para ver texto completo
            SizedBox(height: 8),
            ExpansionTile(
              title: Text(
                'Ver texto completo',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
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
                  child: Text(_receipt!.fullText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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