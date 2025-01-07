import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stay_ease/providers/auth_provider.dart';
import 'package:stay_ease/main.dart';
import 'package:stay_ease/widgets/copyright.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(
                    authProvider.username ?? 'Guest',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  accountEmail: const Text(''),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      (authProvider.username?[0] ?? 'G').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home, size: 28),
                  title: const Text('Beranda'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.book, size: 28),
                  title: const Text('Pesanan Saya'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainScreen(initialIndex: 1),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.favorite, size: 28),
                  title: const Text('Favorit'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainScreen(initialIndex: 2),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.payment, size: 28),
                  title: const Text('Metode Pembayaran'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/payment-methods');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history, size: 28),
                  title: const Text('Riwayat Transaksi'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/transactions');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings, size: 28),
                  title: const Text('Pengaturan'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help, size: 28),
                  title: const Text('Bantuan'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/help');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.exit_to_app,
                      size: 28, color: Colors.red),
                  title:
                      const Text('Keluar', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/');
                    }
                  },
                ),
              ],
            ),
          ),
          const Copyright(),
        ],
      ),
    );
  }
}
