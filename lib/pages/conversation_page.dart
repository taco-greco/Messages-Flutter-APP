import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class ConversationPage extends StatefulWidget {
  final int userId;
  final int otherUserId;
  final String otherUsername;

  const ConversationPage({super.key, required this.userId, required this.otherUserId, required this.otherUsername});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  List<dynamic> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _fetchMessages();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _messageController.dispose();
    super.dispose();
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

  Future<void> _sendMessage() async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/message/send'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'sender_id': widget.userId,
        'receiver_id': widget.otherUserId,
        'content': _messageController.text,
      }),
    );

    if (response.statusCode == 200) {
      _messageController.clear();
      _fetchMessages();
    } else {
      print('Failed to send message: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUsername, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4A1E80),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
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
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF4A1E80)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}