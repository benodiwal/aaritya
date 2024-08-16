import 'package:aaritya/core/network/api_service.dart';
import 'package:flutter/material.dart';

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
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = false;

  void _addQuestion() {
    setState(() {
      _questions.add({
        'question': '',
        'options': ['', '', '', ''],
        'correctAnswer': 0,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Quiz'),
      ),
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
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Quiz Description'),
                    maxLines: 3,
                    onSaved: (value) => _quizDescription = value!,
                  ),
                  SizedBox(height: 16),
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
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Questions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  ..._questions.asMap().entries.map((entry) {
                    int idx = entry.key;
                    Map<String, dynamic> question = entry.value;
                    return Card(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              decoration: InputDecoration(labelText: 'Question ${idx + 1}'),
                              onChanged: (value) => question['question'] = value,
                            ),
                            ...List.generate(4, (optionIdx) {
                              return Row(
                                children: [
                                  Radio<int>(
                                    value: optionIdx,
                                    groupValue: question['correctAnswer'],
                                    onChanged: (value) {
                                      setState(() {
                                        question['correctAnswer'] = value;
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      decoration: InputDecoration(labelText: 'Option ${optionIdx + 1}'),
                                      onChanged: (value) => question['options'][optionIdx] = value,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addQuestion,
                    child: Text('Add Question'),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        _saveQuiz();
                      }
                    },
                    child: Text('Create Quiz'),
                  ),
                ],
              ),
            ),
    );
  }

  void _saveQuiz() async {
    setState(() => _isLoading = true);

    Map<String, dynamic> quizData = {
      'title': _quizTitle,
      'description': _quizDescription,
      'timeLimit': _timeLimit,
      'questions': _questions.map((q) => {
        'text': q['question'],
        'options': q['options'].map((option) => {'text': option}).toList(),
        'correctAnswer': q['correctAnswer'],
      }).toList(),
    };

    try {
      await _apiService.createQuiz(quizData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quiz created successfully')),
      );
      Navigator.of(context).pop(); // Return to previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create quiz: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
