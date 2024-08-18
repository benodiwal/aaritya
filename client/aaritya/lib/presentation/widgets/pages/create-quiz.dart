import 'package:flutter/material.dart';
import 'package:aaritya/core/network/api_service.dart';

class CreateQuizPage extends StatefulWidget {
  @override
  _CreateQuizPageState createState() => _CreateQuizPageState();
}

class _CreateQuizPageState extends State<CreateQuizPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _timeLimitController = TextEditingController();
  final TextEditingController _topicsController = TextEditingController();

  String _difficulty = 'Medium';
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timeLimitController.dispose();
    _topicsController.dispose();
    super.dispose();
  }

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
                  _buildQuizInfoFields(),
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

  Widget _buildQuizInfoFields() {
    return Column(
      children: [
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(labelText: 'Quiz Title'),
          validator: (value) => value?.isEmpty ?? true ? 'Please enter a title' : null,
        ),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(labelText: 'Quiz Description'),
          maxLines: 3,
          validator: (value) => value?.isEmpty ?? true ? 'Please enter a description' : null,
        ),
        TextFormField(
          controller: _timeLimitController,
          decoration: InputDecoration(labelText: 'Time Limit (minutes)'),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Please enter a time limit';
            if (int.tryParse(value!) == null) return 'Please enter a valid number';
            return null;
          },
        ),
        DropdownButtonFormField<String>(
          value: _difficulty,
          decoration: InputDecoration(labelText: 'Difficulty'),
          items: ['Easy', 'Medium', 'Hard'].map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() => _difficulty = newValue);
            }
          },
          validator: (value) => value == null ? 'Please select a difficulty' : null,
        ),
        TextFormField(
          controller: _topicsController,
          decoration: InputDecoration(labelText: 'Topics (comma-separated)'),
          validator: (value) => value?.isEmpty ?? true ? 'Please enter at least one topic' : null,
        ),
      ],
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
                Expanded(child: Text('Question ${index + 1}', style: Theme.of(context).textTheme.titleMedium)),
                IconButton(icon: Icon(Icons.delete), onPressed: () => _removeQuestion(index)),
              ],
            ),
            TextFormField(
              initialValue: question['text'] as String,
              decoration: InputDecoration(labelText: 'Question Text'),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter a question' : null,
              onChanged: (value) => question['text'] = value,
            ),
            TextFormField(
              initialValue: (question['points'] as int).toString(),
              decoration: InputDecoration(labelText: 'Points'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter points';
                if (int.tryParse(value!) == null) return 'Please enter a valid number';
                return null;
              },
              onChanged: (value) => question['points'] = int.tryParse(value) ?? 1,
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
          value: option['isCorrect'] as bool,
          onChanged: (bool? value) {
            setState(() => option['isCorrect'] = value ?? false);
          },
        ),
        Expanded(
          child: TextFormField(
            initialValue: option['optionText'] as String,
            decoration: InputDecoration(labelText: 'Option ${optionIndex + 1}'),
            validator: (value) => value?.isEmpty ?? true ? 'Please enter an option' : null,
            onChanged: (value) => option['optionText'] = value,
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
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill in all required fields')));
      return;
    }

    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please add at least one question')));
      return;
    }

    for (var question in _questions) {
      if ((question['options'] as List).length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Each question must have at least two options')));
        return;
      }
      if (!(question['options'] as List).any((option) => option['isCorrect'] == true)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Each question must have at least one correct answer')));
        return;
      }
    }

    setState(() => _isLoading = true);
    print('Number of questions: ${_questions.length}');
    print('Difficulty: $_difficulty');

    Map<String, dynamic> quizData = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'timeLimit': int.tryParse(_timeLimitController.text) ?? 0,
      'difficulty': _difficulty,
      'topics': _topicsController.text.split(',').map((e) => e.trim()).toList(),
      'questions': _questions.map((q) => {
        'text': q['text'] as String,
        'points': q['points'] as int,
        'options': (q['options'] as List).map((o) => {
          'optionText': o['optionText'] as String,
          'isCorrect': o['isCorrect'] as bool,
        }).toList(),
      }).toList(),
    };

    try {
      bool success = await _apiService.createQuiz(quizData);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Quiz created successfully')));
        _resetForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create quiz. Please try again.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error creating quiz: ${e.toString()}')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    setState(() {
      _titleController.clear();
      _descriptionController.clear();
      _timeLimitController.clear();
      _topicsController.clear();
      _difficulty = 'Medium';
      _questions.clear();
    });
    _formKey.currentState!.reset();
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
