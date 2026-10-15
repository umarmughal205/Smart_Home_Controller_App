class LampModel {
  final String name;
  final bool status;
  final String? onTime;

  LampModel({
    required this.name,
    required this.status,
    required this.onTime,
  });

  factory LampModel.fromMap(Map<dynamic, dynamic> map) {
    return LampModel(
      name: map['name'] ?? 'Lamp',
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
