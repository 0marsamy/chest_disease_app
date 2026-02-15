import 'dart:io';

import 'package:chest_disease_app/core/components/widgets/custom_button.dart';
import 'package:chest_disease_app/features/scan/domain/entities/chest_prediction_entity.dart';
import 'package:flutter/material.dart';

class ScanResultView extends StatefulWidget {
  final ChestPredictionEntity entity;
  final File originalImage;

  const ScanResultView(
      {super.key, required this.entity, required this.originalImage});

  @override
  State<ScanResultView> createState() => _ScanResultViewState();
}

class _ScanResultViewState extends State<ScanResultView> {
  bool _showHeatmap = false;

  @override
  Widget build(BuildContext context) {
    final isDisease = widget.entity.prediction.toLowerCase() != 'normal';
    final diagnosisColor = isDisease ? Colors.red[400] : Colors.green[400];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Result'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Display Area
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    widget.originalImage,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (_showHeatmap)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Opacity(
                      opacity: 0.5,
                      child: Container(
                        height: 300,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Heatmap Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Show Heatmap Overlay', style: TextStyle(fontSize: 16)),
                Switch.adaptive(
                  value: _showHeatmap,
                  onChanged: (value) {
                    setState(() {
                      _showHeatmap = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Diagnosis Card
            Card(
              elevation: 4,
              color: diagnosisColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Diagnosis',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.entity.prediction,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Confidence Score
            Text('Confidence Score: ${(widget.entity.confidence).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: widget.entity.confidence / 100,
              minHeight: 12,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(diagnosisColor!),
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 24),

            // Recommendation Section
            const Text('Recommendation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(widget.entity.description, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 32),

          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Save Report',
                onTap: () {
                  // TODO: Implement save report functionality
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomButton(
                text: 'Chat with a Doctor',
                backgroundColor: Colors.blue,
                onTap: () {
                  // TODO: Implement chat functionality
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
