import 'package:chest_disease_app/generated/l10n.dart';
import 'package:flutter/material.dart';

String normalizeDiagnosisTerms(String value) {
  var normalized = value.replaceAllMapped(
    RegExp(r'\bcovid(?:[-\s]?19)?\b|\bcoronavirus\b', caseSensitive: false),
    (_) => 'COVID-19',
  );
  normalized = normalized.replaceAllMapped(
    RegExp(r'\btuberculosis\b', caseSensitive: false),
    (_) => 'Lung Cancer',
  );
  return normalized;
}

String formatDiagnosisLabel(String? value, {BuildContext? context}) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return text;

  final compactText = text.toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '');

  // If context is provided, use localized strings
  if (context != null) {
    final s = S.of(context);
    if (compactText == 'normal') {
      return s.normal;
    }
    if (compactText == 'covid' ||
        compactText == 'covid19' ||
        compactText == 'coronavirus') {
      return s.covid19;
    }
    if (compactText == 'pneumonia') {
      return s.pneumonia;
    }
    if (compactText == 'lungcancer' || compactText == 'tuberculosis') {
      return s.lungCancer;
    }
  }

  // Fallback to English if no context
  if (compactText == 'covid' ||
      compactText == 'covid19' ||
      compactText == 'coronavirus') {
    return 'COVID-19';
  }

  return normalizeDiagnosisTerms(text);
}

String cleanMedicalAssistantText(String value) {
  var text = normalizeDiagnosisTerms(value.trim());
  text = text.replaceAll(RegExp(r'[`*_#>{}\[\]]'), '');
  text = text.replaceAll(RegExp(r'^\s*[-•]\s+', multiLine: true), '');
  text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  text = text.replaceAll(RegExp(r'[ \t]+'), ' ');
  return text.trim();
}
