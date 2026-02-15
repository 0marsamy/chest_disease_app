import 'dart:io';
import 'package:chest_disease_app/features/scan/domain/entities/chest_prediction_entity.dart';
import 'package:chest_disease_app/features/scan/presentation/view/widgets/scan_result_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _HistoryItem {
  final String patientName;
  final String diagnosis;
  final String date;
  final double confidence;

  _HistoryItem({
    required this.patientName,
    required this.diagnosis,
    required this.date,
    required this.confidence,
  });
}

class _ReportsScreenState extends State<ReportsScreen> {
  final TextEditingController _searchController = TextEditingController();
  late List<_HistoryItem> _historyItems;
  List<_HistoryItem> _filteredHistoryItems = [];
  File? _placeholderImageFile;

  @override
  void initState() {
    super.initState();
    _historyItems = [
      _HistoryItem(patientName: 'Ahmed Ali', diagnosis: 'Viral Pneumonia', date: '2025-01-20', confidence: 98.0),
      _HistoryItem(patientName: 'Fatima Khan', diagnosis: 'Normal', date: '2025-01-22', confidence: 99.5),
      _HistoryItem(patientName: 'Youssef El-Masry', diagnosis: 'Bacterial Pneumonia', date: '2025-01-25', confidence: 92.3),
      _HistoryItem(patientName: 'Nour Ibrahim', diagnosis: 'Tuberculosis', date: '2025-02-01', confidence: 85.0),
      _HistoryItem(patientName: 'Layla Hassan', diagnosis: 'Normal', date: '2025-02-05', confidence: 99.8),
      _HistoryItem(patientName: 'Mustafa Ahmed', diagnosis: 'COVID-19', date: '2025-02-10', confidence: 97.2),
    ];
    _filteredHistoryItems = _historyItems;
    _searchController.addListener(_filterHistory);
    _loadPlaceholderImage();
  }

  Future<void> _loadPlaceholderImage() async {
    final byteData = await rootBundle.load('assets/image/person.png');
    final buffer = byteData.buffer;
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/person.png');
    await tempFile.writeAsBytes(buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    setState(() {
      _placeholderImageFile = tempFile;
    });
  }

  void _filterHistory() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredHistoryItems = _historyItems.where((item) {
        return item.patientName.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History 📜'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search by patient name...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredHistoryItems.length,
              itemBuilder: (context, index) {
                final item = _filteredHistoryItems[index];
                final isDisease = item.diagnosis.toLowerCase() != 'normal';
                final diagnosisColor = isDisease ? Colors.red[400] : Colors.green[400];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blueGrey,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(item.patientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.diagnosis,
                          style: TextStyle(
                            color: diagnosisColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(item.date),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      if (_placeholderImageFile != null) {
                        final predictionEntity = ChestPredictionEntity(
                          prediction: item.diagnosis,
                          confidence: item.confidence,
                          description: 'This is a sample description from the history.',
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScanResultView(
                              entity: predictionEntity,
                              originalImage: _placeholderImageFile!,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}