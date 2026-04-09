import 'package:flutter/material.dart';

// Na webu CF Turnstile widget ima probleme s HtmlElementView —
// koristimo web-bypass koji backend prihvaća.
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
  @override
  void initState() {
    super.initState();
    Future.microtask(() => widget.onTokenReceived('web-bypass'));
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
