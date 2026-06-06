import 'package:climate_app/utils/waether_utils.dart';
import 'package:climate_app/widgets/temperature_card.dart';
import 'package:flutter/material.dart';
import 'search_screen.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<WeatherProvider>(
      context,
      listen: false,
    ).loadWeather('Santiago de Querétaro');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clima Actual'),
        centerTitle: true,
        actions: [
          Consumer<WeatherProvider>(
            builder: (context, weather, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(weather.temperatureUnit),
                  Switch.adaptive(
                    value: weather.temperatureUnit == '°F',
                    onChanged: (_) => weather.toggleTemperatureUnit(),
                  ),
                  const SizedBox(width: 8),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, weather, child) {
          if (weather.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (weather.errorMessage != null) {
            return Center(child: Text(weather.errorMessage!));
          } else if (weather.weather == null) {
            return const Center(child: Text('No data'));
          }

          final isLandscape =
              MediaQuery.of(context).orientation == Orientation.landscape;

          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: isLandscape
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TemperatureCard(
                                city: weather.weather!.city,
                                temperature: weather.displayedTemperature,
                                unit: weather.temperatureUnit,
                                condition: weather.weather!.condition,
                                iconColor: WeatherUtils.getWeatherColor(
                                  weather.weather!.condition,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Humedad: ${weather.weather!.humidity}% | Viento: 12 km/h',
                              ),
                              const Text('Sensación Térmica: 20°C'),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SearchScreen(),
                                    ),
                                  );
                                },
                                child: const Text('Buscar Ciudades'),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TemperatureCard(
                            city: weather.weather!.city,
                            temperature: weather.displayedTemperature,
                            unit: weather.temperatureUnit,
                            condition: weather.weather!.condition,
                            iconColor: WeatherUtils.getWeatherColor(weather.weather!.condition),
                          ),
                          const SizedBox(height: 32),
                          Text('Humedad: ${weather.weather!.humidity}% | Viento: 12 km/h'),
                          const SizedBox(height: 32),
                          const Text('Sensación Térmica: 20°C'),
                          const SizedBox(height: 40),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SearchScreen(),
                                ),
                              );
                            },
                            child: const Text('Buscar Ciudades'),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
