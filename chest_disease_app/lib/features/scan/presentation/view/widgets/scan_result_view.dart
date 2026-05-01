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

enum _ImageMode { original, segmented, heatmap }

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
  _ImageMode _imageMode = _ImageMode.original;
  bool _isSaving = false;

  Uint8List? get _segmentedBytes =>
      _decodeBase64Image(widget.entity.segmentedBase64);

  Uint8List? get _heatmapBytes =>
      _decodeBase64Image(widget.entity.heatmapBase64);

  _ImageMode get _effectiveImageMode {
    if (_imageMode == _ImageMode.segmented && _segmentedBytes != null) {
      return _ImageMode.segmented;
    }
    if (_imageMode == _ImageMode.heatmap && _heatmapBytes != null) {
      return _ImageMode.heatmap;
    }
    return _ImageMode.original;
  }

  bool get isInvalid {
    final prediction = widget.entity.prediction.toLowerCase();
    return prediction == 'not x-ray' || prediction == 'invalid image';
  }

  Uint8List? _decodeBase64Image(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final payload = raw.contains(',') ? raw.split(',').last : raw;
      return base64Decode(payload);
    } catch (_) {
      return null;
    }
  }

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

  Widget _buildImagePreview() {
    final segmentedBytes = _segmentedBytes;
    final heatmapBytes = _heatmapBytes;

    final bytesToShow = switch (_effectiveImageMode) {
      _ImageMode.segmented => segmentedBytes,
      _ImageMode.heatmap => heatmapBytes,
      _ImageMode.original => null,
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: bytesToShow != null
          ? Image.memory(
              bytesToShow,
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
              progressIndicatorBuilder: (_, __, ___) => const SizedBox(
                height: 300,
                child: Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (_, __, ___) => const SizedBox(
                height: 300,
                child: Center(child: Icon(Icons.broken_image_outlined)),
              ),
            ),
    );
  }

  Widget _buildImageModeButton({
    required String label,
    required IconData icon,
    required _ImageMode mode,
  }) {
    final selected = _effectiveImageMode == mode;

    return OutlinedButton.icon(
      onPressed: () => setState(() => _imageMode = mode),
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: selected ? Colors.white : const Color(0xFF08325C),
        backgroundColor: selected ? const Color(0xFF08325C) : Colors.white,
        side: BorderSide(
          color: selected ? const Color(0xFF08325C) : Colors.grey.shade300,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildImageModeSelector() {
    final segmentedBytes = _segmentedBytes;
    final heatmapBytes = _heatmapBytes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildImageModeButton(
              label: 'Original X-ray',
              icon: Icons.image_outlined,
              mode: _ImageMode.original,
            ),
            if (segmentedBytes != null)
              _buildImageModeButton(
                label: 'Show Segmented Lungs',
                icon: Icons.air,
                mode: _ImageMode.segmented,
              ),
            if (heatmapBytes != null)
              _buildImageModeButton(
                label: 'Show AI Heatmap',
                icon: Icons.local_fire_department_outlined,
                mode: _ImageMode.heatmap,
              ),
          ],
        ),
        if (segmentedBytes == null && heatmapBytes == null) ...[
          const SizedBox(height: 8),
          Text(
            'AI overlay images are not available for this scan.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDisease = widget.entity.prediction.toLowerCase() != 'normal';
    final diagnosisColor = isDisease ? Colors.red[400] : Colors.green[400];

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Result'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImagePreview(),
            const SizedBox(height: 16),
            _buildImageModeSelector(),
            const SizedBox(height: 24),
            if (isInvalid)
              const Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 60,
                      color: Colors.red,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Invalid Image',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Please upload a valid chest X-ray image',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            if (!isInvalid) ...[
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
              const SizedBox(height: 8),
              LinearProgressIndicator(value: widget.entity.confidence / 100),
              const SizedBox(height: 20),
              const Text('Recommendation'),
              const SizedBox(height: 6),
              Text(widget.entity.description),
            ],
          ],
        ),
      ),
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
