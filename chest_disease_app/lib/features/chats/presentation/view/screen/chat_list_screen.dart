import 'dart:async';
import 'dart:io';

import 'package:chest_disease_app/core/data/network_services/gemiai_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class MedicalChatbotScreen extends StatefulWidget {
  const MedicalChatbotScreen({super.key});

  @override
  _MedicalChatbotScreenState createState() => _MedicalChatbotScreenState();
}

class _MedicalChatbotScreenState extends State<MedicalChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];

  // Gemiai (Gemini) chatbot service used to generate replies.
  final GemiaiService _gemiaiService = GemiaiService();
  bool _isSending = false;

  File? _attachedFile;
  String? _attachedFileName;

  @override
  void initState() {
    super.initState();
    // Add initial bot message
    _addBotMessage(
      "Hello! I am your Medical Assistant. I can help you interpret X-Ray results. "
      "You can also upload an image or report using the upload button.",
    );
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.insert(0, {"sender": "bot", "text": text});
    });
  }

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result == null || result.files.single.path == null) return;

    setState(() {
      _attachedFile = File(result.files.single.path!);
      _attachedFileName = result.files.single.name;
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _attachedFile == null) return;

    // Capture file before clearing (needed for image analysis)
    final fileToSend = _attachedFile;
    final attachmentName = _attachedFileName;

    setState(() {
      _messages.insert(0, {
        "sender": "user",
        "text": text.isEmpty ? (attachmentName ?? "[Image]") : text,
        if (attachmentName != null) "attachment": attachmentName,
      });
      _isSending = true;
    });

    _controller.clear();
    _attachedFile = null;
    _attachedFileName = null;

    // Scroll to the bottom quickly so user sees their message.
    Timer(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    final prompt = text.isEmpty
        ? "Please analyze this medical/X-ray image and describe what you see. If it's an X-ray, note any findings, abnormalities, or areas of concern."
        : text;

    String botReply;
    try {
      botReply = await _gemiaiService.generateText(prompt, imageFile: fileToSend);
    } catch (e, st) {
      // Include error details for easier troubleshooting.
      final errorMessage = e.toString();
      debugPrint('GemiaiService error: $errorMessage');
      debugPrintStack(label: 'GemiaiService stacktrace', stackTrace: st);

      botReply =
          "Sorry, I couldn't reach the AI service.\nError: $errorMessage";
    }

    setState(() {
      _messages.insert(0, {"sender": "bot", "text": botReply});
      _isSending = false;
    });

    Timer(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Medical Assistant 🤖"),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        foregroundColor: const Color(0xFF007AFF), // A nice blue
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _ChatBubble(
                  text: message['text'] as String,
                  isUser: message['sender'] == 'user',
                  attachmentName: message['attachment'] as String?,
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_attachedFileName != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.attach_file, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _attachedFileName!,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _attachedFile = null;
                            _attachedFileName = null;
                          });
                        },
                        child: const Icon(Icons.close, size: 16),
                      ),
                    ],
                  ),
                ),
              ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Color(0xFF007AFF)),
                  onPressed: _pickAttachment,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                _isSending
                    ? const SizedBox(
                        height: 36,
                        width: 36,
                        child: Center(
                          child: SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation(
                                Color(0xFF007AFF),
                              ),
                            ),
                          ),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send, color: Color(0xFF007AFF)),
                        onPressed: _sendMessage,
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final String? attachmentName;

  const _ChatBubble({
    required this.text,
    required this.isUser,
    this.attachmentName,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF007AFF) : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser
                ? const Radius.circular(20)
                : const Radius.circular(0),
            bottomRight: isUser
                ? const Radius.circular(0)
                : const Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (attachmentName != null) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.insert_drive_file,
                    size: 16,
                    color: isUser ? Colors.white : Colors.black54,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    attachmentName!,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            Text(
              text,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
