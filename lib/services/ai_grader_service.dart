import 'dart:convert';
import 'package:http/http.dart' as http;

class AiGraderService {
  final String endpoint; // contoh: http://127.0.0.1:54321/functions/v1/grade-essay
  AiGraderService(this.endpoint);

  Future<Map<String, dynamic>> grade({
    required String problemText,
    required String studentAnswer,
    List<String>? criteria,
  }) async {
    final res = await http.post(
      Uri.parse(endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'problem_text': problemText,
        'student_answer': studentAnswer,
        'rubric': {
          'criteria': criteria ?? [
            "Rumus benar",
            "Substitusi benar",
            "Perhitungan benar"
          ]
        },
      }),
    );
    if (res.statusCode != 200) {
      throw Exception('Grading failed: ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
