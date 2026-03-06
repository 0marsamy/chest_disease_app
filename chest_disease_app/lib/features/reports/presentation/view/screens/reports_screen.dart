import 'package:chest_disease_app/core/services/service_locator/service_locator.dart';
import 'package:chest_disease_app/features/medical_history/data/model/detection_response.dart';
import 'package:chest_disease_app/features/medical_history/data/repository/medical_history_repository.dart';
import 'package:chest_disease_app/features/scan/domain/entities/chest_prediction_entity.dart';
import 'package:chest_disease_app/features/scan/presentation/view/widgets/scan_result_view.dart';
import 'package:chest_disease_app/foundations/app_urls.dart';
import 'package:flutter/material.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _HistoryItem {
  final String displayName;
  final String diagnosis;
  final String date;
  final double confidence;
  final String? imageUrl;
  final String? description;

  _HistoryItem({
    required this.displayName,
    required this.diagnosis,
    required this.date,
    required this.confidence,
    this.imageUrl,
    this.description,
  });
}

class _ReportsScreenState extends State<ReportsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<_HistoryItem> _historyItems = [];
  List<_HistoryItem> _filteredHistoryItems = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterHistory);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final repo = getIt<MedicalHistoryRepository>();
    final result = await repo.getPatientScans(DetectionRequest(pageIndex: 0, pageSize: 100));
    result.fold(
      (err) => setState(() {
        _loading = false;
        _error = err.message;
        _historyItems = [];
        _filteredHistoryItems = [];
      }),
      (response) {
        final items = response.data.map((d) {
          final dateStr = '${d.uploadDate.year}-${d.uploadDate.month.toString().padLeft(2, '0')}-${d.uploadDate.day.toString().padLeft(2, '0')}';
          final imageUrl = d.imagePath.startsWith('http') ? d.imagePath : '${AppUrls.baseUrl}${d.imagePath}';
          return _HistoryItem(
            displayName: 'Scan - $dateStr - ${d.detectionClass}',
            diagnosis: d.detectionClass,
            date: dateStr,
            confidence: d.confidence ?? 0,
            imageUrl: imageUrl,
            description: d.description,
          );
        }).toList();
        setState(() {
          _loading = false;
          _historyItems = items;
          _filteredHistoryItems = items;
        });
      },
    );
  }

  void _filterHistory() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredHistoryItems = _historyItems.where((item) {
        return item.displayName.toLowerCase().contains(query) ||
            item.diagnosis.toLowerCase().contains(query) ||
            item.date.contains(query);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search by diagnosis or date...',
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
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_error!, textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: _loadHistory,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredHistoryItems.isEmpty
                        ? const Center(child: Text('No scan history yet.\nRun a scan to see results here.'))
                        : ListView.builder(
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
                                    child: Icon(Icons.medical_services, color: Colors.white),
                                  ),
                                  title: Text(item.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                                    final entity = ChestPredictionEntity(
                                      prediction: item.diagnosis,
                                      confidence: item.confidence,
                                      description: item.description ?? 'Result from X-ray AI: ${item.diagnosis} (${item.confidence.toStringAsFixed(1)}%)',
                                    );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ScanResultView(
                                          entity: entity,
                                          imageUrl: item.imageUrl,
                                        ),
                                      ),
                                    );
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