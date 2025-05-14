import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:tuple/tuple.dart';

class BasicEditorPage extends StatefulWidget {
  const BasicEditorPage({Key? key}) : super(key: key);

  @override
  State<BasicEditorPage> createState() => _BasicEditorPageState();
}

class _BasicEditorPageState extends State<BasicEditorPage> {
  late QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  // Line height for calculation (approximate height of a line of text)
  final double _lineHeight = 24.0;

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();

    // Listen for changes to add a new line when reaching the end
    _controller.document.changes.listen((event) {
      setState(() {
        // This will trigger a rebuild when content changes
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate approximate line count (simple calculation for demo purposes)
    final text = _controller.document.toPlainText();
    final approxLineCount = text.isEmpty
        ? 1
        : (text.split('\n').length +
            text.length ~/ 40); // Assuming ~40 chars per line

    // Clamp line count between 1 and 3 for height calculation
    final lineCount = approxLineCount.clamp(1, 3);

    // Calculate editor height based on line count
    final editorHeight = _lineHeight * lineCount + 16; // Add padding

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Basic Editor',
          style: TextStyle(color: Colors.black87),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 600,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Toolbar at the top
                Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: QuillToolbar.basic(
                      controller: _controller,
                      showDividers: false,
                      multiRowsDisplay: false,
                      showFontFamily: false,
                      showFontSize: false,
                      showHeaderStyle: false,
                      showListCheck: false,
                      showCodeBlock: false,
                      showInlineCode: false,
                      showSearchButton: false,
                      showColorButton: false,
                      showBackgroundColorButton: false,
                      showIndent: false,
                      showListBullets: false,
                      showListNumbers: false,
                      showQuote: false,
                      showClearFormat: false,
                      showLink: false,
                      showUndo: false,
                      showRedo: false,
                      showDirection: false,
                      showStrikeThrough: false,
                    ),
                  ),
                ),
                // Divider between toolbar and editor
                const Divider(height: 1, thickness: 1),
                // Editor with fixed height based on content
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    color: Colors.white,
                  ),
                  height: editorHeight,
                  padding: const EdgeInsets.all(8),
                  child: QuillEditor(
                    controller: _controller,
                    scrollController: _scrollController,
                    scrollable: true,
                    focusNode: _focusNode,
                    autoFocus: false,
                    readOnly: false,
                    placeholder: 'Type your message...',
                    expands: false,
                    padding: EdgeInsets.zero,
                    customStyles: DefaultStyles(
                      paragraph: DefaultTextBlockStyle(
                        const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          height: 1.3,
                        ),
                        const Tuple2(0, 0),
                        const Tuple2(0, 0),
                        null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
