import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stay_ease/widgets/app_drawer.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
      ),
      drawer: const AppDrawer(),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (ctx, i) => Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text('Transaksi #${i + 1}'),
            subtitle: Text(
              'Tanggal: ${DateFormat('dd/MM/yyyy').format(DateTime.now().subtract(Duration(days: i)))}',
            ),
            trailing: Text(
              formatCurrency.format(1500000.0 * (i + 1)),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
