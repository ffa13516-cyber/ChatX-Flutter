import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatScreen(),
    );
  }
}

class Message {
  final String text;
  final bool isMe;

  Message(this.text, this.isMe);
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final messages = [
      Message("Hey! 👋", false),
      Message("How are you?", false),
      Message("I'm good. You?", true),
      Message("It seems we have a lot in common", false),
      Message("Good concepts! 🔥", true),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // 🖼️ Background
          Positioned.fill(
            child: Image.network(
              "https://images.unsplash.com/photo-1542751110-97427bbecf20",
              fit: BoxFit.cover,
            ),
          ),

          // 🌫️ Blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // 🔝 HEADER
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: const [
                      CircleAvatar(radius: 20),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Daniel Garcia",
                              style: TextStyle(color: Colors.white)),
                          Text("Online",
                              style: TextStyle(
                                  color: Colors.green, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),

                // 💬 MESSAGES
                Expanded(
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];

                      return Align(
                        alignment: msg.isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin:
                              const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: msg.isMe
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF6A5AE0),
                                      Color(0xFFB44CFF),
                                    ],
                                  )
                                : null,
                            color: msg.isMe
                                ? null
                                : Colors.white.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(20),
                            boxShadow: msg.isMe
                                ? [
                                    BoxShadow(
                                      color: Colors.purple
                                          .withOpacity(0.4),
                                      blurRadius: 12,
                                    )
                                  ]
                                : [],
                          ),
                          child: Text(
                            msg.text,
                            style: const TextStyle(
                                color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ✍️ INPUT
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                          sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12),
                        decoration: BoxDecoration(
                          color:
                              Colors.white.withOpacity(0.05),
                          borderRadius:
                              BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.add,
                                color: Colors.white54),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: TextField(
                                style: TextStyle(
                                    color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: "Message...",
                                  hintStyle: TextStyle(
                                      color:
                                          Colors.white38),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.all(8),
                              decoration:
                                  const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF7F00FF),
                                    Color(0xFFE100FF),
                                  ],
                                ),
                              ),
                              child: const Icon(Icons.mic,
                                  color: Colors.white,
                                  size: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
