import 'package:climate_app/utils/waether_utils.dart';
import 'package:climate_app/widgets/temperature_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'search_screen.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../providers/ble_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<WeatherProvider>().fetchWeather('Queretaro'),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search() {
    final city = _controller.text.trim();
    if (city.isNotEmpty) {
      context.read<WeatherProvider>().fetchWeather(city);
      FocusScope.of(context).unfocus();
    }
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Buscar ciudad...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _search, child: const Text('Buscar')),
              ],
            ),
          ),

          Expanded(
            child: Consumer<WeatherProvider>(
              builder: (context, weather, _) {
                if (weather.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (weather.error != null) {
                  return Center(child: Text(weather.error!));
                }

                if (weather.weather == null) {
                  return const Center(child: Text('Ingresa una ciudad'));
                }

                final isLandscape =
                    MediaQuery.of(context).orientation == Orientation.landscape;

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),

                    child: isLandscape
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Column(
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

                                    const SizedBox(height: 20),

                                    Text(
                                      'Humedad: ${weather.weather!.humidity}%',
                                    ),
                                    Text(
                                      'Viento: ${weather.weather!.windSpeed} m/s',
                                    ),

                                    const SizedBox(height: 20),

                                    ElevatedButton(
                                      onPressed: () async {
                                        final city = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const SearchScreen(),
                                          ),
                                        );

                                        if (city != null) {
                                          context
                                              .read<WeatherProvider>()
                                              .fetchWeather(city);
                                        }
                                      },
                                      child: const Text('Buscar Ciudades'),
                                    ),
                                  ],
                                ),
                              ),

                              Expanded(
                                child: Consumer<BleProvider>(
                                  builder: (_, ble, __) {
                                    return Column(
                                      children: [
                                        ElevatedButton(
                                          onPressed: ble.isScanning
                                              ? null
                                              : ble.scanDevices,
                                          child: Text(
                                            ble.isScanning
                                                ? 'Escaneando...'
                                                : 'Buscar Dispositivos',
                                          ),
                                        ),

                                        const SizedBox(height: 10),

                                        if (ble.isConnecting)
                                          const CircularProgressIndicator()
                                        else
                                          Text(ble.status),

                                        const SizedBox(height: 10),

                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: ble.devices.length,
                                          itemBuilder: (context, index) {
                                            final device =
                                                ble.devices[index].device;

                                            return ListTile(
                                              title: Text(
                                                device.platformName.isNotEmpty
                                                    ? device.platformName
                                                    : 'Dispositivo sin nombre',
                                              ),
                                              subtitle: Text(
                                                device.remoteId.str,
                                              ),
                                              onTap: () async {
                                                await ble.connectAndRead(
                                                  device,
                                                  serviceUuid: Guid('180D'),
                                                  characteristicUuid: Guid(
                                                    '2A37',
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                        : Column(
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

                              const SizedBox(height: 20),

                              Text('Humedad: ${weather.weather!.humidity}%'),
                              Text('Viento: ${weather.weather!.windSpeed} m/s'),

                              const SizedBox(height: 20),

                              ElevatedButton(
                                onPressed: () async {
                                  final city = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SearchScreen(),
                                    ),
                                  );

                                  if (city != null) {
                                    context
                                        .read<WeatherProvider>()
                                        .fetchWeather(city);
                                  }
                                },
                                child: const Text('Buscar Ciudades'),
                              ),

                              const SizedBox(height: 20),

                              Consumer<BleProvider>(
                                builder: (_, ble, __) {
                                  return Column(
                                    children: [
                                      ElevatedButton(
                                        onPressed: ble.isScanning
                                            ? null
                                            : ble.scanDevices,
                                        child: Text(
                                          ble.isScanning
                                              ? 'Escaneando...'
                                              : 'Buscar Dispositivos',
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      if (ble.isConnecting)
                                        const CircularProgressIndicator()
                                      else
                                        Text(ble.status),

                                      const SizedBox(height: 10),

                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: ble.devices.length,
                                        itemBuilder: (context, index) {
                                          final device =
                                              ble.devices[index].device;

                                          return ListTile(
                                            title: Text(
                                              device.platformName.isNotEmpty
                                                  ? device.platformName
                                                  : 'Dispositivo sin nombre',
                                            ),
                                            subtitle: Text(device.remoteId.str),
                                            onTap: () async {
                                              await ble.connectAndRead(
                                                device,
                                                serviceUuid: Guid('180D'),
                                                characteristicUuid: Guid(
                                                  '2A37',
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
