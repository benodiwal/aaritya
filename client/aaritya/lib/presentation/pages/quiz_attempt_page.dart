import 'package:aaritya/core/network/api_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class QuizAttemptPage extends StatefulWidget {
  final Map<String, dynamic> quiz;

  const QuizAttemptPage({Key? key, required this.quiz}) : super(key: key);

  @override
  _QuizAttemptPageState createState() => _QuizAttemptPageState();
}

class _QuizAttemptPageState extends State<QuizAttemptPage> {
  final ApiService _apiService = ApiService();
  int _currentQuestionIndex = 0;
  List<int?> _userAnswers = [];
  bool _quizCompleted = false;
  Timer? _timer;
  int _timeRemaining = 0;
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQuizQuestions();
  }

  Future<void> _loadQuizQuestions() async {
    try {
      final quizData = await _apiService.getQuizById(widget.quiz['id']);
      setState(() {
        _questions = List<Map<String, dynamic>>.from(quizData['questions']);
        _userAnswers = List.filled(_questions.length, null);
        _timeRemaining = _parseTimeLimit(quizData['timeLimit']);
        _isLoading = false;
      });
      startTimer();
    } catch (e) {
      setState(() {
        _error = 'Failed to load quiz questions: $e';
        _isLoading = false;
      });
    }
  }

  int _parseTimeLimit(dynamic timeLimit) {
    if (timeLimit is int) {
      return timeLimit * 60; // Convert minutes to seconds
    } else if (timeLimit is String) {
      final RegExp regex = RegExp(r'(\d+)');
      final match = regex.firstMatch(timeLimit);
      if (match != null) {
        return int.parse(match.group(1)!) * 60; // Convert minutes to seconds
      }
    }
    return 600; // Default to 10 minutes if parsing fails
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_timeRemaining == 0) {
          setState(() {
            timer.cancel();
            _completeQuiz();
          });
        } else {
          setState(() {
            _timeRemaining--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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

  Future<void> _completeQuiz() async {
    _timer?.cancel();
    setState(() {
      _isLoading = true;
      _quizCompleted = true;
    });

    try {
      await _apiService.submitQuizAttempt(
        widget.quiz['id'],
        _userAnswers.asMap().entries.map((entry) {
          return {
            'questionId': _questions[entry.key]['id'],
            'answerId': entry.value,
          };
        }).toList(),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to submit quiz attempt: $e';
        _isLoading = false;
      });
    }
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

  String _formatTime(int timeInSeconds) {
    int minutes = timeInSeconds ~/ 60;
    int seconds = timeInSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz['title'] ?? 'Quiz'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                _formatTime(_timeRemaining),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _quizCompleted
                  ? _buildResultScreen()
                  : _buildQuestionScreen(),
    );
  }

  Widget _buildQuestionScreen() {
    if (_currentQuestionIndex >= _questions.length) {
      return Center(child: Text('No more questions available'));
    }

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
            question['text'] as String? ?? 'No question available',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 24),
          ...(question['options'] as List<dynamic>? ?? []).asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ElevatedButton(
                onPressed: () => _answerQuestion(index),
                child: Text(option['text'] ?? ''),
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
    final totalTime = _parseTimeLimit(widget.quiz['timeLimit']);
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
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          Text(
            'Time taken: ${_formatTime(totalTime - _timeRemaining)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Back to Quiz Feed'),
          ),
        ],
      ),
    );
  }
}
