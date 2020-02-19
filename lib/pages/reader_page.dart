import 'package:flutter/material.dart';
import 'package:text_interaction/app/constants.dart';
import 'package:text_interaction/utils/reader_text.dart';

class ReaderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          _Header(title: 'The Title of The Story', author: 'Authors Name'),
          DocText(),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String author;

  const _Header({Key key, this.title, this.author}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 300.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline),
              const SizedBox(height: 10.0),
              Text(author,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline),
            ],
          ),
        ),
      ),
    );
  }
}

class DocText extends StatefulWidget {
  @override
  _DocTextState createState() => _DocTextState();
}

class _DocTextState extends State<DocText> {
  final text = Constants.loremIpsum;
  Highlight highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: SelectableReaderText(
        textSpan: span,
        onHighlight: (start, end) {
          setState(() {
            highlight = Highlight(start, end);
          });
        },
        selectionEnabled: true,
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  TextSpan get span {
    if (highlight == null) return TextSpan(text: text, style: _style);
    final startIndex = 0;
    final endIndex = text.length;
    final startText = text.substring(startIndex, highlight.start);
    final middleText = text.substring(highlight.start, highlight.end);
    final endText = text.substring(highlight.end, endIndex);
    List<TextSpan> spans = [];
    spans.add(TextSpan(text: startText));
    spans.add(TextSpan(
        text: middleText, style: TextStyle(backgroundColor: Colors.yellow)));
    spans.add(TextSpan(text: endText));
    return TextSpan(children: spans, style: _style);
  }
}

class Highlight {
  final int start;
  final int end;

  Highlight(this.start, this.end);
}

const _style = TextStyle(color: Colors.black, fontSize: 20.0);
