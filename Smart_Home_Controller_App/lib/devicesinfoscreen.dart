import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DevicesInfoScreen extends StatefulWidget {
  @override
  _DevicesInfoScreenState createState() => _DevicesInfoScreenState();
}

class _DevicesInfoScreenState extends State<DevicesInfoScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("devices");

  late StreamSubscription<DatabaseEvent> _subscription;

  int _devicesOnCount = 0;
  int _devicesOffCount = 0;

  @override
  void initState() {
    super.initState();
    _subscribeToDevicesStatus();
  }

  void _subscribeToDevicesStatus() {
    _subscription = _dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        int onCount = 0;
        int offCount = 0;

        data.forEach((roomKey, devicesMap) {
          if (devicesMap is Map) {
            devicesMap.forEach((deviceKey, deviceData) {
              if (deviceData is Map && deviceData.containsKey('status')) {
                final status = deviceData['status'];
                if (status == true) {
                  onCount++;
                } else {
                  offCount++;
                }
              }
            });
          }
        });

        setState(() {
          _devicesOnCount = onCount;
          _devicesOffCount = offCount;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0f3750);
    // const cardColor = Color(0xFF1a4b6e);
    const cardColor = Color(0xFF48707A);
    const accentColor = Colors.limeAccent;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'Devices Info',
          style: TextStyle(
            color: accentColor,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: [
              _buildStatusCard(
                title: 'Devices On',
                count: _devicesOnCount,
                icon: Icons.power,
                iconColor: Colors.greenAccent.shade400,
                cardColor: cardColor,
              ),
              _buildStatusCard(
                title: 'Devices Off',
                count: _devicesOffCount,
                icon: Icons.power_off,
                iconColor: Colors.redAccent.shade400,
                cardColor: cardColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required int count,
    required IconData icon,
    required Color iconColor,
    required Color cardColor,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: iconColor),
          const SizedBox(height: 16),
          Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
