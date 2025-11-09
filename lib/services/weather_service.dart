import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherInfo {
  final double temperature;
  final double windspeed;
  final String? timeIso;

  WeatherInfo({
    required this.temperature,
    required this.windspeed,
    this.timeIso,
  });
}

class WeatherService {
  Future<WeatherInfo?> getCurrentWeather() async {
    // Uprawnienia lokalizacji
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) return null;
    }
    if (perm == LocationPermission.deniedForever) return null;

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );

    // API Open-Meteo (bez klucza)
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
          '?latitude=${pos.latitude}&longitude=${pos.longitude}'
          '&current=temperature_2m,wind_speed_10m',
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) return null;

    final data = jsonDecode(res.body);
    final current = data['current'];

    return WeatherInfo(
      temperature: (current['temperature_2m'] as num).toDouble(),
      windspeed: (current['wind_speed_10m'] as num).toDouble(),
      timeIso: current['time'],
    );
  }
}
