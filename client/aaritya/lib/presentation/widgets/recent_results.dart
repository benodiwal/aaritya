import 'package:flutter/material.dart';

Widget RecentResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Result',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text('See all', style: TextStyle(color: Colors.blue)),
            ],
          ),
        ),
        _resultItem('Science & tecnology', '6/10', Colors.purple.shade100, '1'),
        _resultItem('Geography & history', '9/10', Colors.blue.shade100, '2'),
      ],
    );
  }

 Widget _resultItem(String title, String score, Color color, String number) {
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
            child: Text(number, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                LinearProgressIndicator(
                  value: double.parse(score.split('/')[0]) / 10,
                  backgroundColor: Colors.white,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Text(score, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
