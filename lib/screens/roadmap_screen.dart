import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';

class RoadmapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Learning Roadmap'),
      ),
      body: quizProvider.roadmap.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: quizProvider.roadmap.length,
        itemBuilder: (context, index) {
          final step = quizProvider.roadmap[index];
          return Card(
            child: ListTile(
              title: Text(step['step'] as String),
              subtitle: Text(step['description'] as String),
            ),
          );
        },
      ),
    );
  }
}
