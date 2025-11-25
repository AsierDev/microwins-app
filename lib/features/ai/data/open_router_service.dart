import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../../habits/domain/entities/habit.dart';

class OpenRouterService {
  static const String _baseUrl =
      'https://openrouter.ai/api/v1/chat/completions';

  Future<List<Habit>> generateHabits(String goal) async {
    final apiKey = dotenv.env['OPENROUTER_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OPENROUTER_API_KEY not found in .env');
    }

    final prompt =
        '''
You are a habit formation expert. User goal: "$goal"

Generate 3 micro-routines (2-5 minutes each) that are:
1. Specific and actionable
2. Doable anywhere without equipment
3. Progressive in difficulty

Return ONLY valid JSON array with this structure:
[
  {
    "name": "string (max 50 chars)",
    "duration": 2,
    "steps": ["step 1", "step 2"],
    "category": "Health",
    "difficulty": "Beginner",
    "icon": "✅"
  }
]
Valid categories: Health, Productivity, Wellness, Learning, Fitness
''';

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://microwins.app',
          'X-Title': 'MicroWins',
        },
        body: jsonEncode({
          'model': 'google/gemini-2.5-flash-lite',
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return _parseHabits(content);
      } else {
        throw Exception(
          'Failed to generate habits: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error calling OpenRouter: $e');
    }
  }

  List<Habit> _parseHabits(String content) {
    try {
      // Clean up markdown code blocks if present
      final jsonString = content
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final List<dynamic> jsonList = jsonDecode(jsonString);

      return jsonList.map((json) {
        return Habit(
          id: const Uuid().v4(),
          name: json['name'],
          icon: json['icon'] ?? '✅',
          category: json['category'] ?? 'Wellness',
          durationMinutes: json['duration'] is int
              ? json['duration']
              : int.tryParse(json['duration'].toString()) ?? 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to parse AI response: $e');
    }
  }
}
