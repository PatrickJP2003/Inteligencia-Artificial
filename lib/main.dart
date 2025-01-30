import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data'; // For working with byte data
import 'dart:convert';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
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
  final List<String> _messages = [];
  Uint8List? _imageBytes;

  // Function to pick a file using file_picker
  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _imageBytes = result.files.single.bytes;
      });
    }
  }

  // Function to send message to chatbot
  void _sendMessage(String message) {
    setState(() {
      _messages.add("Tú: $message");
      _messages.add("Chatbot: Respuesta predeterminada del chatbot");
    });
    _controller.clear();  // Clear the text field after sending the message.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbot de Tienda'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                // Button to pick image
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _pickImage,
                ),
                // Text field for user input
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Escribe tu mensaje...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                // Send button
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _sendMessage(_controller.text);
                    }
                  },
                ),
              ],
            ),
          ),
          // Show image if selected
          if (_imageBytes != null)
            Image.memory(_imageBytes!),  // For web, show the image selected from the file system
        ],
      ),
    );
  }
}
