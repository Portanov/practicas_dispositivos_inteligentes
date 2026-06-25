class Weather {
  final String city;
  final int temperature;
  final String condition;
  final String description;
  final int humidity;
  final double windSpeed;

  Weather({
    required this.city,
    required this.temperature,
    required this.condition,
    required this.description,
    required this.humidity,
    required this.windSpeed,
  });
  factory Weather.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('main')) {
      throw FormatException('Missing main field in weather data');
    }
    
    final temp = json['main']['temp'];
    if (temp is! num) {
      throw FormatException('Temperature must be number');
    }

    return Weather(
      city: json['name'] ?? 'Unknown',
      temperature: temp.toInt(),
      condition: (json['weather'] as List?)?.isNotEmpty == true
          ? json['weather'][0]['main'] ?? 'unknown'
          : 'unknown',
      description: json['weather'][0]['description'] ?? '',
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: ((json['wind']?['speed']) ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'city': city,
    'temperature': temperature,
    'condition': condition,
    'humidity': humidity,
  };

  @override
  String toString() {
    return 'Weather(city: $city, temp: $temperature°C, condition: $condition, humidity: $humidity%)';
  }
}
