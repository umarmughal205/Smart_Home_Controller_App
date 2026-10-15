import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BedRoomScreen extends StatefulWidget {
  @override
  _BedRoomScreenState createState() => _BedRoomScreenState();
}

class _BedRoomScreenState extends State<BedRoomScreen> with TickerProviderStateMixin {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("devices/bed_room");

  Map<String, dynamic> _devices = {};
  Map<String, AnimationController> _fanControllers = {};
  StreamSubscription<DatabaseEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = _dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          _devices = data.map((key, value) => MapEntry(key.toString(), value));
        });

        data.forEach((key, value) {
          if ((value['type'] ?? '').toLowerCase() == 'fan') {
            _updateFanAnimation(key, value['status'] ?? false, value['speed'] ?? 'Medium');
          }
        });
      }
    });
  }

  void _updateFanAnimation(String key, bool isOn, String speed) {
    if (!_fanControllers.containsKey(key)) {
      _fanControllers[key] = AnimationController(
        vsync: this,
        duration: _getFanDuration(speed),
      );
    }
    final controller = _fanControllers[key]!;
    controller.duration = _getFanDuration(speed);
    if (isOn) {
      controller.repeat();
    } else {
      controller.stop();
    }
  }

  Duration _getFanDuration(String speed) {
    switch (speed.toLowerCase()) {
      case 'low':
        return Duration(seconds: 3);
      case 'high':
        return Duration(milliseconds: 500);
      default:
        return Duration(seconds: 1);
    }
  }

  void _updateDevice(String key, Map<String, dynamic> updates) {
    _dbRef.child(key).update(updates);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    for (var controller in _fanControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f3750),
      appBar: AppBar(
        title: const Text('Bed Room',
            style: TextStyle(color: Colors.limeAccent, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: _devices.entries.map((entry) {
            final key = entry.key;
            final device = entry.value;
            final String name = device['name'] ?? key;
            final String type = (device['type'] ?? '').toLowerCase();
            final bool isOn = device['status'] ?? false;
            final String speed = device['speed'] ?? 'Medium';
            final DateTime? onTime = device['onTime'] != null ? DateTime.tryParse(device['onTime']) : null;
            final Duration? duration = isOn && onTime != null ? DateTime.now().difference(onTime) : null;

            final bool isFan = type == 'fan';
            final bool isRgb = type == 'rgb';
            final dynamic rawColor = device['color'];
            final int colorValue = rawColor is int ? rawColor : int.tryParse(rawColor.toString()) ?? 0xFFFFFFFF;
            final Color rgbColor = Color(colorValue);

            return Container(
              decoration: BoxDecoration(color: const Color(0xFF1a4b6e), borderRadius: BorderRadius.circular(10)),
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Text(isOn ? 'ON' : 'OFF',
                        style: TextStyle(color: isOn ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Switch(
                      value: isOn,
                      onChanged: (val) {
                        final updated = {
                          'status': val,
                          'onTime': val ? DateTime.now().toIso8601String() : null,
                          'name': name,
                          'type': type,
                        };
                        if (isFan) updated['speed'] = speed;
                        if (isRgb) updated['color'] = rgbColor.value.toString();
                        _updateDevice(key, updated);
                        if (isFan) _updateFanAnimation(key, val, speed);
                      },
                      activeColor: Colors.white,
                      activeTrackColor: Colors.blueGrey[300],
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        isFan
                            ? RotationTransition(
                            turns: _fanControllers.containsKey(key)
                                ? _fanControllers[key]!
                                : AlwaysStoppedAnimation(0),
                            child: Icon(FontAwesomeIcons.fan, size: 48, color: Colors.white))
                            : Icon(
                            _getDeviceIcon(type),
                            size: 48,
                            color: isRgb && isOn ? rgbColor : isOn ? Colors.white : Colors.white70),
                        const SizedBox(height: 8),
                        Text(name,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        if (isFan && isOn)
                          _buildFanSpeedButton(speed, (newSpeed) {
                            _updateDevice(key, {
                              'status': isOn,
                              'onTime': onTime?.toIso8601String(),
                              'speed': newSpeed,
                              'name': name,
                              'type': type,
                            });
                            _updateFanAnimation(key, isOn, newSpeed);
                          }),
                        if (isRgb && isOn)
                          _buildColorButton(rgbColor, (newColor) {
                            _updateDevice(key, {
                              'status': isOn,
                              'onTime': onTime?.toIso8601String(),
                              'color': newColor.value.toString(),
                              'name': name,
                              'type': type,
                            });
                          }),
                        if (duration != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              _formatDuration(duration),
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _getDeviceIcon(String type) {
    switch (type) {
      case 'light':
        return Icons.lightbulb_outline;
      case 'fan':
        return FontAwesomeIcons.fan;
      case 'tv':
        return Icons.tv;
      case 'lamp':
        return Icons.light;
      case 'rgb':
        return Icons.light_mode;
      case 'speaker':
        return Icons.speaker;
      case 'ac':
        return FontAwesomeIcons.temperatureHigh;
      case 'refrigerator':
        return FontAwesomeIcons.snowflake;
      default:
        return Icons.devices_other;
    }
  }

  Widget _buildFanSpeedButton(String speed, ValueChanged<String> onSpeedChange) {
    return GestureDetector(
      onTap: () => _showFanSpeedDialog(speed, onSpeedChange),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF2a5c8a),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blueGrey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.speed, size: 16, color: Colors.white),
            const SizedBox(width: 4),
            Text(speed, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _showFanSpeedDialog(String currentSpeed, ValueChanged<String> onSpeedChange) {
    final speeds = ['Low', 'Medium', 'High'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a4b6e),
        title: const Text('Fan Speed', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: speeds.map((speed) {
            return ListTile(
              leading: Icon(Icons.speed,
                  color: speed == 'Low'
                      ? Colors.green
                      : speed == 'Medium'
                      ? Colors.yellow
                      : Colors.red),
              title: Text(speed, style: const TextStyle(color: Colors.white)),
              onTap: () {
                onSpeedChange(speed);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildColorButton(Color selectedColor, ValueChanged<Color> onColorChange) {
    return GestureDetector(
      onTap: () => _showColorDialog(selectedColor, onColorChange),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF2a5c8a),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blueGrey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: selectedColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white),
              ),
            ),
            const SizedBox(width: 4),
            const Text('Color', style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _showColorDialog(Color selectedColor, ValueChanged<Color> onColorChange) {
    final colors = [Colors.red, Colors.green, Colors.blue];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a4b6e),
        title: const Text('Select Color', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final color = colors[index];
              return GestureDetector(
                onTap: () {
                  onColorChange(color);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selectedColor == color ? Colors.white : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: selectedColor == color
                      ? const Icon(Icons.check, size: 16, color: Colors.black)
                      : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);
    return h > 0 ? '${h}h ${m}m' : m > 0 ? '${m}m ${s}s' : '${s}s';
  }
}
