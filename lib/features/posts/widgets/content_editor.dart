import 'package:flutter/material.dart';

const _kOrange = Color(0xFFE85D04);
const _kCard = Color(0xFF242424);
const _kCardDark = Color(0xFF1A1A1A);

class ContentEditor extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const ContentEditor({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  State<ContentEditor> createState() => _ContentEditorState();
}

class _ContentEditorState extends State<ContentEditor> {
  void _wrapSelection(String open, String close) {
    final ctrl = widget.controller;
    final sel = ctrl.selection;
    if (!sel.isValid) {
      // If nothing selected, insert placeholder
      final pos = sel.baseOffset < 0 ? ctrl.text.length : sel.baseOffset;
      final newText = ctrl.text.substring(0, pos) + open + close + ctrl.text.substring(pos);
      ctrl.value = ctrl.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: pos + open.length),
      );
      return;
    }
    final text = ctrl.text;
    final selected = sel.textInside(text);
    final newText = text.replaceRange(sel.start, sel.end, '$open$selected$close');
    ctrl.value = ctrl.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(
        offset: sel.start + open.length + selected.length + close.length,
      ),
    );
  }

  void _insertAtCursor(String content) {
    final ctrl = widget.controller;
    final sel = ctrl.selection;
    final pos = (sel.isValid && sel.baseOffset >= 0) ? sel.baseOffset : ctrl.text.length;
    final text = ctrl.text;
    final newText = text.substring(0, pos) + content + text.substring(sel.isValid ? sel.end : pos);
    ctrl.value = ctrl.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: pos + content.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toolbar
        Container(
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
            ),
            border: Border.all(color: Colors.white12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              const Text(
                'Format:',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
              const SizedBox(width: 8),
              _ToolbarBtn(
                label: 'B',
                bold: true,
                tooltip: 'Podebljano',
                onTap: () => _wrapSelection('<strong>', '</strong>'),
              ),
              const SizedBox(width: 4),
              _ToolbarBtn(
                label: 'I',
                italic: true,
                tooltip: 'Kurziv',
                onTap: () => _wrapSelection('<em>', '</em>'),
              ),
              const SizedBox(width: 4),
              _ToolbarBtn(
                label: 'H2',
                tooltip: 'Naslov poglavlja',
                onTap: () => _wrapSelection('\n<h2>', '</h2>\n'),
              ),
              const SizedBox(width: 4),
              _ToolbarBtn(
                icon: Icons.format_list_bulleted,
                tooltip: 'Lista',
                onTap: () => _insertAtCursor('\n<ul>\n  <li></li>\n</ul>\n'),
              ),
              const SizedBox(width: 4),
              _ToolbarBtn(
                icon: Icons.horizontal_rule,
                tooltip: 'Razdjelnik',
                onTap: () => _insertAtCursor('\n<hr>\n'),
              ),
            ],
          ),
        ),
        // Text field
        TextFormField(
          controller: widget.controller,
          style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.6),
          decoration: InputDecoration(
            hintText: 'Upute za pripremu, savjeti...',
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
            contentPadding: const EdgeInsets.all(14),
            filled: true,
            fillColor: _kCardDark,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              borderSide: BorderSide(color: Colors.white12),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              borderSide: BorderSide(color: Colors.white12),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              borderSide: BorderSide(color: _kOrange),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
          maxLines: 18,
          minLines: 10,
          validator: widget.validator,
        ),
      ],
    );
  }
}

class _ToolbarBtn extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final bool bold;
  final bool italic;
  final String tooltip;
  final VoidCallback onTap;

  const _ToolbarBtn({
    this.label,
    this.icon,
    this.bold = false,
    this.italic = false,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF333333),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white12),
          ),
          child: icon != null
              ? Icon(icon, color: Colors.white70, size: 15)
              : Text(
                  label!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: bold ? FontWeight.w900 : FontWeight.w500,
                    fontStyle: italic ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
        ),
      ),
    );
  }
}
