import 'package:flutter/material.dart';
import 'package:stay_ease/widgets/app_drawer.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bantuan'),
      ),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ExpansionTile(
            title: Text('Cara Melakukan Pemesanan'),
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '1. Pilih hotel yang diinginkan\n'
                  '2. Pilih tanggal check-in dan check-out\n'
                  '3. Pilih jumlah tamu\n'
                  '4. Pilih metode pembayaran\n'
                  '5. Konfirmasi pemesanan',
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('Cara Pembayaran'),
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '1. Transfer Bank\n'
                  '2. E-Wallet\n'
                  '3. Kartu Kredit\n'
                  '4. Virtual Account',
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('Kebijakan Pembatalan'),
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Pembatalan dapat dilakukan 24 jam sebelum check-in dengan pengembalian dana 100%.',
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('Hubungi Kami'),
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Email: support@stayease.com\n'
                  'Telepon: 021-1234567\n'
                  'WhatsApp: 0812-3456-7890',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
