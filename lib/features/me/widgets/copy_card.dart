import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:artisnal_app/core/l10n/app_text.dart';

const _ink = Color(0xFF152322);
const _muted = Color(0xFF4F5F5D);
const _teal = Color(0xFF1B7574);
const _cardBorder = Color(0xFFE4EEEC);

/// Words with one Copy button, which says when it has worked.
class CopyCard extends StatefulWidget {
  const CopyCard({super.key, required this.text, this.label});

  final String text;
  final String? label;

  @override
  State<CopyCard> createState() => _CopyCardState();
}

class _CopyCardState extends State<CopyCard> {
  bool _copied = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    var worked = true;
    try {
      await Clipboard.setData(
        ClipboardData(text: widget.text),
      ).timeout(const Duration(seconds: 3));
    } on PlatformException {
      worked = false;
    } on TimeoutException {
      worked = false;
    }
    if (!mounted) return;
    if (!worked) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              tr('Could not copy. Select the words and copy them.'),
              style: appType(color: Colors.white),
            ),
          ),
        );
      return;
    }
    setState(() => _copied = true);
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.label;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Text(
              tr(label),
              style: appType(
                color: _muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SelectableText(
              widget.text,
              style: appType(color: _ink, fontSize: 14, height: 1.4),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _copy,
              style: TextButton.styleFrom(foregroundColor: _teal),
              icon: Icon(
                _copied ? Icons.check_rounded : Icons.copy_rounded,
                size: 18,
              ),
              label: Text(
                tr(_copied ? 'Copied' : 'Copy'),
                style: appType(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
