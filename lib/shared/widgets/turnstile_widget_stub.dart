import 'package:flutter/material.dart';

class TurnstileWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
