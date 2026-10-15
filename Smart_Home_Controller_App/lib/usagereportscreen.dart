import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart'; // Add printing package
import 'package:pdf/pdf.dart'; // Required for PDF generation
import 'package:pdf/widgets.dart' as pw; // PDF widgets

class UsageReportScreen extends StatefulWidget {
  const UsageReportScreen({super.key});

  @override
  State<UsageReportScreen> createState() => _UsageReportScreenState();
}

class _UsageReportScreenState extends State<UsageReportScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('devices');
  Map<String, List<Map<String, dynamic>>> groupedReports = {
    'Daily': [],
    'Weekly': [],
    'Monthly': [],
  };

  @override
  void initState() {
    super.initState();
    _fetchUsageReports();
  }

  void _fetchUsageReports() async {
    final snapshot = await _dbRef.get();

    final now = DateTime.now();
    final dailyThreshold = now.subtract(const Duration(days: 1));
    final weeklyThreshold = now.subtract(const Duration(days: 7));
    final monthlyThreshold = now.subtract(const Duration(days: 30));

    final daily = <Map<String, dynamic>>[];
    final weekly = <Map<String, dynamic>>[];
    final monthly = <Map<String, dynamic>>[];

    if (snapshot.exists) {
      final rooms = snapshot.value as Map<dynamic, dynamic>;

      rooms.forEach((roomKey, roomData) {
        final devices = roomData as Map<dynamic, dynamic>;

        devices.forEach((deviceKey, deviceValue) {
          final device = Map<String, dynamic>.from(deviceValue);
          if (device['status'] == true && device.containsKey('onTime')) {
            try {
              final onTime = DateTime.parse(device['onTime']);
              final duration = now.difference(onTime);
              final formattedDuration = _formatDuration(duration);

              final report = {
                'room': roomKey.toString(),
                'device': device['name'] ?? deviceKey.toString(),
                'onTime': onTime,
                'duration': formattedDuration,
              };

              if (onTime.isAfter(dailyThreshold)) {
                daily.add(report);
              } else if (onTime.isAfter(weeklyThreshold)) {
                weekly.add(report);
              } else if (onTime.isAfter(monthlyThreshold)) {
                monthly.add(report);
              }
            } catch (e) {
              // ignore parse errors
            }
          }
        });
      });
    }

    setState(() {
      groupedReports['Daily'] = daily;
      groupedReports['Weekly'] = weekly;
      groupedReports['Monthly'] = monthly;
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) return '$hours h $minutes m';
    if (minutes > 0) return '$minutes m $seconds s';
    return '$seconds s';
  }

  // Function to generate and print the PDF report
  Future<void> _printReport() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(level: 0, child: pw.Text('Usage Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))),
            pw.SizedBox(height: 20),

            // Daily Report
            if (groupedReports['Daily']!.isNotEmpty) ...[
              pw.Text('Daily Report', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Device', 'Room', 'Time ON'],
                data: groupedReports['Daily']!.map((item) => [
                  item['device'],
                  item['room'].toString().replaceAll('_', ' '),
                  item['duration'],
                ]).toList(),
              ),
              pw.SizedBox(height: 20),
            ],

            // Weekly Report
            if (groupedReports['Weekly']!.isNotEmpty) ...[
              pw.Text('Weekly Report', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Device', 'Room', 'Time ON'],
                data: groupedReports['Weekly']!.map((item) => [
                  item['device'],
                  item['room'].toString().replaceAll('_', ' '),
                  item['duration'],
                ]).toList(),
              ),
              pw.SizedBox(height: 20),
            ],

            // Monthly Report
            if (groupedReports['Monthly']!.isNotEmpty) ...[
              pw.Text('Monthly Report', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Device', 'Room', 'Time ON'],
                data: groupedReports['Monthly']!.map((item) => [
                  item['device'],
                  item['room'].toString().replaceAll('_', ' '),
                  item['duration'],
                ]).toList(),
              ),
            ],
          ];
        },
      ),
    );

    // Trigger the print dialog
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Widget _buildTable(String title, List<Map<String, dynamic>> data) {
    if (data.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          '$title Report',
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF124460),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DataTable(
            columnSpacing: 16,
            columns: const [
              DataColumn(label: Text('Device', style: TextStyle(color: Colors.white))),
              DataColumn(label: Text('Room', style: TextStyle(color: Colors.white))),
              DataColumn(label: Text('Time ON', style: TextStyle(color: Colors.white))),
            ],
            rows: data.map((item) {
              return DataRow(
                cells: [
                  DataCell(Text(item['device'], style: const TextStyle(color: Colors.white))),
                  DataCell(Text(item['room'].toString().replaceAll('_', ' '), style: const TextStyle(color: Colors.white))),
                  DataCell(Text(item['duration'], style: const TextStyle(color: Colors.white))),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f3750),
      appBar: AppBar(
        title: const Text('Usage Report', style: TextStyle(color: Colors.limeAccent)),
        backgroundColor: const Color(0xFF082B3C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTable('Daily', groupedReports['Daily']!),
            _buildTable('Weekly', groupedReports['Weekly']!),
            _buildTable('Monthly', groupedReports['Monthly']!),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _printReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.limeAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Print Report', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}