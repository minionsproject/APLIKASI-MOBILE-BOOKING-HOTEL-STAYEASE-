import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stay_ease/providers/auth_provider.dart';
import 'package:stay_ease/providers/hotel_provider.dart';
import 'package:stay_ease/screens/login_screen.dart';
import 'package:stay_ease/screens/home_screen.dart';
import 'package:stay_ease/screens/register_screen.dart';
import 'package:stay_ease/screens/orders_screen.dart';
import 'package:stay_ease/screens/favorites_screen.dart';
import 'package:stay_ease/screens/profile_screen.dart';
import 'package:stay_ease/screens/payment_methods_screen.dart';
import 'package:stay_ease/screens/transactions_screen.dart';
import 'package:stay_ease/screens/settings_screen.dart';
import 'package:stay_ease/screens/help_screen.dart';
import 'package:stay_ease/helpers/storage_helper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stay_ease/helpers/mongodb_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print('Loading environment variables...');
    await dotenv.load(fileName: ".env");
    print('Environment variables loaded successfully');

    print('Initializing app...');

    // Inisialisasi storage
    final storage = StorageHelper();
    await storage.init();
    print('Storage initialized successfully');

    // Inisialisasi MongoDB dan test koneksi
    final mongoHelper = MongoDBHelper();
    await mongoHelper.database; // Test koneksi
    print('MongoDB connection tested successfully');

    // Inisialisasi providers
    final authProvider = AuthProvider();
    final hotelProvider = HotelProvider();

    // Coba auto login
    await authProvider.tryAutoLogin();

    // Muat data hotel
    await hotelProvider.loadHotels();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authProvider),
          ChangeNotifierProvider.value(value: hotelProvider),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    print('Error initializing app: $e');
    print('Stack trace: $stackTrace');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Terjadi kesalahan: $e'),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StayEase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          primary: const Color(0xFF1E88E5),
          secondary: const Color(0xFF64B5F6),
          tertiary: const Color(0xFFFFB74D),
          background: const Color(0xFFF5F5F5),
          surface: Colors.white,
          onSurface: const Color(0xFF424242),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1E88E5),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            backgroundColor: const Color(0xFF1E88E5),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
          ),
          labelStyle: const TextStyle(color: Color(0xFF757575)),
          prefixIconColor: const Color(0xFF757575),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => Consumer<AuthProvider>(
              builder: (ctx, auth, _) => auth.isAuthenticated
                  ? const MainScreen()
                  : const LoginScreen(),
            ),
        '/register': (context) => const RegisterScreen(),
        '/orders': (context) => const OrdersScreen(),
        '/favorites': (context) => const FavoritesScreen(),
        '/payment-methods': (context) => const PaymentMethodsScreen(),
        '/transactions': (context) => const TransactionsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/help': (context) => const HelpScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({this.initialIndex = 0, super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const OrdersScreen(),
    const FavoritesScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
