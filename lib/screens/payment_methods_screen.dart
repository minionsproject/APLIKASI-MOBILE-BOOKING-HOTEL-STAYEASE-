import 'package:flutter/material.dart';
import 'package:stay_ease/widgets/app_drawer.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metode Pembayaran'),
      ),
      drawer: const AppDrawer(),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.account_balance),
            title: Text('Transfer Bank'),
            subtitle: Text('BCA, Mandiri, BNI, BRI'),
          ),
          ListTile(
            leading: Icon(Icons.account_balance_wallet),
            title: Text('E-Wallet'),
            subtitle: Text('GoPay, OVO, DANA, ShopeePay'),
          ),
          ListTile(
            leading: Icon(Icons.credit_card),
            title: Text('Kartu Kredit'),
            subtitle: Text('Visa, Mastercard, American Express'),
          ),
        ],
      ),
    );
  }
}
