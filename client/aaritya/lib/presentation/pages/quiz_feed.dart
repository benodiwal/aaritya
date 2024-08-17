import 'package:flutter/material.dart';
import 'package:aaritya/core/network/api_service.dart';
import 'package:aaritya/presentation/pages/quiz_attempt_page.dart';

class QuizFeedPage extends StatefulWidget {
  @override
  _QuizFeedPageState createState() => _QuizFeedPageState();
}

class _QuizFeedPageState extends State<QuizFeedPage> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _quizzes = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  int _page = 1;
  bool _hasMore = true;
  int _pageSize = 10;
  int _totalQuizzes = 0;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadQuizzes();
    }
  }

  Future<void> _loadQuizzes() async {
  if (_isLoading || !_hasMore) return;

  setState(() {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
  });

  try {
    print('Attempting to load quizzes: page $_page, pageSize $_pageSize');
    final response = await _apiService.getQuizzes(page: _page, pageSize: _pageSize);
    final newQuizzes = List<Map<String, dynamic>>.from(response['quizzes']);
    print('Received ${newQuizzes.length} quizzes');

    setState(() {
      _quizzes.addAll(newQuizzes);
      _isLoading = false;
      _page++;
      _totalQuizzes = response['total'];
      _hasMore = _quizzes.length < _totalQuizzes;
    });
  } catch (e) {
    print('Error loading quizzes: $e');
    setState(() {
      _isLoading = false;
      _hasError = true;
      _errorMessage = e.toString();
    });
  }
}

  Future<void> _refreshQuizzes() async {
    setState(() {
      _quizzes.clear();
      _page = 1;
      _hasMore = true;
      _hasError = false;
      _errorMessage = null;
    });
    await _loadQuizzes();
  }

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
      body: RefreshIndicator(
        onRefresh: _refreshQuizzes,
        child: _hasError
            ? _buildErrorDisplay()
            : _quizzes.isEmpty && !_isLoading
                ? _buildEmptyDisplay()
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _quizzes.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _quizzes.length) {
                        return _isLoading
                            ? Center(child: CircularProgressIndicator())
                            : SizedBox.shrink();
                      }
                      final quiz = _quizzes[index];
                      return QuizCard(quiz: quiz);
                    },
                  ),
      ),
    );
  }

  Widget _buildErrorDisplay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Failed to load quizzes',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 16),
          Text(
            'Error: ${_errorMessage ?? "Unknown error"}',
            style: TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshQuizzes,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDisplay() {
    return Center(
      child: Text(
        'No quizzes available',
        style: Theme.of(context).textTheme.headlineSmall,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    quiz['Title'] ?? 'Untitled Quiz',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                _buildDifficultyChip(quiz['Difficulty'] ?? 'Unknown'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, size: 16),
                SizedBox(width: 4),
                Text('Created by User ${quiz['UserId'] ?? 'Unknown'}'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.question_answer, size: 16),
                SizedBox(width: 4),
                Text('${(quiz['Questions'] as List?)?.length ?? 0} questions'),
                Spacer(),
                Icon(Icons.timer, size: 16),
                SizedBox(width: 4),
                Text('${quiz['TimeLimit'] ?? 'Unknown'} minutes'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.star, size: 16),
                SizedBox(width: 4),
                Text('${quiz['TotalPoints'] ?? 0} points'),
              ],
            ),
            if (quiz['Topics'] != null && (quiz['Topics'] as List).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Wrap(
                  spacing: 8,
                  children: (quiz['Topics'] as List).map((topic) => 
                    Chip(label: Text(topic['TopicName'] ?? 'Unknown Topic'))
                  ).toList(),
                ),
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
