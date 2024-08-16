import 'package:aaritya/presentation/pages/quiz_attempt_page.dart';
import 'package:flutter/material.dart';

class QuizFeedPage extends StatelessWidget {
  final List<Map<String, dynamic>> quizzes = [
    {
      'title': 'Science Trivia',
      'creator': 'John Doe',
      'difficulty': 'Medium',
      'questionCount': 10,
      'timeLimit': '15 min',
      'attempts': 150,
    },
    {
      'title': 'History Quiz',
      'creator': 'Jane Smith',
      'difficulty': 'Hard',
      'questionCount': 15,
      'timeLimit': '20 min',
      'attempts': 89,
    },
    {
      'title': 'Pop Culture Mania',
      'creator': 'Alex Johnson',
      'difficulty': 'Easy',
      'questionCount': 20,
      'timeLimit': '25 min',
      'attempts': 275,
    },
    // Add more quiz data as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Feed'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: quizzes.length,
        itemBuilder: (context, index) {
          final quiz = quizzes[index];
          return QuizCard(quiz: quiz);
        },
      ),
    );
  }
}

class QuizCard extends StatelessWidget {
  final Map<String, dynamic> quiz;

  const QuizCard({Key? key, required this.quiz}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quiz['title'],
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, size: 16),
                SizedBox(width: 4),
                Text(quiz['creator']),
                Spacer(),
                _buildDifficultyChip(quiz['difficulty']),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.question_answer, size: 16),
                SizedBox(width: 4),
                Text('${quiz['questionCount']} questions'),
                Spacer(),
                Icon(Icons.timer, size: 16),
                SizedBox(width: 4),
                Text(quiz['timeLimit']),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.people, size: 16),
                SizedBox(width: 4),
                Text('${quiz['attempts']} attempts'),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => QuizAttemptPage(quiz: quiz),
                  ),
                );
              },
              child: Text('Start Quiz'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 36),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(String difficulty) {
    Color color;
    switch (difficulty.toLowerCase()) {
      case 'easy':
        color = Colors.green;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      case 'hard':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        difficulty,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }
}
