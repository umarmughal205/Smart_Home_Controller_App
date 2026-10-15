// admin_manage_devices_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AdminManageDevicesScreen extends StatefulWidget {
  const AdminManageDevicesScreen({Key? key}) : super(key: key);

  @override
  State<AdminManageDevicesScreen> createState() => _AdminManageDevicesScreenState();
}

class _AdminManageDevicesScreenState extends State<AdminManageDevicesScreen> {
  final List<String> _rooms = ['bed_room', 'kitchen', 'living_room'];
  final _deviceNameController = TextEditingController();
  final _deviceTypeController = TextEditingController();
  String _selectedRoom = 'bed_room';

  final DatabaseReference _rootRef = FirebaseDatabase.instance.ref("devices");

  void _addDevice() async {
    final name = _deviceNameController.text.trim();
    final type = _deviceTypeController.text.trim().toLowerCase();

    // Check if name/type is empty
    if (name.isEmpty || type.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both name and type')),
      );
      return;
    }

    // Regex: must start with a letter
    final letterRegex = RegExp(r'^[a-zA-Z]');

    if (!letterRegex.hasMatch(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device name must start with a letter')),
      );
      return;
    }

    if (!letterRegex.hasMatch(type)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device type must start with a letter')),
      );
      return;
    }

    final roomRef = _rootRef.child(_selectedRoom);

    final snapshot = await roomRef.get();
    if (snapshot.exists) {
      final existingDevices = Map<String, dynamic>.from(snapshot.value as Map);
      final nameExists = existingDevices.values.any((device) =>
      device is Map &&
          (device['name']?.toString().toLowerCase() ?? '') == name.toLowerCase());

      if (nameExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Device with name "$name" already exists in $_selectedRoom')),
        );
        return;
      }
    }

    final newDeviceKey = '${type}_${DateTime.now().millisecondsSinceEpoch}';

    final deviceData = {
      'name': name,
      'type': type,
      'status': false,
    };

    if (type.contains('fan')) {
      deviceData['speed'] = 'Medium';
    } else if (type.contains('rgb')) {
      deviceData['color'] = 0xFFFFFFFF;
    }

    await roomRef.child(newDeviceKey).set(deviceData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Device "$name" added successfully to $_selectedRoom')),
    );

    _deviceNameController.clear();
    _deviceTypeController.clear();
  }



  void _deleteDevice(String room, String key) {
    _rootRef.child(room).child(key).remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f3750),
      appBar: AppBar(
        backgroundColor: const Color(0xFF082B3C),
        title: const Text('Manage Devices', style: TextStyle(color: Colors.limeAccent)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedRoom,
                  dropdownColor: Colors.blueGrey,
                  decoration: const InputDecoration(labelText: 'Select Room', labelStyle: TextStyle(color: Colors.white)),
                  items: _rooms.map((room) {
                    return DropdownMenuItem(value: room, child: Text(room, style: const TextStyle(color: Colors.white)));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedRoom = value);
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _deviceNameController,
                  decoration: const InputDecoration(labelText: 'Device Name', labelStyle: TextStyle(color: Colors.white)),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _deviceTypeController,
                  decoration: const InputDecoration(labelText: 'Device Type for Icon (fan, rgb, light, lamp, etc)', labelStyle: TextStyle(color: Colors.white)),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(const Color(0xFF48707A)),
                  ),
                  onPressed: _addDevice,
                  child: const Text(
                    'Add Device',
                    style: TextStyle(color: Colors.white),
                  ),
                ),

              ],
            ),
          ),
          const Divider(color: Colors.white),
          Expanded(
            child: ListView(
              children: _rooms.map((room) {
                return StreamBuilder<DatabaseEvent>(
                  stream: _rootRef.child(room).onValue,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                      final devices = (snapshot.data!.snapshot.value as Map<dynamic, dynamic>)
                          .map((key, value) => MapEntry(key.toString(), value));

                      return ExpansionTile(
                        collapsedBackgroundColor: const Color(0xFF124460),
                        backgroundColor: const Color(0xFF1a4b6e),
                        textColor: Colors.white,
                        iconColor: Colors.white,
                        collapsedIconColor: Colors.white,
                        title: Text(room.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                        children: devices.entries.map((entry) {
                          final key = entry.key;
                          final name = entry.value['name'] ?? key;
                          return ListTile(
                            title: Text(name, style: const TextStyle(color: Colors.white)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _deleteDevice(room, key),
                            ),
                          );
                        }).toList(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
