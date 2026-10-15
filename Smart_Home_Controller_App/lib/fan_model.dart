class FanModel {
  final String name;
  final bool status;
  final String? onTime;
  final String speed;

  FanModel({
    required this.name,
    required this.status,
    required this.onTime,
    required this.speed,
  });

  factory FanModel.fromMap(Map<dynamic, dynamic> map) {
    return FanModel(
      name: map['name'] ?? 'Fan',
      status: map['status'] ?? false,
      onTime: map['onTime'],
      speed: map['speed'] ?? 'Medium',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'status': status,
      'onTime': onTime,
      'speed': speed,
    };
  }
}
