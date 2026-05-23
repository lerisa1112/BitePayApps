import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
class ChatScreen extends StatefulWidget {
  final String userId;

  const ChatScreen({
    super.key,
    required this.userId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {

  final TextEditingController _messageController =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  String? _audioPath;

  // 🌍 TEXT API
  final String apiUrl =
      "https://ai-agent-system-29a6.onrender.com/chat";

  // 🎤 VOICE API
  final String voiceApiUrl =
      "https://ai-agent-system-29a6.onrender.com/voice-chat";

  // 🎙️ RECORDING
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  double _dragOffset = 0.0;

  // 🤖 AI TYPING
  bool _isTyping = false;

  // 🔴 BLINK ANIMATION
  late AnimationController _blinkController;

  // 💬 CHAT LIST
  List<Map<String, dynamic>> _messages = [
    {
      "isMe": false,
      "text":
          "Hello 👋 I'm BitePay AI Assistant. How can I help you today?",
      "time": "Now",
    }
  ];

  @override
    void initState() {
    super.initState();
    _initRecorder();

    _blinkController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 700),
        lowerBound: 0.2,
        upperBound: 1.0,
    )..repeat(reverse: true);
    }

  // ⏱️ START TIMER
  void _startTimer() {
    _recordingSeconds = 0;

    _recordingTimer =
        Timer.periodic(const Duration(seconds: 1), (
      timer,
    ) {
      setState(() {
        _recordingSeconds++;
      });
    });
  }

  // 🛑 STOP TIMER
  void _stopTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  // 🕒 FORMAT TIME
  String _formatTime(int seconds) {

    final minutes =
        (seconds ~/ 60).toString().padLeft(2, '0');

    final remainingSeconds =
        (seconds % 60).toString().padLeft(2, '0');

    return "$minutes:$remainingSeconds";
  }

  // 🎙️ START RECORDING
  Future<void> _startRecording() async {
  try {
    final mic = await Permission.microphone.request();

    if (!mic.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Microphone permission denied")),
      );
      return;
    }

    final dir = await getTemporaryDirectory();

    _audioPath =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.startRecorder(
      toFile: _audioPath!,
      codec: Codec.aacMP4,
    );

    print("🎙️ Recording started => $_audioPath");
  } catch (e) {
    print("❌ START ERROR => $e");
  }
}

  // 🛑 STOP RECORDING
  Future<void> _stopRecording() async {
  try {
    _audioPath = await _recorder.stopRecorder();
    print("🛑 Recording stopped => $_audioPath");
  } catch (e) {
    print("❌ STOP ERROR => $e");
  }
}

  // 🎤 SEND VOICE MESSAGE
  Future<void> _sendVoiceMessage() async {

    if (_audioPath == null) {

      print("❌ AUDIO PATH NULL");
      return;
    }

    if (_isTyping) return;

    setState(() {

      _messages.add({
        "isMe": true,
        "text":
            "🎤 Voice Message (${_formatTime(_recordingSeconds)})",
        "time": "Now",
      });

      _isTyping = true;
    });

    _scrollToBottom();

    try {

      print("================================");
      print("🎤 VOICE API STARTED");
      print("FILE => $_audioPath");
      print("================================");

      var request = http.MultipartRequest(
        "POST",
        Uri.parse(voiceApiUrl),
      );

      // 👤 USER ID
      request.fields["userId"] =
          widget.userId;

      // 🎵 AUDIO FILE
      request.files.add(
        await http.MultipartFile.fromPath(
          "audio",
          _audioPath!,
        ),
      );

      // 🚀 SEND
      var streamedResponse =
          await request.send();

      var response =
          await http.Response.fromStream(
        streamedResponse,
      );

      print("================================");
      print(
          "📡 STATUS => ${response.statusCode}");
      print("📨 RESPONSE => ${response.body}");
      print("================================");

      if (response.statusCode == 200) {

        dynamic data;

        try {

          data =
              jsonDecode(response.body);

        } catch (e) {

          data = {
            "response": response.body,
          };
        }

        String botReply =
            data["response"]?.toString() ??
                "No response";

        setState(() {

          _messages.add({
            "isMe": false,
            "text": botReply,
            "time": "Now",
          });

          _isTyping = false;
        });

      } else {

        setState(() {

          _messages.add({
            "isMe": false,
            "text":
                "❌ Voice API Error : ${response.statusCode}",
            "time": "Now",
          });

          _isTyping = false;
        });
      }

    } catch (e) {

      print("❌ VOICE ERROR => $e");

      setState(() {

        _messages.add({
          "isMe": false,
          "text":
              "❌ Voice Error : ${e.toString()}",
          "time": "Now",
        });

        _isTyping = false;
      });
    }

    _scrollToBottom();
  }

