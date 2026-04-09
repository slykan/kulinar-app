import 'package:flutter/material.dart';

// Na mobilnoj platformi Turnstile preskačemo —
// backend validacija se vrši samo na webu.
// Token šaljemo kao 'mobile-bypass' koji Laravel prihvaća za mobile klijente.
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
  State<TurnstileWidget> createState() => _TurnstileWidgetMobileState();
}

class _TurnstileWidgetMobileState extends State<TurnstileWidget> {
  @override
  void initState() {
    super.initState();
    // Auto-pass na mobilnoj platformi
    Future.microtask(() => widget.onTokenReceived('mobile-bypass'));
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
