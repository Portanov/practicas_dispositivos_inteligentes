import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class DetailScreen extends StatefulWidget {
  final String city;
  const DetailScreen({super.key, required this.city});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<WeatherProvider>().fetchWeather(widget.city),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final city = widget.city;

    return Scaffold(
      appBar: AppBar(title: Text('$city - 5 Días')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              isLandscape
                  ? SizedBox(
                      height: 200,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildDayCard('Lun', '24°C', '☁️'),
                          _buildDayCard('Mar', '26°C', '☀️'),
                          _buildDayCard('Mié', '20°C', '🌧️'),
                          _buildDayCard('Jue', '25°C', '☁️'),
                          _buildDayCard('Vie', '28°C', '☀️'),
                        ],
                      ),
                    )
                  : Wrap(
                      alignment: WrapAlignment.spaceEvenly,
                      children: [
                        _buildDayCard('Lun', '24°C', '☁️'),
                        _buildDayCard('Mar', '26°C', '☀️'),
                        _buildDayCard('Mié', '20°C', '🌧️'),
                        _buildDayCard('Jue', '25°C', '☁️'),
                        _buildDayCard('Vie', '28°C', '☀️'),
                      ],
                    ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayCard(String day, String temp, String emoji) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(temp, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
