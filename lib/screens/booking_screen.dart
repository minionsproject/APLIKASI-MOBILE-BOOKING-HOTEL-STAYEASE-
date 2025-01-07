import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stay_ease/models/hotel.dart';
import 'package:stay_ease/models/booking.dart';
import 'package:stay_ease/providers/auth_provider.dart';
import 'package:stay_ease/helpers/mongodb_helper.dart';
import 'package:stay_ease/main.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class BookingScreen extends StatefulWidget {
  final Hotel hotel;

  const BookingScreen({super.key, required this.hotel});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _guests = 1;
  String _selectedPaymentMethod = 'bank_transfer';
  String? _selectedPaymentProvider;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'bank_transfer',
      'name': 'Transfer Bank',
      'icon': Icons.account_balance,
      'banks': ['BCA', 'Mandiri', 'BNI', 'BRI']
    },
    {
      'id': 'e_wallet',
      'name': 'E-Wallet',
      'icon': Icons.account_balance_wallet,
      'providers': ['GoPay', 'OVO', 'DANA', 'ShopeePay']
    },
    {
      'id': 'credit_card',
      'name': 'Kartu Kredit',
      'icon': Icons.credit_card,
      'providers': ['Visa', 'Mastercard', 'American Express']
    },
    {
      'id': 'virtual_account',
      'name': 'Virtual Account',
      'icon': Icons.payment,
      'banks': ['BCA', 'Mandiri', 'BNI', 'BRI']
    },
  ];

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? DateTime.now() : (_checkIn ?? DateTime.now()),
      firstDate: isCheckIn ? DateTime.now() : (_checkIn ?? DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkIn = picked;
          if (_checkOut != null && _checkOut!.isBefore(_checkIn!)) {
            _checkOut = null;
          }
        } else {
          _checkOut = picked;
        }
      });
    }
  }

  double _calculateTotalPrice() {
    if (_checkIn == null || _checkOut == null) return 0;
    final nights = _checkOut!.difference(_checkIn!).inDays;
    return (widget.hotel.price * nights * _guests).toDouble();
  }

  Future<void> _processBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_checkIn == null || _checkOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon pilih tanggal check-in dan check-out'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.userId == null) {
        throw Exception('Silakan login terlebih dahulu');
      }

      final booking = Booking(
        id: mongo.ObjectId().toHexString(),
        userId: authProvider.userId!,
        hotelId: widget.hotel.id,
        hotelName: widget.hotel.name,
        hotelLocation: widget.hotel.location,
        checkInDate: _checkIn!,
        checkOutDate: _checkOut!,
        totalPrice: _calculateTotalPrice().toInt(),
        status: 'Menunggu Pembayaran',
        createdAt: DateTime.now(),
      );

      // Simpan ke database
      await MongoDBHelper().insertBooking(booking);

      // Tampilkan dialog konfirmasi
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Pemesanan Berhasil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID Pemesanan: ${booking.id.substring(0, 8)}'),
              const SizedBox(height: 8),
              Text(
                'Total: ${NumberFormat.currency(
                  locale: 'id',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                ).format(booking.totalPrice)}',
              ),
              const SizedBox(height: 16),
              const Text(
                'Silakan lakukan pembayaran sesuai metode yang dipilih.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                Navigator.pop(context); // Kembali ke halaman sebelumnya
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainScreen(initialIndex: 1),
                  ),
                );
              },
              child: const Text('Lihat Pesanan Saya'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildPaymentMethodSelector() {
    final selectedMethod = _paymentMethods.firstWhere(
      (method) => method['id'] == _selectedPaymentMethod,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(
          _paymentMethods.length,
          (index) => RadioListTile(
            title: Row(
              children: [
                Icon(_paymentMethods[index]['icon']),
                const SizedBox(width: 16),
                Text(_paymentMethods[index]['name']),
              ],
            ),
            value: _paymentMethods[index]['id'],
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value.toString();
                _selectedPaymentProvider = null;
              });
            },
          ),
        ),
        if (_selectedPaymentMethod == 'bank_transfer' ||
            _selectedPaymentMethod == 'virtual_account')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Pilih Bank',
              ),
              value: _selectedPaymentProvider,
              items: (selectedMethod['banks'] as List<String>)
                  .map((bank) => DropdownMenuItem(
                        value: bank,
                        child: Text(bank),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPaymentProvider = value;
                });
              },
              validator: (value) {
                if (value == null) return 'Pilih bank';
                return null;
              },
            ),
          ),
        if (_selectedPaymentMethod == 'e_wallet')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Pilih E-Wallet',
              ),
              value: _selectedPaymentProvider,
              items: (selectedMethod['providers'] as List<String>)
                  .map((provider) => DropdownMenuItem(
                        value: provider,
                        child: Text(provider),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPaymentProvider = value;
                });
              },
              validator: (value) {
                if (value == null) return 'Pilih e-wallet';
                return null;
              },
            ),
          ),
        if (_selectedPaymentMethod == 'credit_card')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Pilih Jenis Kartu',
              ),
              value: _selectedPaymentProvider,
              items: (selectedMethod['providers'] as List<String>)
                  .map((provider) => DropdownMenuItem(
                        value: provider,
                        child: Text(provider),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPaymentProvider = value;
                });
              },
              validator: (value) {
                if (value == null) return 'Pilih jenis kartu';
                return null;
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Hotel'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Hotel Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.hotel.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.hotel.location,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rp ${NumberFormat('#,###').format(widget.hotel.price)}/malam',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Booking Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Pemesanan',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    // Check-in Date
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Tanggal Check-in'),
                      subtitle: Text(
                        _checkIn == null
                            ? 'Pilih tanggal'
                            : DateFormat('dd MMM yyyy').format(_checkIn!),
                      ),
                      onTap: () => _selectDate(context, true),
                    ),
                    // Check-out Date
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Tanggal Check-out'),
                      subtitle: Text(
                        _checkOut == null
                            ? 'Pilih tanggal'
                            : DateFormat('dd MMM yyyy').format(_checkOut!),
                      ),
                      onTap: () => _selectDate(context, false),
                    ),
                    // Number of Guests
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Jumlah Tamu'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: _guests > 1
                                ? () => setState(() => _guests--)
                                : null,
                          ),
                          Text('$_guests'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _guests < 5
                                ? () => setState(() => _guests++)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Payment Method
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Metode Pembayaran',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildPaymentMethodSelector(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Total Price
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rp ${NumberFormat('#,###').format(_calculateTotalPrice())}',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Book Button
            ElevatedButton(
              onPressed: _isLoading ? null : _processBooking,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Pesan Sekarang',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
