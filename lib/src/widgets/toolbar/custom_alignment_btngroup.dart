import 'package:flutter/material.dart';

import '../../../flutter_quill.dart';

/// A widget that displays a row of three alignment buttons (left, center, right).
/// This widget allows configuring icon size, colors for selected/unselected states,
/// and background colors for alignment buttons.
class CustomAlignmentButtonGroup extends StatefulWidget {
  const CustomAlignmentButtonGroup({
    required this.controller,
    this.iconSize = 18.0,
    this.selectedIconColor,
    this.unselectedIconColor,
    this.selectedBackgroundColor,
    this.unselectedBackgroundColor,
    this.borderRadius = 2.0,
    this.afterButtonPressed,
    Key? key,
  }) : super(key: key);

  /// The controller for the Quill editor.
  final QuillController controller;

  /// Size of the icons in the alignment buttons.
  final double iconSize;

  /// Color for the selected alignment button's icon.
  final Color? selectedIconColor;

  /// Color for unselected alignment buttons' icons.
  final Color? unselectedIconColor;

  /// Background color for the selected alignment button.
  final Color? selectedBackgroundColor;

  /// Background color for unselected alignment buttons.
  final Color? unselectedBackgroundColor;

  /// Border radius for alignment buttons.
  final double borderRadius;

  /// Callback executed after a button is pressed.
  final VoidCallback? afterButtonPressed;

  @override
  _CustomAlignmentButtonGroupState createState() =>
      _CustomAlignmentButtonGroupState();
}

class _CustomAlignmentButtonGroupState
    extends State<CustomAlignmentButtonGroup> {
  Attribute? _value;

  Style get _selectionStyle => widget.controller.getSelectionStyle();

  @override
  void initState() {
    super.initState();
    _value = _selectionStyle.attributes[Attribute.align.key] ??
        Attribute.leftAlignment;
    widget.controller.addListener(_didChangeEditingValue);
  }

  @override
  void didUpdateWidget(covariant CustomAlignmentButtonGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_didChangeEditingValue);
      widget.controller.addListener(_didChangeEditingValue);
      _value = _selectionStyle.attributes[Attribute.align.key] ??
          Attribute.leftAlignment;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_didChangeEditingValue);
    super.dispose();
  }

  void _didChangeEditingValue() {
    setState(() {
      _value = _selectionStyle.attributes[Attribute.align.key] ??
          Attribute.leftAlignment;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use provided colors or fall back to theme defaults
    final selectedIconColor =
        widget.selectedIconColor ?? theme.primaryIconTheme.color;
    final unselectedIconColor =
        widget.unselectedIconColor ?? theme.iconTheme.color;
    final selectedBackgroundColor =
        widget.selectedBackgroundColor ?? theme.primaryColor;
    final unselectedBackgroundColor =
        widget.unselectedBackgroundColor ?? theme.canvasColor;

    // List of alignment attributes and their corresponding icons
    final alignments = [
      {'attribute': Attribute.leftAlignment, 'icon': Icons.format_align_left},
      {
        'attribute': Attribute.centerAlignment,
        'icon': Icons.format_align_center
      },
      {'attribute': Attribute.rightAlignment, 'icon': Icons.format_align_right},
    ];

    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          alignments.length,
          (index) {
            final attribute =
                alignments[index]['attribute'] as Attribute<String?>;
            final icon = alignments[index]['icon'] as IconData;
            final isSelected = _value?.value == attribute.value;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (_value?.value == attribute.value) {
                    // If already selected, unselect (default to left align)
                    widget.controller.formatSelection(Attribute.leftAlignment);
                  } else {
                    widget.controller.formatSelection(attribute);
                  }
                  widget.afterButtonPressed?.call();
                },
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: Container(
                  height: widget.iconSize * kIconButtonFactor,
                  width: widget.iconSize * kIconButtonFactor,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? selectedBackgroundColor
                        : unselectedBackgroundColor,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                  ),
                  child: Icon(
                    icon,
                    size: widget.iconSize,
                    color: isSelected ? selectedIconColor : unselectedIconColor,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
