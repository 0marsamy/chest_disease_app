import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chest_disease_app/core/components/widgets/custom_button.dart';
import 'package:chest_disease_app/core/data/network_services/api_service.dart';
import 'package:chest_disease_app/core/helper/functions/diagnosis_label_formatter.dart';
import 'package:chest_disease_app/core/utils/theme/colors/app_colors.dart';
import 'package:chest_disease_app/features/chats/presentation/view/screen/chat_list_screen.dart';
import 'package:chest_disease_app/features/scan/domain/entities/chest_prediction_entity.dart';
import 'package:chest_disease_app/foundations/app_urls.dart';
import 'package:chest_disease_app/generated/l10n.dart';
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

  String get _diagnosisLabel =>
      formatDiagnosisLabel(widget.entity.prediction, context: context);

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
      final predictionSlug = _diagnosisLabel.replaceAll(' ', '_');
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
          SnackBar(content: Text(S.of(context).reportSavedToDevice)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.of(context).failedToSaveReport} $e')),
        );
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
    final previewHeight = MediaQuery.sizeOf(context).height < 720
        ? 300.0
        : 350.0;

    final bytesToShow = switch (_effectiveImageMode) {
      _ImageMode.segmented => segmentedBytes,
      _ImageMode.heatmap => heatmapBytes,
      _ImageMode.original => null,
    };

    return Container(
      height: previewHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: bytesToShow != null
            ? Image.memory(
                bytesToShow,
                height: previewHeight,
                width: double.infinity,
                fit: BoxFit.contain,
              )
            : widget.originalImage != null
            ? Image.file(
                widget.originalImage!,
                height: previewHeight,
                width: double.infinity,
                fit: BoxFit.contain,
              )
            : CachedNetworkImage(
                imageUrl: widget.imageUrl!,
                height: previewHeight,
                width: double.infinity,
                fit: BoxFit.contain,
                progressIndicatorBuilder: (_, __, ___) => const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => const SizedBox(
                  height: 300,
                  child: Center(child: Icon(Icons.broken_image_outlined)),
                ),
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
              label: S.of(context).originalXray,
              icon: Icons.image_outlined,
              mode: _ImageMode.original,
            ),
            if (segmentedBytes != null)
              _buildImageModeButton(
                label: S.of(context).showSegmentedLungs,
                icon: Icons.air,
                mode: _ImageMode.segmented,
              ),
            if (heatmapBytes != null)
              _buildImageModeButton(
                label: S.of(context).showAiHeatmap,
                icon: Icons.local_fire_department_outlined,
                mode: _ImageMode.heatmap,
              ),
          ],
        ),
        if (segmentedBytes == null && heatmapBytes == null) ...[
          const SizedBox(height: 8),
          Text(
            S.of(context).aiOverlayNotAvailable,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ],
    );
  }

  Widget _buildHeatmapLegend() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2EDF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).heatmapColorLegend,
            style: TextStyle(
              color: AppColors.buttonsAndNav,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10),
          _LegendRow(color: Color(0xFFB00020), text: S.of(context).heatmapRed),
          SizedBox(height: 8),
          _LegendRow(
            color: Color(0xFFE6C229),
            text: S.of(context).heatmapYellow,
          ),
          SizedBox(height: 8),
          _LegendRow(color: Color(0xFF2F80ED), text: S.of(context).heatmapBlue),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDisease = widget.entity.prediction.toLowerCase() != 'normal';
    final diagnosisColor = isDisease ? Colors.red[400] : Colors.green[400];
    final confidenceProgress = (widget.entity.confidence / 100).clamp(0.0, 1.0);
    final confidence = widget.entity.confidence;
    final prediction = widget.entity.prediction.toLowerCase();

    // Check confidence levels
    final bool isHighConfidence = confidence >= 80.0;
    final bool isMediumConfidence = confidence >= 60.0 && confidence < 80.0;
    final bool isLowConfidence = confidence < 60.0;

    // Determine if heatmap should be shown:
    // - SHOW heatmap for confidence FROM 60% TO 100% (>= 60.0)
    // - EXCEPT when prediction is exactly 'Normal'
    // - This matches your exact requirement: heatmap shows from 60 to 100, but normal never shows it
    final bool showHeatmap = confidence >= 60.0 && prediction != 'normal';

    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).scanResult), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImagePreview(),
            const SizedBox(height: 16),
            _buildImageModeSelector(),
            if (_effectiveImageMode == _ImageMode.heatmap && showHeatmap) ...[
              const SizedBox(height: 16),
              _buildHeatmapLegend(),
            ],
            const SizedBox(height: 24),
            if (isInvalid)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 60,
                      color: Colors.red,
                    ),
                    SizedBox(height: 10),
                    Text(
                      S.of(context).invalidImage,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      S.of(context).uploadValidXray,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            if (!isInvalid) ...[
              if (isLowConfidence)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade100,
                    border: Border.all(color: Colors.yellow.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 48,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        S.of(context).unreliablePrediction,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        S.of(context).imageUnclear,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              if (!isLowConfidence) ...[
                Card(
                  color: diagnosisColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).diagnosis,
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        Text(
                          _diagnosisLabel,
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
                  '${S.of(context).confidence} ${widget.entity.confidence.toStringAsFixed(1)}%',
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: confidenceProgress),
              ],
              if (isMediumConfidence)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    border: Border.all(color: Colors.orange.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          S.of(context).lowConfidenceWarning,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.orange,
                          ),
                          overflow: TextOverflow.visible,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                ),
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
                text: S.of(context).saveReport,
                isLoading: _isSaving,
                onTap: _saveReport,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CustomButton(
                text: S.of(context).chatWithMedical,
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

class _LegendRow extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendRow({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF455A64),
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
