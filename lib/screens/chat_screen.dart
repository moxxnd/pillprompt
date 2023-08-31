import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> sendChatMessage(String message) async {
  const String apiUrl = "http://223.194.160.130/chat"; // API 경로 변경
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({"message": message}),
  );

  return jsonDecode(response.body);
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  void _submitMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      setState(() {
        _messages.add({"text": messageText, "type": "user"});
      });

      _messageController.clear();

      final response = await sendChatMessage(messageText);

      if (response.isNotEmpty) {
        setState(() {
          _messages.add(
              {"text": response["reply"], "type": "bot"}); // 서버 응답에서 수정하세요.
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("챗봇")),
      body: Column(
        children: [
          // 메시지 목록을 표시하는 부분
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]["text"]),
                  subtitle: Text(_messages[index]["type"]),
                );
              },
            ),
          ),

          // 새 메시지를 입력하고 전송하는 부분
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "메시지를 입력하세요...",
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _submitMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
