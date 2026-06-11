import 'package:climate_app/utils/waether_utils.dart';
import 'package:climate_app/widgets/temperature_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'search_screen.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../services/ble_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BleService _bleService = BleService();
  List<ScanResult> _devices = [];
  bool _isScanning = false;

  Future<void> _scanDevices() async {
    setState(() {
      _isScanning = true;
    });

    try {
      final results = await _bleService.scanDevices();
      setState(() {
        _devices = results;
      });
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    await _bleService.connectToDevice(device);
  }

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
                            iconColor: WeatherUtils.getWeatherColor(
                              weather.weather!.condition,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Humedad: ${weather.weather!.humidity}% | Viento: 12 km/h',
                          ),
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
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _isScanning ? null : _scanDevices,
                            child: const Text('Buscar Dispositivos'),
                          ),

                          const SizedBox(height: 10),

                          Consumer<WeatherProvider>(
                            builder: (_, weather, __) {
                              if (weather.isBleConnecting) {
                                return const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(),
                                );
                              }
                              return Text(weather.bleStatus);
                            },
                          ),

                          const SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _devices.length,
                            itemBuilder: (context, index) {
                              final scanResult = _devices[index];
                              final device = scanResult.device;

                              return ListTile(
                                title: Text(
                                  device.platformName.isNotEmpty
                                      ? device.platformName
                                      : 'Dispositivo sin nombre',
                                ),
                                subtitle: Text(device.remoteId.str),
                                onTap: () async {
                                  final provider = context
                                      .read<WeatherProvider>();
                                  await provider.connectAndReadDevice(
                                    device,
                                    serviceUuid: Guid('180D'),
                                    characteristicUuid: Guid('2A37'),
                                  );
                                },
                              );
                            },
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
