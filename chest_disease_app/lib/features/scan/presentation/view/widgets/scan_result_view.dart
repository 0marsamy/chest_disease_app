import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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
  }) : assert(originalImage != null || imageUrl != null);

  @override
  State<ScanResultView> createState() => _ScanResultViewState();
}

class _ScanResultViewState extends State<ScanResultView> {
  bool _showHeatmap = false;
  bool _isSaving = false;

  Uint8List? get _decodedHeatmapBytes {
    final raw = widget.entity.heatmapBase64;
    if (raw == null || raw.isEmpty) return null;
    try {
      final payload = raw.contains(',') ? raw.split(',').last : raw;
      return base64Decode(payload);
    } catch (_) {
      return null;
    }
  }

  bool get isInvalid =>
      widget.entity.prediction.toLowerCase() == 'not x-ray' ||
      widget.entity.prediction.toLowerCase() == 'invalid image';

  Future<void> _saveReport() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');

      final predictionSlug = widget.entity.prediction.replaceAll(' ', '_');

      final filename =
          'scan_${predictionSlug}_${widget.entity.confidence.toStringAsFixed(1)}%_$timestamp.png';

      String? url = widget.imageUrl;
      url ??= widget.entity.imagePath != null
          ? (widget.entity.imagePath!.startsWith('http')
                ? widget.entity.imagePath
                : '${AppUrls.baseUrl}${widget.entity.imagePath}')
          : null;

      if (url != null) {
        await AppDio().downloadFile(url, filename);
      } else if (widget.originalImage != null) {
        Directory? directory;

        if (Platform.isAndroid) {
          directory = Directory('/storage/emulated/0/Download');
        } else if (Platform.isIOS) {
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save report: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisease = widget.entity.prediction.toLowerCase() != 'normal';
    final diagnosisColor = isDisease ? Colors.red[400] : Colors.green[400];
    final heatmapBytes = _decodedHeatmapBytes;
    final hasHeatmap = heatmapBytes != null;
    final showHeatmapImage = _showHeatmap && hasHeatmap;

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Result'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// 🖼️ Display original image or heatmap from same API response
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: showHeatmapImage
                  ? Image.memory(
                      heatmapBytes,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : widget.originalImage != null
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
                        ),
            ),

            const SizedBox(height: 24),

            /// ❌ حالة Invalid
            if (isInvalid)
              Center(
                child: Column(
                  children: const [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 60,
                      color: Colors.red,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Invalid Image",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Please upload a valid chest X-ray image",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            /// ✅ الحالة الطبيعية
            if (!isInvalid) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    hasHeatmap
                        ? 'Show Heatmap'
                        : 'Show Heatmap (not available)',
                  ),
                  Switch(
                    value: _showHeatmap,
                    onChanged: hasHeatmap
                        ? (v) => setState(() => _showHeatmap = v)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Card(
                color: diagnosisColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Diagnosis',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Text(
                        widget.entity.prediction,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Confidence: ${widget.entity.confidence.toStringAsFixed(1)}%',
              ),
              LinearProgressIndicator(value: widget.entity.confidence / 100),

              const SizedBox(height: 20),

              const Text('Recommendation'),
              Text(widget.entity.description),
            ],
          ],
        ),
      ),

      /// 🔽 الأزرار تحت (ثابتة)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Save Report',
                isLoading: _isSaving,
                onTap: _saveReport,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CustomButton(
                text: 'Chat with Medical',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MedicalChatbotScreen(),
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
