import 'package:flutter/material.dart';
import 'package:text_interaction/pages/reader_page.dart';

class TextInteractionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text Interaction',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: ReaderPage(),
    );
  }
}