  // 📤 SEND TEXT MESSAGE
  Future<void> _sendMessage() async {

    if (_isTyping) {
      print("⛔ REQUEST ALREADY RUNNING");
      return;
    }

    String message =
        _messageController.text.trim();

    if (message.isEmpty) {
      return;
    }

    if (widget.userId.isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text("User ID Missing"),
        ),
      );

      return;
    }

    setState(() {

      _messages.add({
        "isMe": true,
        "text": message,
        "time": "Now",
      });

      _isTyping = true;
    });

    _messageController.clear();

    _scrollToBottom();

    try {

      final requestBody = {
        "userId": widget.userId,
        "message": message,
      };

      final response = await http.post(

        Uri.parse(apiUrl),

        headers: {
          "Content-Type":
              "application/json",
        },

        body: jsonEncode(requestBody),

      ).timeout(
        const Duration(seconds: 120),
      );

      if (response.statusCode == 200) {

        dynamic data;

        try {

          data =
              jsonDecode(response.body);

        } catch (e) {

          data = {
            "response": response.body,
          };
        }

        String botReply =
            data["response"]?.toString() ??
                "No response from AI";

        if (!mounted) return;

        setState(() {

          _messages.add({
            "isMe": false,
            "text": botReply,
            "time": "Now",
          });

          _isTyping = false;
        });

      } else {

        if (!mounted) return;

        setState(() {

          _messages.add({
            "isMe": false,
            "text":
                "❌ Server Error : ${response.statusCode}",
            "time": "Now",
          });

          _isTyping = false;
        });
      }

    } on TimeoutException {

      if (!mounted) return;

      setState(() {

        _messages.add({
          "isMe": false,
          "text":
              "⏰ Server taking too long",
          "time": "Now",
        });

        _isTyping = false;
      });

    } catch (e) {

      if (!mounted) return;

      setState(() {

        _messages.add({
          "isMe": false,
          "text":
              "❌ Error : ${e.toString()}",
          "time": "Now",
        });

        _isTyping = false;
      });
    }

    _scrollToBottom();
  }

  // ⬇️ AUTO SCROLL
  void _scrollToBottom() {

    Future.delayed(
      const Duration(milliseconds: 300),
      () async {

        if (_scrollController.hasClients) {

          await _scrollController.animateTo(

            _scrollController
                    .position.maxScrollExtent +
                120,

            duration:
                const Duration(milliseconds: 300),

            curve: Curves.easeOut,
          );
        }
      },
    );
  }

    Future<void> _initRecorder() async {
    await Permission.microphone.request();

    await _recorder.openRecorder();

    await _recorder.setSubscriptionDuration(
        const Duration(milliseconds: 100),
    );
    }

    @override
    void dispose() {
    _recordingTimer?.cancel();
    _recorder.closeRecorder();
    _messageController.dispose();
    _scrollController.dispose();
    _blinkController.dispose();
    super.dispose();
    }

  // 💬 CHAT BUBBLE
  Widget _buildMessage(
    Map<String, dynamic> message,
  ) {

    final isMe = message["isMe"];

    return Align(

      alignment:
          isMe
              ? Alignment.centerRight
              : Alignment.centerLeft,

      child: Container(

        margin:
            const EdgeInsets.only(bottom: 14),

        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context)
                      .size
                      .width *
                  0.75,
        ),

        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),

        decoration: BoxDecoration(

          gradient:
              isMe
                  ? const LinearGradient(
                      colors: [
                        Color(0xFF8E2DE2),
                        Color(0xFFB06AB3),
                      ],
                    )
                  : null,

          color:
              isMe ? null : Colors.white,

          borderRadius: BorderRadius.only(

            topLeft:
                const Radius.circular(18),

            topRight:
                const Radius.circular(18),

            bottomLeft: Radius.circular(
              isMe ? 18 : 4,
            ),

            bottomRight: Radius.circular(
              isMe ? 4 : 18,
            ),
          ),

          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(

          crossAxisAlignment:
              isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,

          children: [

            Text(
              message["text"],

              style: TextStyle(
                color:
                    isMe
                        ? Colors.white
                        : Colors.black87,
                fontSize: 15,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              message["time"],

              style: TextStyle(
                color:
                    isMe
                        ? Colors.white70
                        : Colors.black45,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🤖 AI TYPING
  Widget _buildTypingWidget() {

    return Align(

      alignment: Alignment.centerLeft,

      child: Container(

        margin:
            const EdgeInsets.only(bottom: 14),

        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius:
              BorderRadius.circular(20),

          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Row(

          mainAxisSize: MainAxisSize.min,

          children: [

            Container(

              padding:
                  const EdgeInsets.all(8),

              decoration: BoxDecoration(
                color:
                    const Color(0xFFF1EEFF),
                borderRadius:
                    BorderRadius.circular(12),
              ),

              child: const Icon(
                Icons.smart_toy_rounded,
                color: Color(0xFF8E2DE2),
                size: 18,
              ),
            ),

            const SizedBox(width: 12),

            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
              ),
            ),

            const SizedBox(width: 12),

            const Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              mainAxisSize: MainAxisSize.min,

              children: [

                Text(
                  "BitePay AI",
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 13,
                  ),
                ),

                SizedBox(height: 2),

                Text(
                  "Searching for best response...",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🎤 RECORD PANEL
  Widget _buildRecordingPanel() {

    return Container(

      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),

      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius:
            BorderRadius.circular(30),
      ),

      child: Row(
        children: [

          FadeTransition(
            opacity: _blinkController,

            child: const Icon(
              Icons.fiber_manual_record,
              color: Colors.red,
              size: 16,
            ),
          ),

          const SizedBox(width: 10),

          Text(
            _formatTime(_recordingSeconds),

            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),

          const Spacer(),

          Opacity(

            opacity:
                (1.0 + (_dragOffset / 100))
                    .clamp(0.0, 1.0),

            child: const Row(
              children: [

                Icon(
                  Icons.keyboard_arrow_left,
                  color: Colors.grey,
                ),

                Text(
                  "Slide to cancel",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✍️ INPUT
  Widget _buildInputBox() {

    return Container(

      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
      ),

      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius:
            BorderRadius.circular(30),
      ),

      child: TextField(

        controller: _messageController,

        maxLines: null,

        textCapitalization:
            TextCapitalization.sentences,

        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "AI સાથે વાત કરો...",
        ),

        onSubmitted: (value) {
          _sendMessage();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF7F7FB),

      appBar: AppBar(

        elevation: 0,

        backgroundColor: Colors.white,

        title: Row(
          children: [

            const CircleAvatar(
              radius: 22,
              backgroundColor:
                  Color(0xFF9370DB),
              child: Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
              ),
            ),

            const SizedBox(width: 12),

            Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                const Text(
                  "BitePay AI",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 17,
                  ),
                ),

                const Text(
                  "Online",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      body: Column(
        children: [

          // 💬 CHAT LIST
          Expanded(
            child: ListView.builder(

              controller:
                  _scrollController,

              padding:
                  const EdgeInsets.all(16),

              itemCount:
                  _messages.length +
                      (_isTyping ? 1 : 0),

              itemBuilder:
                  (context, index) {

                if (_isTyping &&
                    index ==
                        _messages.length) {

                  return _buildTypingWidget();
                }

                return _buildMessage(
                  _messages[index],
                );
              },
            ),
          ),

          // 🔻 BOTTOM BAR
          SafeArea(
            child: Container(

              padding:
                  const EdgeInsets.only(
                left: 12,
                right: 12,
                top: 10,
                bottom: 14,
              ),

              decoration: BoxDecoration(
                color: Colors.white,

                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black
                            .withOpacity(0.05),
                    blurRadius: 12,
                    offset:
                        const Offset(0, -3),
                  ),
                ],
              ),

              child: Row(
                children: [

                  // 🎙️ MIC
                  GestureDetector(

                    onLongPressStart: (_) async {

                      setState(() {
                        _isRecording = true;
                        _dragOffset = 0.0;
                      });

                      _startTimer();

                      await _startRecording();
                    },

                    onLongPressMoveUpdate:
                        (details) {

                      setState(() {
                        _dragOffset =
                            details
                                .offsetFromOrigin
                                .dx;
                      });
                    },

                    onLongPressEnd: (_) async {

                      _stopTimer();

                      await _stopRecording();

                      if (_dragOffset <
                          -100) {

                        if (_audioPath != null) {

                          File(_audioPath!)
                              .deleteSync();
                        }

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(

                          const SnackBar(
                            content: Text(
                              "Recording cancelled 🗑️",
                            ),
                          ),
                        );

                      } else {

                        await _sendVoiceMessage();

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(

                          SnackBar(
                            content: Text(
                              "Voice message sent (${_formatTime(_recordingSeconds)})",
                            ),
                          ),
                        );
                      }

                      setState(() {
                        _isRecording = false;
                        _dragOffset = 0.0;
                      });
                    },

                    child: AnimatedContainer(

                      duration:
                          const Duration(
                        milliseconds: 120,
                      ),

                      transform:
                          Matrix4.identity()
                            ..translate(
                              _dragOffset > 0
                                  ? 0.0
                                  : (_dragOffset <
                                          -100
                                      ? -100.0
                                      : _dragOffset),
                              0.0,
                            ),

                      padding:
                          const EdgeInsets.all(
                        14,
                      ),

                      decoration:
                          BoxDecoration(

                        color:
                            _isRecording
                                ? Colors.redAccent
                                : const Color(
                                    0xFFF1EEFF,
                                  ),

                        shape: BoxShape.circle,
                      ),

                      child: Icon(

                        _isRecording
                            ? Icons.mic
                            : Icons
                                .mic_none_rounded,

                        color:
                            _isRecording
                                ? Colors.white
                                : const Color(
                                    0xFF9370DB,
                                  ),

                        size: 26,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // ✍️ INPUT
                  Expanded(

                    child: AnimatedSwitcher(

                      duration:
                          const Duration(
                        milliseconds: 250,
                      ),

                      child:
                          _isRecording
                              ? _buildRecordingPanel()
                              : _buildInputBox(),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // 🚀 SEND
                  if (!_isRecording)
                    InkWell(

                      onTap: _sendMessage,

                      borderRadius:
                          BorderRadius.circular(
                        30,
                      ),

                      child: Container(

                        padding:
                            const EdgeInsets.all(
                          13,
                        ),

                        decoration:
                            const BoxDecoration(

                          gradient:
                              LinearGradient(
                            colors: [
                              Color(0xFF8E2DE2),
                              Color(0xFFB06AB3),
                            ],
                          ),

                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}