class LightModel {
  final String name;
  final bool status;
  final String? onTime;

  LightModel({
    required this.name,
    required this.status,
    required this.onTime,
  });

  factory LightModel.fromMap(Map<dynamic, dynamic> map) {
    return LightModel(
      name: map['name'] ?? 'Light',
      status: map['status'] ?? false,
      onTime: map['onTime'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'status': status,
      'onTime': onTime,
    };
  }
}
