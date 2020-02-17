import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:text_interaction/utils/reader_text_selection.dart';

typedef HighlightCallback = void Function(int start, int end);

class SelectableReaderText extends StatefulWidget {
  final String data;
  final FocusNode focusNode;
  final TextSpan textSpan;
  final TextStyle style;
  final bool selectionEnabled;
  final HighlightCallback onHighlight;

  const SelectableReaderText({
    this.data,
    Key key,
    this.focusNode,
    this.textSpan,
    this.style,
    this.selectionEnabled,
    this.onHighlight,
  }) : super(key: key);

  @override
  _SelectableReaderTextState createState() => _SelectableReaderTextState();
}

class _SelectableReaderTextState extends State<SelectableReaderText>
    with AutomaticKeepAliveClientMixin
    implements TextSelectionGestureDetectorBuilderDelegate {
  EditableTextState get _editableText => editableTextKey.currentState;
  _TextSpanEditingController _controller;
  FocusNode _focusNode;
  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_focusNode ??= FocusNode());

  bool _showSelectionHandles = false;

  _ReaderTextSelectionGestureDetectorBuilder _selectionGestureDetectorBuilder;

  @override
  void initState() {
    super.initState();
    _selectionGestureDetectorBuilder =
        _ReaderTextSelectionGestureDetectorBuilder(state: this);
    _controller = _TextSpanEditingController(
        textSpan: widget.textSpan ?? TextSpan(text: widget.data));
  }

  @override
  void didUpdateWidget(SelectableReaderText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data ||
        widget.textSpan != oldWidget.textSpan) {
      _controller = _TextSpanEditingController(
          textSpan: widget.textSpan ?? TextSpan(text: widget.data));
    }
    if (_effectiveFocusNode.hasFocus && _controller.selection.isCollapsed) {
      _showSelectionHandles = false;
    }
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    super.dispose();
  }

  void _handleSelectionChanged(
      TextSelection selection, SelectionChangedCause cause) {
    final bool willShowSelectionHandles = _shouldShowSelectionHandles(cause);
    if (willShowSelectionHandles != _showSelectionHandles) {
      setState(() {
        _showSelectionHandles = willShowSelectionHandles;
      });
    }
  }

  /// Toggle the toolbar when a selection handle is tapped.
  void _handleSelectionHandleTapped() {
    if (_controller.selection.isCollapsed) {
      _editableText.toggleToolbar();
    }
  }

  bool _shouldShowSelectionHandles(SelectionChangedCause cause) {
    // When the text field is activated by something that doesn't trigger the
    // selection overlay, we shouldn't show the handles either.
    if (!_selectionGestureDetectorBuilder.shouldShowSelectionToolbar)
      return false;

    if (_controller.selection.isCollapsed) return false;

    if (cause == SelectionChangedCause.keyboard) return false;

    if (cause == SelectionChangedCause.longPress) return true;

    if (_controller.text.isNotEmpty) return true;

    return false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // See AutomaticKeepAliveClientMixin.
    assert(() {
      return _controller._textSpan
          .visitChildren((InlineSpan span) => span.runtimeType == TextSpan);
    }(),
        'SelectableText only supports TextSpan; Other type of InlineSpan is not allowed');
    assert(debugCheckHasMediaQuery(context));
    assert(debugCheckHasDirectionality(context));
    assert(
      !(widget.style != null &&
          widget.style.inherit == false &&
          (widget.style.fontSize == null || widget.style.textBaseline == null)),
      'inherit false style must supply fontSize and textBaseline',
    );

    final FocusNode focusNode = _effectiveFocusNode;
    TextStyle effectiveTextStyle = widget.style;

    final textSelectionControls = ReaderTextSelectionControls(onHighlight: () {
      final TextEditingValue value = _editableText.textEditingValue;
      print('Highlight: ${value.selection.textInside(value.text)}');
      widget.onHighlight(value.selection.start, value.selection.end);
    });

    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    final Widget child = RepaintBoundary(
      child: EditableText(
        key: editableTextKey,
        style: effectiveTextStyle,
        readOnly: true,
        textWidthBasis: defaultTextStyle.textWidthBasis,
        showSelectionHandles: _showSelectionHandles,
        showCursor: false,
        controller: _controller,
        focusNode: focusNode,

        strutStyle: StrutStyle.disabled,
        textAlign: defaultTextStyle.textAlign ?? TextAlign.start,
        maxLines: null,
//        textDirection: widget.textDirection,
//        textScaleFactor: widget.textScaleFactor,
//        autofocus: widget.autofocus,
        forceLine: false,
//        toolbarOptions: widget.toolbarOptions,
//        maxLines: widget.maxLines ?? defaultTextStyle.maxLines,
        selectionColor: Colors.blue, //TODO: Hardcoded, use theme
        selectionControls:
            widget.selectionEnabled ? textSelectionControls : null,
        onSelectionChanged: _handleSelectionChanged,
        onSelectionHandleTapped: _handleSelectionHandleTapped,
        rendererIgnoresPointer: true,
//        cursorWidth: widget.cursorWidth,
//        cursorRadius: cursorRadius,
        cursorColor: Colors.green, //TODO: Hardcoded, use theme
//        cursorOpacityAnimates: cursorOpacityAnimates,
//        cursorOffset: cursorOffset,
//        paintCursorAboveText: paintCursorAboveText,
        backgroundCursorColor: CupertinoColors.inactiveGray,
//        enableInteractiveSelection: widget.enableInteractiveSelection,
//        dragStartBehavior: widget.dragStartBehavior,
//        scrollPhysics: widget.scrollPhysics,
      ),
    );

    return Semantics(
      onTap: () {
        if (!_controller.selection.isValid)
          _controller.selection =
              TextSelection.collapsed(offset: _controller.text.length);
        _effectiveFocusNode.requestFocus();
      },
      onLongPress: () {
        _effectiveFocusNode.requestFocus();
      },
      child: _selectionGestureDetectorBuilder.buildGestureDetector(
        behavior: HitTestBehavior.translucent,
        child: child,
      ),
    );
  }

  @override
  final GlobalKey<EditableTextState> editableTextKey =
      GlobalKey<EditableTextState>();

  @override
  bool get forcePressEnabled => true;

  @override
  bool get selectionEnabled => true;

  @override
  bool get wantKeepAlive => true;
}

