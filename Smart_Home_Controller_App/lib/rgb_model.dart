class RgbModel {
  final String name;
  final bool status;
  final int timerSeconds;
  final int colorValue;

  RgbModel({
    required this.name,
    required this.status,
    required this.timerSeconds,
    required this.colorValue,
  });

  factory RgbModel.fromMap(Map<dynamic, dynamic> map) {
    final rawColor = map['color'];
    final colorInt = rawColor is int
        ? rawColor
        : int.tryParse(rawColor.toString()) ?? 0xFFFFFFFF;

    return RgbModel(
      name: map['name'] ?? 'RGB Light',
      status: map['status'] ?? false,
      timerSeconds: map['timerSeconds'] ?? 0,
      colorValue: colorInt,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'status': status,
      'timerSeconds': timerSeconds,
      'color': colorValue,
    };
  }
}
