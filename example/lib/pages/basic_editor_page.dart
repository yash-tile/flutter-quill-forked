import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:tuple/tuple.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import 'package:flutter_quill/src/utils/font.dart';

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

  // HTML content to convert to Delta
  final String _testHtmlContent = '''
<div>
<strong>sdfasf<br></strong><em>sdfasdf<br></em><em><del>sdfasfd<br></del></em><em style="text-decoration:underline;">fdsafaf</em>
</div><h1><em>sdfsdaf</em></h1><ul>
<li>sdfaf</li>
<li>dsfa</li>
</ul><ol>
<li>dsafsf</li>
<li>dsaf</li>
</ol><div>sdfadfa</div>
''';

  @override
  void initState() {
    super.initState();

    // Initialize with empty document
    _controller = QuillController.basic();

    // Convert HTML to Delta and set it in the controller
    _loadHtmlContent();

    // Listen for changes to add a new line when reaching the end
    _controller.document.changes.listen((event) {
      setState(() {
        // This will trigger a rebuild when content changes
      });
    });
  }

  // Method to convert HTML to Delta and load it into the editor
  void _loadHtmlContent() {
    try {
      // Create an instance of HtmlToDelta
      final converter = HtmlToDelta();
      // Convert HTML to Delta
      final delta = converter.convert(_testHtmlContent);
      // The delta returned from HtmlToDelta is compatible with dart_quill_delta
      // We need to convert it to a format that flutter_quill can use
      final document = Document.fromJson(delta.toJson());
      // Create a new QuillController with the document
      _controller = QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0));
      setState(() {});
    } catch (e) {
      print('Error converting HTML to Delta: $e');
    }
  }

  // Method to convert Delta to HTML
  void _convertDeltaToHtml() {
    try {
      // Get the Delta from the controller
      final delta = _controller.document.toDelta();

      // Create a converter instance
      final converter = QuillDeltaToHtmlConverter(
        delta.toJson().cast<Map<String, dynamic>>(),
        ConverterOptions.forEmail(),
      );

      // Convert the Delta to HTML
      final html = converter.convert();

      // Print HTML to console for copying
      print('CONVERTED HTML:');
      print(html);

      // Show a snackbar to inform user where to find the HTML
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('HTML output printed to console/terminal'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error converting Delta to HTML: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
    const double toolOptionPadding = 8.0;
    const double toolOptionIconSize = 16.0;
    const double verticalDividerWidth = 14.0;

    QuillIconTheme iconTheme = QuillIconTheme(
      iconSelectedColor: Colors.black,
      iconUnselectedColor: Colors.black,
      iconSelectedFillColor: Colors.orange[200],
      iconUnselectedFillColor: Colors.transparent,
      borderRadius: 10,
    );

    final fontSizes = {
      '10': '10',
      '12': '12',
      '14': '14',
      '16': '16',
      '18': '18',
    };
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
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
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
                    // Toolbar
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          // first row of toolbox
                          IntrinsicHeight(
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // basic text editing buttons
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: toolOptionPadding),
                                  child: ColorButton(
                                    icon: Icons.format_color_text,
                                    controller: _controller,
                                    background: false,
                                    iconTheme: iconTheme,
                                    iconSize: toolOptionIconSize,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: toolOptionPadding),
                                  child: ColorButton(
                                    icon: Icons.format_color_fill,
                                    controller: _controller,
                                    background: true,
                                    iconTheme: iconTheme,
                                    iconSize: toolOptionIconSize,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: toolOptionPadding),
                                  child: ToggleStyleButton(
                                    attribute: Attribute.bold,
                                    icon: Icons.format_bold,
                                    controller: _controller,
                                    iconTheme: iconTheme,
                                    iconSize: toolOptionIconSize,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: toolOptionPadding),
                                  child: ToggleStyleButton(
                                    attribute: Attribute.italic,
                                    icon: Icons.format_italic,
                                    controller: _controller,
                                    iconTheme: iconTheme,
                                    iconSize: toolOptionIconSize,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: toolOptionPadding),
                                  child: ToggleStyleButton(
                                    attribute: Attribute.underline,
                                    icon: Icons.format_underline,
                                    controller: _controller,
                                    iconTheme: iconTheme,
                                    iconSize: toolOptionIconSize,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: toolOptionPadding),
                                  child: ToggleStyleButton(
                                    attribute: Attribute.strikeThrough,
                                    icon: Icons.format_strikethrough,
                                    controller: _controller,
                                    iconTheme: iconTheme,
                                    iconSize: toolOptionIconSize,
                                  ),
                                ),

                                VerticalDivider(
                                  width: verticalDividerWidth,
                                  thickness: 1,
                                  color: Colors.grey.shade200,
                                ),

                                // undo and redo buttons
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: toolOptionPadding),
                                  child: HistoryButton(
                                    icon: Icons.undo_outlined,
                                    controller: _controller,
                                    undo: true,
                                    iconTheme: iconTheme,
                                    iconSize: toolOptionIconSize,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: toolOptionPadding),
                                  child: HistoryButton(
                                    icon: Icons.redo_outlined,
                                    controller: _controller,
                                    undo: false,
                                    iconTheme: iconTheme,
                                    iconSize: toolOptionIconSize,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            height: 0,
                            thickness: 1,
                            color: Colors.grey.shade200,
                          ),
                          // second row of toolbox
                          IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: toolOptionPadding),
                                  child: QuillFontSizeButton(
                                    iconTheme: iconTheme,
                                    iconSize: toolOptionIconSize,
                                    attribute: Attribute.size,
                                    controller: _controller,
                                    items: [
                                      for (MapEntry<String, String> fontSize
                                          in fontSizes.entries)
                                        PopupMenuItem<String>(
                                          key: ValueKey(fontSize.key),
                                          value: fontSize.value,
                                          child: Text(fontSize.key.toString(),
                                              style: TextStyle(
                                                  color: fontSize.value == '0'
                                                      ? Colors.red
                                                      : null)),
                                        ),
                                    ],
                                    onSelected: (newSize) {
                                      _controller.formatSelection(
                                          Attribute.fromKeyValue(
                                              'size',
                                              newSize == '0'
                                                  ? null
                                                  : getFontSize(newSize)));
                                    },
                                    rawItemsMap: fontSizes,
                                  ),
                                ),
                                VerticalDivider(
                                  width: 0,
                                  thickness: 1,
                                  color: Colors.grey.shade200,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: toolOptionPadding),
                                  child: CustomAlignmentButtonGroup(
                                    controller: _controller,
                                    unselectedIconColor:
                                        iconTheme.iconUnselectedColor,
                                    selectedIconColor:
                                        iconTheme.iconSelectedColor,
                                    unselectedBackgroundColor:
                                        iconTheme.iconUnselectedFillColor,
                                    selectedBackgroundColor:
                                        iconTheme.iconSelectedFillColor,
                                    borderRadius: iconTheme.borderRadius ?? 2,
                                    leftAlignmentIcon: Icons.format_align_left,
                                    centerAlignmentIcon:
                                        Icons.format_align_center,
                                    rightAlignmentIcon:
                                        Icons.format_align_right,
                                    iconSize: toolOptionIconSize,
                                  ),
                                ),
                                VerticalDivider(
                                  width: 0,
                                  thickness: 1,
                                  color: Colors.grey.shade200,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: toolOptionPadding),
                                  child: ToggleStyleButton(
                                    attribute: Attribute.ol,
                                    controller: _controller,
                                    icon: Icons.format_list_numbered,
                                    iconTheme: iconTheme,
                                    iconSize: toolOptionIconSize,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: toolOptionPadding),
                                  child: ToggleStyleButton(
                                    attribute: Attribute.ul,
                                    controller: _controller,
                                    icon: Icons.format_list_bulleted,
                                    iconTheme: iconTheme,
                                    iconSize: toolOptionIconSize,
                                  ),
                                ),
                                // VerticalDivider(
                                //   width: verticalDividerWidth,
                                //   thickness: 1,
                                //   color: customColorScheme.border_07,
                                // ),
                                // // insert link button
                                // Padding(
                                //   padding: const EdgeInsets.only(top: toolOptionPadding),
                                //   child: quill.LinkStyleButton(
                                //     controller: widget.controller,
                                //     icon: Icons.link,
                                //     iconTheme: iconTheme,
                                //     iconSize: toolOptionIconSize,
                                //     // dialogTheme: dialogTheme,
                                //   ),
                                // ),

                                // // indent and outdent buttons
                                // quill.IndentButton(
                                //   icon: Icons.format_indent_increase,
                                //   controller: widget.controller,
                                //   isIncrease: true,
                                //   iconTheme: iconTheme,
                                // ),
                                // quill.IndentButton(
                                //   icon: Icons.format_indent_decrease,
                                //   controller: widget.controller,
                                //   isIncrease: false,
                                //   iconTheme: iconTheme,
                                // ),
                              ],
                            ),
                          ),
                        ],
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
                      height: 400,
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
              const SizedBox(height: 20),
              // Submit button to convert Delta to HTML
              ElevatedButton(
                onPressed: _convertDeltaToHtml,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[200],
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Convert to HTML'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///Text field with suffix icon
Widget textFieldBoxWithSuffix(
    context,
    Function() onTap,
    FocusNode focusNode,
    TextEditingController controller,
    String label,
    TextInputType keyboardType,
    bool error,
    String errorMessage,
    void Function(String)? onChanged,
    String suffixIconPath,
    VoidCallback? suffixIconOnPressed,
    {bool enableInteractiveSelection = true}) {
  return TextField(
    scrollPadding: const EdgeInsets.only(bottom: 40),
    keyboardType: keyboardType,
    autocorrect: false,
    enableSuggestions: false,
    onTap: onTap,
    onChanged: onChanged,
    focusNode: focusNode,
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      suffixIcon: Container(
        margin: const EdgeInsets.only(right: 8),
        child: IconButton(
          splashRadius: 20,
          onPressed: suffixIconOnPressed,
          icon: const Icon(Icons.person),
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      errorStyle: const TextStyle(color: Colors.red),
      errorText: error ? errorMessage : null,
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      labelStyle: const TextStyle(fontSize: 13, color: Colors.black),
    ),
    controller: controller,
    enableInteractiveSelection: enableInteractiveSelection,
  );
}
