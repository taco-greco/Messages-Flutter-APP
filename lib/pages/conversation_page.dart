import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConversationPage extends StatefulWidget {
  final int userId;
  final int otherUserId;
  final String otherUsername; // Add this line

  const ConversationPage({super.key, required this.userId, required this.otherUserId, required this.otherUsername}); // Update this line

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
        title: Text(widget.otherUsername, style: const TextStyle(color: Colors.white)), // Update this line
        backgroundColor: const Color(0xFF4A1E80),
      ),
      body: _messages.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          final isSentByUser = message['Sender_ID'] == widget.userId;
          final alignment = isSentByUser ? Alignment.centerRight : Alignment.centerLeft;
          final color = isSentByUser ? const Color(0xFF4A1E80) : const Color(0xFFFFB830);
          final icon = isSentByUser ? Icons.person : Icons.person_outline;

          return Align(
            alignment: alignment,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isSentByUser) Icon(icon, color: Colors.white),
                  if (!isSentByUser) const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message['Content'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        message['Timestamp'],
                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ],
                  ),
                  if (isSentByUser) const SizedBox(width: 10),
                  if (isSentByUser) Icon(icon, color: Colors.white),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}