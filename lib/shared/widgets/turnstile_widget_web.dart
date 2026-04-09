// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:js_interop';
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';

extension type _Window(JSObject _) implements JSObject {
  external set _kulinarTurnstileCallback(JSFunction f);
  external set _kulinarTurnstileExpired(JSFunction f);
}

class TurnstileWidget extends StatefulWidget {
  final String siteKey;
  final Function(String) onTokenReceived;
  final VoidCallback? onTokenExpired;

  const TurnstileWidget({
    super.key,
    required this.siteKey,
    required this.onTokenReceived,
    this.onTokenExpired,
  });

  @override
  State<TurnstileWidget> createState() => _TurnstileWidgetWebState();
}

class _TurnstileWidgetWebState extends State<TurnstileWidget> {
  static int _counter = 0;
  late final String _viewId;

  @override
  void initState() {
    super.initState();
    _counter++;
    _viewId = 'turnstile-$_counter';

    final win = _Window(globalContext);
    win._kulinarTurnstileCallback = ((JSString token) {
      widget.onTokenReceived(token.toDart);
    }).toJS;
    win._kulinarTurnstileExpired = (() {
      widget.onTokenExpired?.call();
    }).toJS;

    ui.platformViewRegistry.registerViewFactory(_viewId, (int id) {
      return html.DivElement()
        ..className = 'cf-turnstile'
        ..setAttribute('data-sitekey', widget.siteKey)
        ..setAttribute('data-callback', '_kulinarTurnstileCallback')
        ..setAttribute('data-expired-callback', '_kulinarTurnstileExpired')
        ..setAttribute('data-theme', 'dark')
        ..setAttribute('data-language', 'hr');
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 70, child: HtmlElementView(viewType: _viewId));
  }
}
