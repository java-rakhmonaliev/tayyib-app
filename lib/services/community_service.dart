import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class CommunityScore {
  final String barcode;
  final String communityVerdict;
  final int totalVotes;
  final int confirmedHalalCount;
  final int foundIssueCount;
  final int notSureCount;

  CommunityScore({
    required this.barcode,
    required this.communityVerdict,
    required this.totalVotes,
    required this.confirmedHalalCount,
    required this.foundIssueCount,
    required this.notSureCount,
  });

  factory CommunityScore.fromJson(Map<String, dynamic> json) {
    return CommunityScore(
      barcode: json['barcode'] ?? '',
      communityVerdict: json['community_verdict'] ?? 'unverified',
      totalVotes: json['total_votes'] ?? 0,
      confirmedHalalCount: json['confirmed_halal_count'] ?? 0,
      foundIssueCount: json['found_issue_count'] ?? 0,
      notSureCount: json['not_sure_count'] ?? 0,
    );
  }
}

class CommunityService {
  static const String baseUrl = 'http://13.217.178.63';

  static Future<CommunityScore> getScore(String barcode) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/community/score/$barcode/'),
    );
    return CommunityScore.fromJson(jsonDecode(response.body));
  }

  static Future<String?> getMyVote(String barcode) async {
    final token = await AuthService.getAccessToken();
    if (token == null) return null;
    final response = await http.get(
      Uri.parse('$baseUrl/api/community/my-vote/$barcode/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = jsonDecode(response.body);
    return data['vote'];
  }

  static Future<void> submitVote({
    required String barcode,
    required String vote,
    required String madhab,
    String productName = '',
    String note = '',
  }) async {
    final token = await AuthService.getAccessToken();
    if (token == null) throw Exception('Not logged in.');
    final response = await http.post(
      Uri.parse('$baseUrl/api/community/report/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'barcode': barcode,
        'vote': vote,
        'product_name': productName,
        'madhab': madhab,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Vote failed.');
    }
  }
}