import 'package:flutter/material.dart';
import 'login.dart'; // Import the Login page
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'conversation_page.dart'; // Import the ConversationPage

class HomePage extends StatefulWidget {
  final int userId;

  const HomePage({super.key, required this.userId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/user/getUsers/${widget.userId}'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['code'] == 0) {
        setState(() {
          _users = data['users'];
        });
      } else {
        print('Failed to load users: ${data['message']}');
      }
    } else {
      print('Failed to load users: ${response.reasonPhrase}');
    }
  }

  void _openConversation(int userId, int otherUserId, String otherUsername) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationPage(
          userId: userId,
          otherUserId: otherUserId,
          otherUsername: otherUsername, // Pass the otherUsername parameter
        ),
      ),
    );
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()), // Navigate back to the login page
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QuoiApp', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4A1E80),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          final userId = user['ID']; // Use the correct field name 'ID'
          final username = user['Username']; // Get the username
          return Card(
            color: const Color(0xFFFFB830),
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(
                username,
                style: const TextStyle(color: Colors.black),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.message, color: Colors.white),
                onPressed: () => _openConversation(widget.userId, userId, username), // Pass the username
              ),
            ),
          );
        },
      ),
    );
  }
}