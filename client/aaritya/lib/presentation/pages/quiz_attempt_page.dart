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
      final quizData = await _apiService.getQuizById(widget.quiz['ID'].toString());
      setState(() {
          _questions = List<Map<String, dynamic>>.from(quizData['Questions']);
        _userAnswers = List.filled(_questions.length, null);
        _timeRemaining =
            quizData['TimeLimit'] * 60;
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
      final answers = _userAnswers
          .asMap()
          .entries
          .map((entry) {
            final questionIndex = entry.key;
            final answerIndex = entry.value;
            if (answerIndex != null) {
              return {
                'questionId': _questions[questionIndex]['ID'],
                'optionId': _questions[questionIndex]['Options'][answerIndex]
                    ['ID'],
              };
            }
            return null;
          })
          .where((answer) => answer != null)
          .toList()
          .cast<Map<String, dynamic>>();

      final success = await _apiService.submitQuizAttempt(
        widget.quiz['ID'],
        answers,
      );

      setState(() {
        _isLoading = false;
        if (success) {
        } else {
          _error = 'Failed to submit quiz attempt';
        }
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
      if (_userAnswers[i] != null &&
          _questions[i]['Options'][_userAnswers[i]!]['IsCorrect']) {
          score += (_questions[i]['Points'] as num).toInt();
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
        title: Text(widget.quiz['Title'] ?? 'Quiz'),
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
      return const Center(child: Text('No more questions available'));
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
          const SizedBox(height: 16),
          Text(
            question['QuestionText'] as String? ?? 'No question available',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          ...(question['Options'] as List<dynamic>? ?? [])
              .asMap()
              .entries
              .map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = _userAnswers[_currentQuestionIndex] == index;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ElevatedButton(
                onPressed: () => _answerQuestion(index),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    isSelected ? Colors.blue : null,
                  ),
                  foregroundColor: MaterialStateProperty.all(
                    isSelected ? Colors.white : null,
                  ),
                ),
                child: Text(option['OptionText'] ?? ''),
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
                onPressed: _nextQuestion,
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
    final totalPoints = widget.quiz['TotalPoints'];
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
            'Your Score: $score out of $totalPoints',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          Text(
            'Time taken: ${_formatTime(widget.quiz['TimeLimit'] * 60 - _timeRemaining)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _error!,
                style: TextStyle(color: Colors.red),
              ),
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
