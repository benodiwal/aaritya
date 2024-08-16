import 'package:flutter/material.dart';

class QuizAttemptPage extends StatefulWidget {
  final Map<String, dynamic> quiz;

  const QuizAttemptPage({Key? key, required this.quiz}) : super(key: key);

  @override
  _QuizAttemptPageState createState() => _QuizAttemptPageState();
}

class _QuizAttemptPageState extends State<QuizAttemptPage> {
  int _currentQuestionIndex = 0;
  List<int?> _userAnswers = [];
  bool _quizCompleted = false;

  // Sample questions - replace with actual quiz questions
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is the capital of France?',
      'options': ['London', 'Berlin', 'Paris', 'Madrid'],
      'correctAnswer': 2,
    },
    {
      'question': 'Which planet is known as the Red Planet?',
      'options': ['Venus', 'Mars', 'Jupiter', 'Saturn'],
      'correctAnswer': 1,
    },
    {
      'question': 'Who painted the Mona Lisa?',
      'options': ['Van Gogh', 'Da Vinci', 'Picasso', 'Rembrandt'],
      'correctAnswer': 1,
    },
  ];

  @override
  void initState() {
    super.initState();
    _userAnswers = List.filled(_questions.length, null);
  }

  void _answerQuestion(int answerIndex) {
    setState(() {
      _userAnswers[_currentQuestionIndex] = answerIndex;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _completeQuiz();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _completeQuiz() {
    setState(() {
      _quizCompleted = true;
    });
  }

  int _calculateScore() {
    int score = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_userAnswers[i] == _questions[i]['correctAnswer']) {
        score++;
      }
    }
    return score;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz['title']),
      ),
      body: _quizCompleted ? _buildResultScreen() : _buildQuestionScreen(),
    );
  }

  Widget _buildQuestionScreen() {
    final question = _questions[_currentQuestionIndex];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 16),
          Text(
            question['question'],
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 24),
          ...(question['options'] as List<String>).asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ElevatedButton(
                onPressed: () => _answerQuestion(index),
                child: Text(option),
              ),
            );
          }).toList(),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentQuestionIndex > 0)
                ElevatedButton(
                  onPressed: _previousQuestion,
                  child: Text('Previous'),
                )
              else
                SizedBox(),
              ElevatedButton(
                onPressed: _userAnswers[_currentQuestionIndex] != null
                    ? _nextQuestion
                    : null,
                child: Text(_currentQuestionIndex == _questions.length - 1
                    ? 'Finish'
                    : 'Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    final score = _calculateScore();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Quiz Completed!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 16),
          Text(
            'Your Score: $score out of ${_questions.length}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Return to the previous screen
            },
            child: Text('Back to Quiz Feed'),
          ),
        ],
      ),
    );
  }
}
