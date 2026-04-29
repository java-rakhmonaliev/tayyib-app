import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/analysis_result.dart';

class ApiService {
  static const String baseUrl = 'http://13.217.178.63';

  static Future<AnalysisResult> analyzeText({
    required String ingredients,
    required String madhab,
    String productName = '',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/analyze/text/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'ingredients': ingredients,
        'madhab': madhab,
        'product_name': productName,
      }),
    );

    if (response.statusCode == 200) {
      return AnalysisResult.fromJson(jsonDecode(response.body));
    }
    throw Exception(jsonDecode(response.body)['error'] ?? 'Analysis failed');
  }

  static Future<AnalysisResult> analyzeBarcode({
    required String barcode,
    required String madhab,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/analyze/barcode/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'barcode': barcode,
        'madhab': madhab,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['product'] != null) {
        data['product']['barcode'] = barcode;
      }
      return AnalysisResult.fromJson(data);
    }
    throw Exception(jsonDecode(response.body)['error'] ?? 'Barcode lookup failed');
  }

  static Future<AnalysisResult> analyzeImage({
    required File image,
    required String madhab,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/analyze/image/'),
    );
    request.fields['madhab'] = madhab;
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return AnalysisResult.fromJson(jsonDecode(response.body));
    }
    throw Exception(jsonDecode(response.body)['error'] ?? 'Image analysis failed');
  }
}