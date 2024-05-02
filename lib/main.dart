import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:chatboot/message.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat com IA em Flutter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _userInput = TextEditingController();

  final apikey = "AIzaSyABRdYzO1sTNujgHpe3ZwlOLH_JqyCr6oM";

  final List<Message> _message = [];

  Future<void> talkWithGemini() async {
    final userMsg = _userInput.text;

    setState(() {
      _message
          .add(Message(isUser: true, message: userMsg, date: DateTime.now()));
    });

    try {
      final model = GenerativeModel(model: "gemini-pro", apiKey: apikey);
      final content = Content.text(userMsg);
      final response = await model.generateContent([content]);

      setState(() {
        _message.add(Message(
            isUser: false, message: response.text ?? "", date: DateTime.now()));
      });

      print('Response from Gemini AI: ${response.text}');

      _userInput.clear();
    } catch (e) {
      print('Error communicating with Gemini AI: $e');
      setState(() {
        _message.add(Message(
            isUser: false,
            message: "Error communicating with Gemini AI",
            date: DateTime.now()));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
                child: ListView.builder(
                    itemCount: _message.length,
                    itemBuilder: (context, index) {
                      final message = _message[index];
                      return Messages(
                          isUser: message.isUser,
                          message: message.message,
                          date: DateFormat('HH:mm').format(message.date));
                    },),),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 15,
                    child: TextFormField(
                      style: TextStyle(color: Color.fromARGB(255, 86, 13, 195)),
                      controller: _userInput,
                      cursorColor: Color.fromARGB(255, 3, 75, 43),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                              color: Colors.blue), // Set border color here
                        ),
                        labelStyle: TextStyle(color: Color.fromARGB(255, 182, 7, 7)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 3,
                            color: const Color.fromARGB(255, 92, 132, 201),
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    padding: EdgeInsets.all(12),
                    iconSize: 30,
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.blueAccent),
                        foregroundColor:
                            MaterialStateProperty.all(Colors.white),
                        shape: MaterialStateProperty.all(CircleBorder())),
                    onPressed: () {
                      talkWithGemini();
                    },
                    icon: Icon(Icons.send),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}