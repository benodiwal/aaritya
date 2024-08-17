import 'dart:io';

import 'package:aaritya/core/network/api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    try {
      final profileData = await _apiService.getUserProfile();
      final rank = await _apiService.getUserRank();
      setState(() {
        _profileData = profileData;
        _profileData!['rank'] = rank;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile data: ${e.toString()}')),
      );
    }
  }

  Future<void> _pickImage() async {
  final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    setState(() {
      _image = File(pickedFile.path);
    });
    try {
      await _apiService.uploadProfileImage(_image!);
      await _loadProfileData(); // Reload profile data to get new image URL
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile image updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: ${e.toString()}')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings page
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          _image != null
                              ? FileImage(_image!)
                              : (_profileData?['profileImageUrl'] != null
                                      ? NetworkImage(
                                          _profileData!['profileImageUrl'])
                                      : AssetImage(
                                          'assets/default_profile_picture.jpg'))
                                  as ImageProvider,
                      child: _image == null &&
                              _profileData?['profileImageUrl'] == null
                          ? Icon(Icons.add_a_photo,
                              size: 30, color: Colors.white)
                          : null,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _profileData?['Username'] ?? 'Unknown User',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    _profileData?['Email'] ?? 'No email',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 20),
                  _buildInfoCard(context),
                  SizedBox(height: 20),
                  _buildStatsCard(context),
                  SizedBox(height: 20),
                  _buildRecentActivityCard(context),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Personal Information',
                style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 10),
            _buildInfoRow(
                Icons.cake, 'Birthday', _profileData?['birthday'] ?? 'Not set'),
            _buildInfoRow(Icons.location_on, 'Location',
                _profileData?['location'] ?? 'Not set'),
            _buildInfoRow(Icons.school, 'Education',
                _profileData?['education'] ?? 'Not set'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stats', style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Quizzes Taken',
                    _profileData?['quizzesTaken']?.toString() ?? '0'),
                _buildStat('Avg. Score',
                    '${_profileData?['avgScore']?.toStringAsFixed(1) ?? '0'}%'),
                _buildStat(
                    'Rank', '#${_profileData?['rank']?.toString() ?? 'N/A'}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildRecentActivityCard(BuildContext context) {
    List<Map<String, dynamic>> recentActivities =
        _profileData?['recentActivities'] ?? [];

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Activity',
                style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 10),
            ...recentActivities
                .map((activity) => _buildActivityItem(
                    activity['description'], activity['time']))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String activity, String time) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(activity)),
          Text(time, style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
