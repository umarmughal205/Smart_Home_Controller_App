class DeviceModel {
  final String name;
  final bool status;
  final String? onTime;

  DeviceModel({
    required this.name,
    required this.status,
    required this.onTime,
  });

  factory DeviceModel.fromMap(Map<dynamic, dynamic> map) {
    return DeviceModel(
      name: map['name'] ?? '',
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
