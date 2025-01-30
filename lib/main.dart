import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data'; // Para trabajar con datos de tipo byte

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
  final List<dynamic> _messages = [];  // Lista para almacenar mensajes (pueden ser texto o imágenes)
  Uint8List? _imageBytes;  // Para almacenar la imagen seleccionada
  String? _textMessage;  // Para almacenar el texto ingresado

  // Función para seleccionar una imagen
  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _imageBytes = result.files.single.bytes;
        _textMessage = null;  // Limpiar el texto si se selecciona una imagen
      });
    }
  }

  // Función para enviar el mensaje (con imagen o solo texto)
  void _sendMessage() {
    if (_imageBytes != null || (_textMessage != null && _textMessage!.isNotEmpty)) {
      setState(() {
        // Si hay imagen, enviar imagen, sino enviar texto
        if (_imageBytes != null) {
          _messages.add({'type': 'image', 'content': _imageBytes, 'from': 'user'});
        }
        if (_textMessage != null && _textMessage!.isNotEmpty) {
          _messages.add({'type': 'text', 'content': 'Tú: $_textMessage', 'from': 'user'});
        }

        // Respuesta básica del chatbot (texto)
        String botResponse = _getBotResponse(_textMessage ?? '');
        _messages.add({'type': 'text', 'content': 'Chatbot: $botResponse', 'from': 'bot'});

        _controller.clear();  // Limpiar el campo de texto
        _textMessage = null;  // Limpiar el texto ingresado
        _imageBytes = null;   // Limpiar la imagen seleccionada
      });
    }
  }

  // Función que genera una respuesta básica del chatbot
  String _getBotResponse(String message) {
    if (message.toLowerCase() == 'hola') {
      return '¡Hola! ¿Cómo puedo ayudarte hoy?';
    } else if (message.toLowerCase().contains('precio')) {
      return 'El precio es 20 USD.';
    } else {
      return 'Lo siento, no entiendo esa pregunta.';
    }
  }

  // Widget para crear la burbuja de mensaje
  Widget _buildMessageBubble(dynamic message) {
    bool isUser = message['from'] == 'user';
    if (message['type'] == 'text') {
      return Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: isUser ? Colors.blueAccent : Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            message['content'],
            style: TextStyle(
              color: isUser ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
        ),
      );
    } else if (message['type'] == 'image') {
      return Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.memory(
              message['content'],
              width: 150,  // Tamaño de la imagen
              height: 150, // Tamaño de la imagen
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
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
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                // Botón para seleccionar imagen
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _pickImage,
                ),
                // Si hay una imagen seleccionada, mostrarla al lado del campo de texto
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
                // Campo de texto para el mensaje del usuario
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Escribe tu mensaje...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (text) {
                      setState(() {
                        _textMessage = text;  // Actualizar texto mientras se escribe
                      });
                    },
                  ),
                ),
                // Botón para enviar el mensaje
                IconButton(
                  icon: const Icon(Icons.send),
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