/// Custom TextEditingController?
class _TextSpanEditingController extends TextEditingController {
  _TextSpanEditingController({@required TextSpan textSpan})
      : assert(textSpan != null),
        _textSpan = textSpan,
        super(text: textSpan.toPlainText());

  final TextSpan _textSpan;

  @override
  TextSpan buildTextSpan({TextStyle style, bool withComposing}) => _textSpan;
}

/// Overrides custom gesture behaviors
class _ReaderTextSelectionGestureDetectorBuilder
    extends TextSelectionGestureDetectorBuilder {
  _ReaderTextSelectionGestureDetectorBuilder({
    @required _SelectableReaderTextState state,
  }) : super(delegate: state);

  @override
  void onForcePressStart(ForcePressDetails details) {
    super.onForcePressStart(details);
    HapticFeedback.lightImpact();
  }

  @override
  void onSingleLongTapStart(LongPressStartDetails details) {
    if (delegate.selectionEnabled) {
      renderEditable.selectWord(cause: SelectionChangedCause.tap);
    }
    HapticFeedback.lightImpact();
  }

  @override
  void onSingleLongTapMoveUpdate(LongPressMoveUpdateDetails details) {}

  @override
  void onSingleLongTapEnd(LongPressEndDetails details) {
    editableText.showToolbar();
  }

//  @override
//  void onForcePressEnd(ForcePressDetails details) {
//    super.onForcePressEnd(details);
//    HapticFeedback.lightImpact();
//  }

}

class SolidReaderText extends StatelessWidget {
  final List<ReaderSpan> spans;

  const SolidReaderText({Key key, this.spans}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text.rich(TextSpan(
      children: spans.map((readerSpan) => readerSpan.span).toList(),
    ));
  }
}

abstract class ReaderSpan {
  final TextSpan _span;
  ReaderSpan._(this._span);
  InlineSpan get span;
}

class RegularSpan extends ReaderSpan {
  RegularSpan(TextSpan span) : super._(span);
  @override
  InlineSpan get span => _span;
}

class HighlightedSpan extends ReaderSpan {
  final Key key;
  HighlightedSpan(TextSpan span, {this.key}) : super._(span);
  @override
  InlineSpan get span =>
      WidgetSpan(child: KeyedSubtree(key: key, child: Text.rich(_span)));
}
