import 'package:climate_app/widgets/temperature_card.dart';
import 'package:flutter/material.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(title: const Text('Clima Actual'), centerTitle: true),
      body: Center(
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
                            city: 'Santiago de Querétaro',
                            temperature: 24,
                            condition: 'nublado',
                            iconColor: Colors.blue,
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Humedad: 65% | Viento: 12 km/h'),
                          const Text('Sensación Térmica: 20°C'),
                          const SizedBox(height: 24),
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
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TemperatureCard(
                        city: 'Santiago de Querétaro',
                        temperature: 24,
                        condition: 'soleado',
                        iconColor: Colors.blue,
                      ),
                      const SizedBox(height: 32),
                      const Text('Humedad: 65% | Viento: 12 km/h'),
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
      ),
    );
  }
}
