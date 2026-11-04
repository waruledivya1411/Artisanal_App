import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:artisnal_app/core/l10n/app_text.dart';
import 'package:artisnal_app/features/learn/data/learn_task_chain.dart';
import 'package:artisnal_app/features/learn/data/learn_tasks.dart';
import 'package:artisnal_app/features/learn/data/saved_work.dart';

/// Opens from an earned badge: what the artisan wrote for that task, and good
/// bios and captions ready to copy.
class BadgeWorkScreen extends StatelessWidget {
  const BadgeWorkScreen({super.key, required this.taskId});

  final String taskId;

  static const Color background = Color(0xFFF6F7F4);
  static const Color teal = Color(0xFF1B7574);
  static const Color ink = Color(0xFF152322);
  static const Color muted = Color(0xFF4F5F5D);
  static const Color gold = Color(0xFFC5922E);
  static const Color cardBorder = Color(0xFFE4EEEC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip: tr('Back'),
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded),
                color: ink,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFF6E7C8), gold],
                  ),
                ),
                child: const Icon(
                  Icons.military_tech_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              tr(LearnTaskChain.titleFor(taskId)),
              textAlign: TextAlign.center,
              style: appType(
                color: ink,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              tr(LearnTaskChain.badgeLineFor(taskId)),
              textAlign: TextAlign.center,
              style: appType(color: muted, fontSize: 14, height: 1.35),
            ),
            ..._sections(),
          ],
        ),
      ),
    );
  }

  List<Widget> _sections() {
    final work = SavedWork.instance;
    switch (taskId) {
      case setUpPageTaskId:
        return [
          const _Heading('Your work'),
          if (!work.hasPage)
            const _NothingYet()
          else ...[
            _Details(
              rows: [
                ('Name', work.name),
                ('Username', work.username),
                ('Category', work.category == null ? null : tr(work.category!)),
              ],
            ),
            if (work.bio case final bio? when bio.isNotEmpty) ...[
              const SizedBox(height: 10),
              _CopyCard(label: 'Bio', text: bio),
            ],
          ],
          const _Heading('Bio ideas'),
          for (final idea in bioIdeas) _CopyCard(text: tr(idea)),
        ];
      case LearnTaskChain.createPostTaskId:
        return [
          const _Heading('Your caption'),
          if (work.caption case final caption? when caption.isNotEmpty)
            _CopyCard(text: caption)
          else
            const _NothingYet(),
          const _Heading('Caption ideas'),
          for (final idea in captionIdeas) _CopyCard(text: tr(idea)),
        ];
      case aiPhotosTaskId:
        return [
          const _Heading('Your last prompt'),
          if (work.aiPrompt case final prompt? when prompt.isNotEmpty)
            _CopyCard(text: prompt)
          else
            const _NothingYet(),
        ];
      default:
        return const [];
    }
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Text(
        tr(text),
        style: appType(
          color: BadgeWorkScreen.ink,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _NothingYet extends StatelessWidget {
  const _NothingYet();

  @override
  Widget build(BuildContext context) {
    return Text(
      tr('Nothing saved yet.'),
      style: appType(color: BadgeWorkScreen.muted, fontSize: 14),
    );
  }
}

BoxDecoration _cardDecoration() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(color: BadgeWorkScreen.cardBorder),
);

class _Details extends StatelessWidget {
  const _Details({required this.rows});

  final List<(String, String?)> rows;

  @override
  Widget build(BuildContext context) {
    final filled = [
      for (final row in rows)
        if (row.$2 != null && row.$2!.isNotEmpty) row,
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (index, row) in filled.indexed) ...[
            if (index > 0) const SizedBox(height: 10),
            Text(
              tr(row.$1),
              style: appType(
                color: BadgeWorkScreen.muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            SelectableText(
              row.$2!,
              style: appType(
                color: BadgeWorkScreen.ink,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Words with one Copy button, which says when it has worked.
class _CopyCard extends StatefulWidget {
  const _CopyCard({required this.text, this.label});

  final String text;
  final String? label;

  @override
  State<_CopyCard> createState() => _CopyCardState();
}

class _CopyCardState extends State<_CopyCard> {
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
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Text(
              tr(label),
              style: appType(
                color: BadgeWorkScreen.muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SelectableText(
              widget.text,
              style: appType(
                color: BadgeWorkScreen.ink,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _copy,
              style: TextButton.styleFrom(
                foregroundColor: BadgeWorkScreen.teal,
              ),
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
