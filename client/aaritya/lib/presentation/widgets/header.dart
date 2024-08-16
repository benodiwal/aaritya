import 'package:flutter/material.dart';

Widget Header() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(Icons.grid_view, color: Colors.blue),
        Icon(Icons.search, color: Colors.blue),
      ],
    ),
  );
}
