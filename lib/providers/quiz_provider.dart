import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuizProvider with ChangeNotifier {
  String _difficulty = 'easy';
  List<Map<String, Object>> _questions = [];
  List<Map<String, Object>> _roadmap = [];
  int _currentQuestionIndex = 0;

  String get difficulty => _difficulty;
  List<Map<String, Object>> get questions => _questions;
  List<Map<String, Object>> get roadmap => _roadmap;

  int get currentQuestionIndex => _currentQuestionIndex;
  set currentQuestionIndex(int index) {
    _currentQuestionIndex = index;
    notifyListeners();
  }

  Future<void> fetchQuestions(String topic) async {
    _questions.clear();

    final url = Uri.parse('https://api-inference.huggingface.co/models/mistralai/Mixtral-8x7B-Instruct-v0.1');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer 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',
      },
      body: json.encode({
        'inputs': 'Generate per questions and its have to be about $topic with four multiple choice options and their correct answer. No explanation',
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('Response Data: $responseData');
      if (responseData != null && responseData is List) {

        _questions = responseData.expand((item) {
          final generatedText = item['generated_text'] as String;
          final parts = generatedText.split('\n').where((part) => part.trim().isNotEmpty).toList();

          final List<Map<String, Object>> questions = [];
          for (var i = 0; i < parts.length; i += 7) {
            if (i + 6 >= parts.length) break;

            final questionText = parts[i + 1].split(' - ').last.trim();
            final options = parts.sublist(i + 2, i + 6).map((option) {
              final optionParts = option.split(' - ');
              return optionParts.last.trim();
            }).toList();
            final correctAnswer = parts[i + 6].split(': ').last.trim();
            final id = UniqueKey().toString();

            questions.add({
              'id': id,
              'question': questionText,
              'options': options,
              'correctAnswer': correctAnswer,
            });
          }

          return questions;
        }).toList();
        _currentQuestionIndex = 0;

      }
    } else {
      print('Failed to load questions: ${response.statusCode}');
    }

    notifyListeners();
  }


  Future<void> evaluateResponses(List<Map<String, Object>> userResponses) async {
    final correctAnswers = userResponses.where((response) => response['correct'] as bool).length;
    if (correctAnswers >= 8) {
      _difficulty = 'advanced';
    } else if (correctAnswers >= 5) {
      _difficulty = 'intermediate';
    } else {
      _difficulty = 'beginner';
    }
    await fetchRoadmap();
    notifyListeners();
  }

  Future<void> fetchRoadmap() async {
    final url = Uri.parse('https://api-inference.huggingface.co/models/01-ai/Yi-1.5-34B-Chat');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer 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',
      },
      body: json.encode({
        'inputs': 'Generate a roadmap for learning at $_difficulty level.'
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('Response Data: $responseData');

      if (responseData != null && responseData is List) {
        _roadmap = responseData.map<Map<String, Object>>((choice) => {
          'step': choice['step'] ?? 'unknown',
          'description': choice['generated_text'] ?? '',
        }).toList();
      }
    } else {
      print('Failed to load roadmap: ${response.statusCode}');
    }

    notifyListeners();
  }

}
