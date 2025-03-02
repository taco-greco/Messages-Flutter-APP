import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConversationPage extends StatefulWidget {
  final int userId;
  final int otherUserId;

  const ConversationPage({super.key, required this.userId, required this.otherUserId});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  List<dynamic> _messages = [];

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/user/getMessages/${widget.userId}/${widget.otherUserId}'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _messages = data['messages'];
      });
    } else {
      print('Failed to load messages');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4A1E80),
      ),
      body: _messages.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          return ListTile(
            title: Text(message['content']),
            subtitle: Text(message['timestamp']),
          );
        },
      ),
    );
  }
}