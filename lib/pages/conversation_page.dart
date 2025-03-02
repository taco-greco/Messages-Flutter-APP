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
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/message/getMessages/${widget.userId}/${widget.otherUserId}'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['code'] == 0) {
        setState(() {
          _messages = data['messages'];
        });
      } else {
        print('Failed to load messages: ${data['message']}');
      }
    } else {
      print('Failed to load messages: ${response.reasonPhrase}');
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
            title: Text(message['Content']),
            subtitle: Text(message['Timestamp']),
          );
        },
      ),
    );
  }
}