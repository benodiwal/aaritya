import 'package:aaritya/presentation/widgets/featured_categories.dart';
import 'package:aaritya/presentation/widgets/header.dart';
import 'package:aaritya/presentation/widgets/play_card.dart';
import 'package:aaritya/presentation/widgets/recent_results.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Header(),
            PlayCard(),
            FeaturedCategories(),
            RecentResults(),
          ],
        ),
      ),
    );
  }
}
