import 'package:flutter/material.dart';

void main() {
  runApp(QuizApp());
}

class QuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildPlayCard(),
            _buildCategories(),
            _buildRecentResults(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Quizzes'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage('https://example.com/avatar.jpg'),
          ),
          SizedBox(width: 8),
          Text(
            'Ralph Edwards',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Spacer(),
          Icon(Icons.search),
        ],
      ),
    );
  }

  Widget _buildPlayCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(
            "Let's play\ntogether",
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
          Spacer(),
          ElevatedButton(
            onPressed: () {},
            child: Text('Play now'),
            style: ElevatedButton.styleFrom(primary: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Featured Categories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _categoryItem('Biology', Icons.science),
              _categoryItem('Animals', Icons.pets),
              _categoryItem('Geography', Icons.public),
              _categoryItem('Science', Icons.biotech),
            ],
          ),
        ),
      ],
    );
  }

  Widget _categoryItem(String title, IconData icon) {
    return Container(
      width: 80,
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue.shade100,
            child: Icon(icon, color: Colors.blue),
          ),
          SizedBox(height: 4),
          Text(title, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildRecentResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Results',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text('See all', style: TextStyle(color: Colors.blue)),
            ],
          ),
        ),
        _resultItem('Science & technology', '6/10', Colors.purple.shade100),
        _resultItem('Geography & history', '9/10', Colors.blue.shade100),
      ],
    );
  }

  Widget _resultItem(String title, String score, Color color) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Text('1', style: TextStyle(color: Colors.black)),
          ),
          SizedBox(width: 16),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          Spacer(),
          Text(score, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
