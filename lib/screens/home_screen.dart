import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stay_ease/providers/hotel_provider.dart';
import 'package:stay_ease/widgets/app_drawer.dart';
import 'package:stay_ease/widgets/hotel_card.dart';
import 'package:stay_ease/screens/booking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => Provider.of<HotelProvider>(context, listen: false).loadHotels());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'StayEase',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primary,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari hotel...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                // TODO: Implementasi pencarian
                Provider.of<HotelProvider>(context, listen: false)
                    .searchHotels(value);
              },
            ),
          ),
          Expanded(
            child: Consumer<HotelProvider>(
              builder: (context, hotelProvider, _) => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: hotelProvider.hotels.length,
                itemBuilder: (context, index) {
                  final hotel = hotelProvider.hotels[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingScreen(hotel: hotel),
                          ),
                        );
                      },
                      child: HotelCard(hotel: hotel),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
