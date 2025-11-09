import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/scan_entry.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = StorageService();
  final _weatherService = WeatherService();
  late Future<WeatherInfo?> _weatherFuture;

  @override
  void initState() {
    super.initState();
    _weatherFuture = _weatherService.getCurrentWeather();
  }

  Future<void> _scanAndAdd() async {
    final value = await context.push<String>('/scan');
    if (value == null || value.trim().isEmpty) return;

    final entries = await _storage.load();
    entries.insert(
      0,
      ScanEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        value: value.trim(),
        createdAt: DateTime.now(),
      ),
    );
    await _storage.save(entries);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Zapisano skan w historii')),
    );
  }

  Future<void> _addManual() async {
    final created = await context.push<ScanEntry>('/edit');
    if (created == null) return;

    final entries = await _storage.load();
    entries.insert(0, created);
    await _storage.save(entries);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dodano wpis do historii')),
    );
  }

  Widget _buildWeatherCard() {
    return FutureBuilder<WeatherInfo?>(
      future: _weatherFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Card(
            child: ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Pobieranie pogody...'),
            ),
          );
        }

        if (snap.hasError) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.error),
              title: const Text('Błąd pobierania pogody'),
              trailing: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () =>
                    setState(() => _weatherFuture = _weatherService.getCurrentWeather()),
              ),
            ),
          );
        }

        final w = snap.data;
        if (w == null) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.location_off),
              title: const Text('Brak danych pogodowych'),
              subtitle: const Text('Sprawdź uprawnienia lokalizacji'),
              trailing: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () =>
                    setState(() => _weatherFuture = _weatherService.getCurrentWeather()),
              ),
            ),
          );
        }

        return Card(
          child: ListTile(
            leading: const Icon(Icons.wb_sunny),
            title: Text('Temperatura: ${w.temperature.toStringAsFixed(1)}°C'),
            subtitle: Text('Wiatr: ${w.windspeed.toStringAsFixed(1)} m/s'),
            trailing: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () =>
                  setState(() => _weatherFuture = _weatherService.getCurrentWeather()),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skaner QR')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildWeatherCard(),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _scanAndAdd,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Skanuj kod QR'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => context.push('/history'),
              icon: const Icon(Icons.history),
              label: const Text('Historia'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _addManual,
              icon: const Icon(Icons.add),
              label: const Text('Dodaj ręcznie'),
            ),
          ],
        ),
      ),
    );
  }
}
