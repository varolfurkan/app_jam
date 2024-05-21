import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import 'roadmap_screen.dart';

class QuizScreen extends StatefulWidget {
  final String topic;

  QuizScreen({required this.topic});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool _quizStarted = false;
  List<Map<String, Object>> _userResponses = [];

  void _startQuiz() {
    setState(() {
      _quizStarted = true;
    });
    Provider.of<QuizProvider>(context, listen: false).fetchQuestions(widget.topic);
  }

  void _submitQuiz() {
    Provider.of<QuizProvider>(context, listen: false).evaluateResponses(_userResponses).then((_) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RoadmapScreen()),
      );
    });
  }

  void _nextQuestion() {
    var quizProvider = Provider.of<QuizProvider>(context, listen: false);
    setState(() {
      if (quizProvider.currentQuestionIndex < quizProvider.questions.length - 1) {
        // Mevcut sorunun index'ini arttır
        quizProvider.currentQuestionIndex++;
      } else {
        // Eğer mevcut soru dizisinin sınırlarını aştıysak, yeni soruları getir
        quizProvider.fetchQuestions(widget.topic);
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.topic} Quiz'),
      ),
      body: _quizStarted
          ? quizProvider.questions.isEmpty
          ? Center(child: CircularProgressIndicator())
          : _buildQuestionView(quizProvider)
          : Center(
        child: ElevatedButton(
          onPressed: _startQuiz,
          child: Text('Start Quiz to see your level'),
        ),
      ),
    );
  }

  Widget _buildQuestionView(QuizProvider quizProvider) {
    final question = quizProvider.questions[quizProvider.currentQuestionIndex];
    final options = question['options'] as List<String>?;

    if (options == null || options.isEmpty) {
      return Center(
        child: Text('Question options are missing.'),
      );
    }

    return Column(
      children: [
        Text(
          question['question'] as String,
          style: TextStyle(fontSize: 18),
        ),
        ...options.map((option) {
          final isSelected = _userResponses.length > quizProvider.currentQuestionIndex &&
              _userResponses[quizProvider.currentQuestionIndex]['selected'] == option;

          return GestureDetector(
            onTap: () {
              setState(() {
                if (_userResponses.length > quizProvider.currentQuestionIndex) {
                  _userResponses[quizProvider.currentQuestionIndex]['selected'] = option;
                  _userResponses[quizProvider.currentQuestionIndex]['correct'] = option == question['correctAnswer'];
                } else {
                  _userResponses.add({
                    'selected': option,
                    'correct': option == question['correctAnswer'],
                  });
                }
              });
            },
            child: Container(
              padding: EdgeInsets.all(8.0),
              margin: EdgeInsets.symmetric(vertical: 4.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(option),
            ),
          );
        }).toList(),
        SizedBox(height: 20.0),
        ElevatedButton(
          onPressed: _nextQuestion,
          child: Text('Next'),
        ),
      ],
    );
  }
}
