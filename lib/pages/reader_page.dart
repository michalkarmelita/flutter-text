import 'package:flutter/material.dart';
import 'package:text_interaction/app/constants.dart';
import 'package:text_interaction/utils/reader_text.dart';

class ReaderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
//      body: Markdown(
//        selectable: true,
//        data: Constants.md,
//        imageDirectory: 'https://raw.githubusercontent.com',
//      ),
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
        padding: _padding,
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
  bool _isEditing = false;

  final hKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    if (!_isEditing)
      return Column(
        children: <Widget>[
          RaisedButton(
            child: Text('GO TO HIGHLIGHT'),
            onPressed: () {
              Scrollable.ensureVisible(hKey.currentContext,
                  duration: Duration(seconds: 2));
            },
          ),
          _solid(() {
            setState(() {
              _isEditing = true;
            });
          }),
        ],
      );
    return Padding(
      padding: _padding,
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

  Widget _solid(VoidCallback onModeChange) {
    return Padding(
      padding: _padding,
      child: GestureDetector(
        onLongPressStart: (_) => onModeChange(),
        child: SolidReaderText(
          spans: <ReaderSpan>[
            RegularSpan(TextSpan(text: Constants.loremIpsum, style: _style)),
            HighlightedSpan(
                TextSpan(
                    text: 'HIGHLIGHT',
                    style: _style.copyWith(backgroundColor: Colors.yellow)),
                key: hKey),
            RegularSpan(TextSpan(text: Constants.loremIpsum, style: _style)),
          ],
        ),
      ),
    );
  }
}

class Highlight {
  final int start;
  final int end;

  Highlight(this.start, this.end);
}

const _style = TextStyle(color: Colors.black, fontSize: 20.0);
const _padding = EdgeInsets.all(15.0);
