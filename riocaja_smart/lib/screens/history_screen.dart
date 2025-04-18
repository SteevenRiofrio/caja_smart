import 'package:flutter/material.dart';
import 'package:riocaja_smart/models/receipt.dart';

class HistoryScreen extends StatelessWidget {
  // Datos simulados para la demostración
  final List<Receipt> _receipts = [
    Receipt(
      type: 'Depósito',
      number: '12345',
      date: '15/04/2025',
      amount: 150.00,
      accountNumber: '20301254789',
      reference: 'PAG-8752',
    ),
    Receipt(
      type: 'Retiro',
      number: '67890',
      date: '15/04/2025',
      amount: 200.00,
      accountNumber: '20301254789',
      reference: 'RET-1234',
    ),
    Receipt(
      type: 'Pago Servicios',
      number: '54321',
      date: '14/04/2025',
      amount: 45.50,
      accountNumber: '20301254789',
      reference: 'SERV-9876',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Comprobantes'),
      ),
      body: _receipts.isEmpty
          ? Center(
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
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _receipts.length,
              itemBuilder: (context, index) {
                final receipt = _receipts[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      '${receipt.type} #${receipt.number}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text('Fecha: ${receipt.date}'),
                        Text('Monto: \$${receipt.amount.toStringAsFixed(2)}'),
                        Text('Referencia: ${receipt.reference}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.more_vert),
                      onPressed: () {
                        _showOptions(context, receipt);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showOptions(BuildContext context, Receipt receipt) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.visibility),
                title: Text('Ver detalles'),
                onTap: () {
                  Navigator.pop(context);
                  // Navegar a detalles
                },
              ),
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Editar información'),
                onTap: () {
                  Navigator.pop(context);
                  // Navegar a editar
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Eliminar', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  // Confirmar eliminación
                },
              ),
            ],
          ),
        );
      },
    );
  }
}