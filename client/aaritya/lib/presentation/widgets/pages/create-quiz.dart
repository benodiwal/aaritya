import 'package:flutter/material.dart';
import 'package:aaritya/core/network/api_service.dart';

class CreateQuizPage extends StatefulWidget {
  @override
  _CreateQuizPageState createState() => _CreateQuizPageState();
}

class _CreateQuizPageState extends State<CreateQuizPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  String _quizTitle = '';
  String _quizDescription = '';
  int _timeLimit = 0;
  String _difficulty = 'Medium';
  List<String> _topics = [];
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = false;

  void _addQuestion() {
    setState(() {
      _questions.add({
        'text': '',
        'points': 1,
        'options': [
          {'optionText': '', 'isCorrect': false},
          {'optionText': '', 'isCorrect': false},
        ],
      });
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  void _addOption(int questionIndex) {
    setState(() {
      _questions[questionIndex]['options'].add({'optionText': '', 'isCorrect': false});
    });
  }

  void _removeOption(int questionIndex, int optionIndex) {
    setState(() {
      _questions[questionIndex]['options'].removeAt(optionIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Quiz')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16.0),
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Quiz Title'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                    onSaved: (value) => _quizTitle = value!,
                    initialValue: _quizTitle,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Quiz Description'),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                    onSaved: (value) => _quizDescription = value!,
                    initialValue: _quizDescription,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Time Limit (minutes)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a time limit';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                    onSaved: (value) => _timeLimit = int.parse(value!),
                    initialValue: _timeLimit.toString(),
                  ),
                  DropdownButtonFormField<String>(
                    value: _difficulty,
                    decoration: InputDecoration(labelText: 'Difficulty'),
                    items: ['Easy', 'Medium', 'Hard'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _difficulty = newValue!;
                      });
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Topics (comma-separated)'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter at least one topic';
                      }
                      return null;
                    },
                    onSaved: (value) => _topics = value!.split(',').map((e) => e.trim()).toList(),
                    initialValue: _topics.join(', '),
                  ),
                  SizedBox(height: 20),
                  _buildOpenAIGeneratorCard(),
                  SizedBox(height: 20),
                  Text('Questions', style: Theme.of(context).textTheme.headlineSmall),
                  ..._questions.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> question = entry.value;
                    return _buildQuestionCard(index, question);
                  }).toList(),
                  ElevatedButton(
                    onPressed: _addQuestion,
                    child: Text('Add Question'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveQuiz,
                    child: Text('Create Quiz'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildQuestionCard(int index, Map<String, dynamic> question) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Question ${index + 1}', style: Theme.of(context).textTheme.titleMedium),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _removeQuestion(index),
                ),
              ],
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Question Text'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a question';
                }
                return null;
              },
              onChanged: (value) => question['text'] = value,
              initialValue: question['text'],
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Points'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter points';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
              onChanged: (value) => question['points'] = int.tryParse(value) ?? 1,
              initialValue: question['points'].toString(),
            ),
            SizedBox(height: 10),
            Text('Options', style: Theme.of(context).textTheme.titleMedium),
            ...(question['options'] as List<Map<String, dynamic>>).asMap().entries.map((optionEntry) {
              int optionIndex = optionEntry.key;
              Map<String, dynamic> option = optionEntry.value;
              return _buildOptionRow(index, optionIndex, option);
            }).toList(),
            ElevatedButton(
              onPressed: () => _addOption(index),
              child: Text('Add Option'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionRow(int questionIndex, int optionIndex, Map<String, dynamic> option) {
    return Row(
      children: [
        Checkbox(
          value: option['isCorrect'],
          onChanged: (bool? value) {
            setState(() {
              option['isCorrect'] = value ?? false;
            });
          },
        ),
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(labelText: 'Option ${optionIndex + 1}'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an option';
              }
              return null;
            },
            onChanged: (value) => option['optionText'] = value,
            initialValue: option['optionText'],
          ),
        ),
        IconButton(
          icon: Icon(Icons.remove_circle),
          onPressed: () => _removeOption(questionIndex, optionIndex),
        ),
      ],
    );
  }

  void _saveQuiz() async {
    _formKey.currentState!.save();

    if (_formKey.currentState!.validate()) {
      if (_questions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please add at least one question')),
        );
        return;
      }
      
      for (var question in _questions) {
        if (question['options'].length < 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Each question must have at least two options')),
          );
          return;
        }
        if (!question['options'].any((option) => option['isCorrect'])) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Each question must have at least one correct answer')),
          );
          return;
        }
      }

      setState(() => _isLoading = true);

      Map<String, dynamic> quizData = {
        'title': _quizTitle,
        'description': _quizDescription,
        'timeLimit': _timeLimit,
        'difficulty': _difficulty,
        'topics': _topics,
        'questions': _questions.map((q) => {
          'text': q['text'],
          'points': q['points'],
          'options': q['options'].map((o) => {
            'optionText': o['optionText'],
            'isCorrect': o['isCorrect'],
          }).toList(),
        }).toList(),
      };

      print('Quiz Data: $quizData');

      try {
        await _apiService.createQuiz(quizData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Quiz created successfully')),
        );
      } catch (e) {
        print('Error creating quiz: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create quiz: ${e.toString()}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      print('Form validation failed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields')),
      );
    }
  }
}

Widget _buildOpenAIGeneratorCard() {
  return LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      final isSmallScreen = constraints.maxWidth < 600;

      return Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.purple.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: isSmallScreen ? 24 : 30),
                    SizedBox(width: isSmallScreen ? 8 : 10),
                    Expanded(
                      child: Text(
                        'Generate Questions using OpenAI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 8 : 10),
                Text(
                  'Coming Soon!',
                  style: TextStyle(
                    color: Colors.yellow,
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 8 : 10),
                Text(
                  'Automatically generate quiz questions using advanced AI technology.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
