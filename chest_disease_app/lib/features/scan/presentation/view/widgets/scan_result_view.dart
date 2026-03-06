import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chest_disease_app/core/components/widgets/custom_button.dart';
import 'package:chest_disease_app/core/data/network_services/api_service.dart';
import 'package:chest_disease_app/features/chats/presentation/view/screen/chat_list_screen.dart';
import 'package:chest_disease_app/features/scan/domain/entities/chest_prediction_entity.dart';
import 'package:chest_disease_app/foundations/app_urls.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ScanResultView extends StatefulWidget {
  final ChestPredictionEntity entity;
  final File? originalImage;
  final String? imageUrl;

  const ScanResultView({
    super.key,
    required this.entity,
    this.originalImage,
    this.imageUrl,
  }) : assert(originalImage != null || imageUrl != null, 'Provide originalImage or imageUrl');

  @override
  State<ScanResultView> createState() => _ScanResultViewState();
}

class _ScanResultViewState extends State<ScanResultView> {
  bool _showHeatmap = false;
  bool _isSaving = false;

  Future<void> _saveReport() async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
    });

    try {
      // Generate a friendly filename based on prediction and confidence
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final predictionSlug = widget.entity.prediction.replaceAll(' ', '_');
      final filename =
          'scan_${predictionSlug}_${widget.entity.confidence.toStringAsFixed(1)}%_$timestamp.png';

      // Prefer using a server image URL if available (history or upload response)
      String? url = widget.imageUrl;
      url ??= widget.entity.imagePath != null
          ? (widget.entity.imagePath!.startsWith('http')
              ? widget.entity.imagePath
              : '${AppUrls.baseUrl}${widget.entity.imagePath}')
          : null;

      if (url != null) {
        await AppDio().downloadFile(url, filename);
      } else if (widget.originalImage != null) {
        // Fallback: copy the original local image to Downloads/Documents
        Directory? directory;
        if (Platform.isAndroid) {
          directory = Directory('/storage/emulated/0/Download');
        } else if (Platform.isIOS) {
          // On iOS, use app documents directory
          directory = await getApplicationDocumentsDirectory();
        }

        if (directory != null) {
          if (!await directory.exists()) {
            await directory.create(recursive: true);
          }
          final sanitizedFileName = filename.replaceAll(
            RegExp(r'[<>:"/\\|?*]'),
            '_',
          );
          final filePath = '${directory.path}/$sanitizedFileName';
          await widget.originalImage!.copy(filePath);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report saved to your device.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save report: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

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
                  child: widget.originalImage != null
                      ? Image.file(
                          widget.originalImage!,
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : CachedNetworkImage(
                          imageUrl: widget.imageUrl!,
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (_, __, ___) => const Icon(Icons.broken_image, size: 48),
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
                isLoading: _isSaving,
                onTap: () {
                  if (!_isSaving) {
                    _saveReport();
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomButton(
                text: 'Chat with Medical Assistant',
                backgroundColor: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MedicalChatbotScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
