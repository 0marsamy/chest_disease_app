import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:chest_disease_app/foundations/app_constants.dart';

/// Wrapper for the Google Gemini generative text API.
///
/// Uses the current generateContent endpoint and request/response format.
/// API key is passed as query param. Do not hardcode keys in production.
class GemiaiService {
  GemiaiService();

  /// gemini-1.5-flash deprecated; use gemini-2.5-flash.
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  /// Extracts plain text from various Gemini response shapes.
  /// Returns null if parsing fails (avoids showing raw JSON to users).
  static String? _extractText(dynamic data) {
    if (data is! Map<String, dynamic>) return null;

    final candidates = data['candidates'];
    if (candidates is! List || candidates.isEmpty) return null;

    final first = candidates.first;
    if (first is! Map<String, dynamic>) return null;

    final content = first['content'];
    if (content == null) return null;

    List<dynamic>? parts;
    if (content is Map<String, dynamic>) {
      parts = content['parts'] as List<dynamic>?;
    } else if (content is List && content.isNotEmpty) {
      final firstContent = content.first;
      if (firstContent is Map<String, dynamic>) {
        parts = firstContent['parts'] as List<dynamic>?;
      }
    }

    if (parts == null || parts.isEmpty) return null;
    final firstPart = parts.first;
    if (firstPart is! Map<String, dynamic>) return null;

    final text = firstPart['text'];
    return text is String ? text : null;
  }

  /// Generates a response for [prompt] using Gemini generateContent.
  /// If [imageFile] is provided (jpg/png), Gemini can analyze the image.
  ///
  /// Request: contents → parts → text, and optionally inline_data for images.
  /// Response: candidates[0].content.parts[0].text
  Future<String> generateText(String prompt, {File? imageFile}) async {
    final url = '$_baseUrl?key=${AppConstants.gemiaiApiKey}';

    final parts = <Map<String, dynamic>>[];
    if (prompt.isNotEmpty) {
      parts.add({'text': prompt});
    }

    // Add image as inline_data when supported (jpg, jpeg, png)
    if (imageFile != null && await imageFile.exists()) {
      final ext = imageFile.path.toLowerCase().split('.').last;
      final mimeTypes = ['jpg', 'jpeg', 'png'];
      if (mimeTypes.contains(ext)) {
        final bytes = await imageFile.readAsBytes();
        final base64 = base64Encode(bytes);
        final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
        parts.add({
          'inlineData': {'mimeType': mime, 'data': base64},
        });
        if (kDebugMode) {
          debugPrint('GemiaiService: including image ${imageFile.path} ($mime)');
        }
      }
    }

    if (parts.isEmpty) {
      return "Please type a message or attach an image (jpg/png) to analyze.";
    }

    final body = {
      'contents': [
        {'parts': parts},
      ],
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 4096,
      },
    };

    if (kDebugMode) {
      debugPrint('GemiaiService: POST $url');
      debugPrint('GemiaiService: prompt length=${prompt.length}, hasImage=${imageFile != null}');
    }

    try {
      // Use plain Dio as per Gemini API docs – key in URL, body as Map
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ));
      final response = await dio.post(
        url,
        data: body,
        options: Options(
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
        ),
      );

      final status = response.statusCode ?? 0;
      final data = response.data;

      if (kDebugMode) {
        debugPrint('GemiaiService: status=$status');
        if (data is Map) {
          debugPrint('GemiaiService: keys=${data.keys.toList()}');
        }
      }

      if (status >= 200 && status < 300) {
        final text = _extractText(data);
        if (text != null && text.isNotEmpty) {
          return text.trim();
        }
        debugPrint('GemiaiService: failed to extract text, raw=$data');
        return "I received a response I couldn't parse. Please try again.";
      }

      final errorDetail = data is Map ? (data['error'] ?? data) : data;
      throw Exception('Gemini API error ($status): $errorDetail');
    } on DioException catch (e, st) {
      final status = e.response?.statusCode;
      final errData = e.response?.data;
      debugPrint('GemiaiService DioException: status=$status, body=$errData');
      debugPrintStack(label: 'GemiaiService', stackTrace: st);

      if (status == 429) {
        throw Exception(
          'Rate limit reached. Please try again in a minute. '
          'If you\'re on the free tier, you may have hit the daily limit—try again tomorrow.',
        );
      }
      throw Exception(
        status != null
            ? 'Gemini API error ($status): ${errData ?? e.message}'
            : 'Network error: ${e.message}',
      );
    } on Exception catch (e, st) {
      debugPrint('GemiaiService error: $e');
      debugPrintStack(label: 'GemiaiService', stackTrace: st);
      rethrow;
    }
  }
}
