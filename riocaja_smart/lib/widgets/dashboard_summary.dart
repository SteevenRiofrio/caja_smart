import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:riocaja_smart/providers/receipts_provider.dart';

class DashboardSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final receiptsProvider = Provider.of<ReceiptsProvider>(context);
    
    // Verificar si está cargando
    if (receiptsProvider.isLoading) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    
    // Generar el reporte para la fecha actual
    final reportData = receiptsProvider.generateClosingReport(DateTime.now());
    
    // Si no hay datos
    if (reportData.isEmpty || (reportData['count'] as int) == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                Icons.insert_chart,
                size: 48,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 8),
              Text(
                'No hay datos para mostrar hoy',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // Mostrar el resumen
    final summary = reportData['summary'] as Map<String, double>;
    final total = reportData['total'] as double;
    final count = reportData['count'] as int;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen del día',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                  'Transacciones',
                  count.toString(),
                  Icons.receipt,
                  Colors.blue.shade100,
                ),
                _buildSummaryItem(
                  'Total',
                  '\$${total.toStringAsFixed(2)}',
                  Icons.account_balance_wallet,
                  Colors.green.shade100,
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Distribución',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            ...summary.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key),
                    Text('\$${entry.value.toStringAsFixed(2)}'),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Container(
      width: 140,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}