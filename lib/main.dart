import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:intl/intl.dart'; // Import para el formato de la hora
// ayudaa
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatbotScreen(),
    );
  }
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  Uint8List? _imageBytes;
  Uint8List? _audioBytes;
  String? _textMessage;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _voiceText = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _pickImage() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _imageBytes = result.files.single.bytes;
        _audioBytes = null;
        _textMessage = null;
      });
    }
  }

  Future<void> _pickAudio() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      setState(() {
        _audioBytes = result.files.single.bytes;
        _imageBytes = null;
        _textMessage = null;
      });
    }
  }

  void _sendMessage() {
    if (_imageBytes != null ||
        _audioBytes != null ||
        (_textMessage != null && _textMessage!.isNotEmpty)) {
      String timestamp = DateFormat('HH:mm').format(DateTime.now());
      setState(() {
        if (_imageBytes != null) {
          _messages.add({
            'type': 'image',
            'content': _imageBytes,
            'from': 'user',
            'time': timestamp
          });
        }
        if (_audioBytes != null) {
          _messages.add({
            'type': 'audio',
            'content': _audioBytes,
            'from': 'user',
            'time': timestamp
          });
        }
        if (_textMessage != null && _textMessage!.isNotEmpty) {
          _messages.add({
            'type': 'text',
            'content': _textMessage,
            'from': 'user',
            'time': timestamp
          });
        }

        String botResponse = _getBotResponse(_textMessage ?? '');
        _messages.add({
          'type': 'text',
          'content': botResponse,
          'from': 'bot',
          'time': DateFormat('HH:mm').format(DateTime.now())
        });

        _controller.clear();
        _textMessage = null;
        _imageBytes = null;
        _audioBytes = null;
      });
    }
  }

  String _getBotResponse(String message) {
    if (message.toLowerCase() == 'hola') {
      return '¡Hola! ¿Cómo puedo ayudarte hoy?';
    } else if (message.toLowerCase().contains('precio')) {
      return 'El precio es 20 USD.';
    } else {
      return 'Lo siento, no entiendo esa pregunta.';
    }
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done') {
            setState(() => _isListening = false);
          }
        },
        onError: (error) => print('Error: $error'),
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _voiceText = result.recognizedWords;
              _controller.text = _voiceText;
              _textMessage = _voiceText;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    bool isUser = message['from'] == 'user';
    List<Widget> bubbleChildren = [];

    // Contenido según el tipo de mensaje
    if (message['type'] == 'text') {
      bubbleChildren.add(Text(
        message['content'],
        style: TextStyle(
          color: isUser ? Colors.white : Colors.black,
          fontSize: 16,
        ),
      ));
    } else if (message['type'] == 'image') {
      bubbleChildren.add(ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.memory(
          message['content'],
          width: 150,
          height: 150,
          fit: BoxFit.cover,
        ),
      ));
    } else if (message['type'] == 'audio') {
      bubbleChildren.add(IconButton(
        icon: Icon(Icons.play_arrow,
            color: isUser ? Colors.white : Colors.black),
        onPressed: () async {
          await _audioPlayer.play(BytesSource(message['content']));
        },
        iconSize: 40,
      ));
    }

    // Agregamos la hora debajo del contenido
    bubbleChildren.add(const SizedBox(height: 4));
    bubbleChildren.add(Text(
      message['time'],
      style: TextStyle(
        fontSize: 10,
        color: isUser ? Colors.white : Colors.black,
      ),
    ));

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: bubbleChildren,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, // Siempre blanco
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Área desplazable que incluye el encabezado y los mensajes
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length + 1, // +1 para el encabezado
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Encabezado: logo y textos, con fondo blanco
                    return Container(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: const Image(
                              image: NetworkImage(
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSn7n5QBmZ9Jhcx5e1COvr_Ixl-gpZpWzUKNQ&s',
                              ),
                              height: 200,
                              width: 200,
                            ),
                          ),
                          const SizedBox(height: 40),
                          Padding(
                            padding: const EdgeInsets.only(left: 30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Hi, I\'m DeepSeek.',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'How can I help you today?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Los mensajes se muestran a partir del índice 1
                    return _buildMessageBubble(_messages[index - 1]);
                  }
                },
              ),
            ),
            // Área de entrada de mensajes
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: _pickImage,
                  ),
                  IconButton(
                    icon: const Icon(Icons.audiotrack),
                    onPressed: _pickAudio,
                  ),
                  IconButton(
                    icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                    onPressed: _startListening,
                  ),
                  if (_imageBytes != null)
                    Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.only(right: 8.0),
                      child: Image.memory(
                        _imageBytes!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Escribe tu mensaje...',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (text) {
                        setState(() {
                          _textMessage = text;
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
