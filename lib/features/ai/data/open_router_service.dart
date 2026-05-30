import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../../habits/domain/entities/habit.dart';

class OpenRouterService {
  static const String _proxyUrl = String.fromEnvironment('AI_PROXY_URL');

  Future<List<Habit>> generateHabits(String goal) async {
    if (_proxyUrl.isEmpty) {
      throw Exception(
        'AI service is not configured. Provide AI_PROXY_URL via --dart-define.',
      );
    }

    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      final baseUrl = _proxyUrl.endsWith('/')
          ? _proxyUrl.substring(0, _proxyUrl.length - 1)
          : _proxyUrl;
      final endpoint = Uri.parse('$baseUrl/ai/habits');
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        endpoint,
        headers: headers,
        body: jsonEncode({'goal': goal}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List<dynamic>) {
          return _parseHabits(data);
        }
        if (data is Map<String, dynamic> && data['habits'] is List<dynamic>) {
          return _parseHabits(data['habits'] as List<dynamic>);
        }
        throw Exception('Invalid AI response format');
      }

      throw Exception(
        'Failed to generate habits: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      throw Exception('Error calling AI backend: $e');
    }
  }

  List<Habit> _parseHabits(List<dynamic> jsonList) {
    try {
      return jsonList.map((json) {
        final item = json as Map<String, dynamic>;
        return Habit(
          id: const Uuid().v4(),
          name: item['name'] as String,
          icon: (item['icon'] as String?) ?? '✅',
          category: (item['category'] as String?) ?? 'Wellness',
          durationMinutes: item['duration'] is int
              ? item['duration'] as int
              : int.tryParse(item['duration'].toString()) ?? 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to parse AI response: $e');
    }
  }
}
