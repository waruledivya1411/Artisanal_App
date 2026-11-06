import 'package:flutter/material.dart';

import 'package:artisnal_app/features/learn/data/learn_progress.dart';
import 'package:artisnal_app/features/learn/data/learn_task_chain.dart';
import 'package:artisnal_app/features/learn/data/saved_work.dart';
import 'package:artisnal_app/core/l10n/app_text.dart';
import 'package:artisnal_app/features/me/widgets/copy_card.dart';

/// The badges in one row, then the words the artisan wrote while practising,
/// each with more ideas to copy.
class MeScreen extends StatefulWidget {
  const MeScreen({super.key, required this.locale});

  final String locale;

  static const Color background = Color(0xFFF6F7F4);
  static const Color teal = Color(0xFF1B7574);
  static const Color ink = Color(0xFF152322);
  static const Color muted = Color(0xFF4F5F5D);
  static const Color gold = Color(0xFFC5922E);
  static const Color track = Color(0xFFEDF2EF);

  @override
  State<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends State<MeScreen> {
  final _progress = LearnProgress.instance;
  final _work = SavedWork.instance;

  @override
  void initState() {
    super.initState();
    _progress.addListener(_onChange);
    _work.addListener(_onChange);
  }

  @override
  void dispose() {
    _progress.removeListener(_onChange);
    _work.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final captions = _work.captions;
    final bio = _work.bio;
    return ColoredBox(
      color: MeScreen.background,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          children: [
            Text(
              tr('Me'),
              style: appType(
                color: MeScreen.ink,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              tr('Finish Learn tasks to unlock your badges.'),
              style: appType(color: MeScreen.muted, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 22),
            Text(
              tr('YOUR BADGES'),
              style: appType(
                color: MeScreen.muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 12),
            // One row; it scrolls sideways when the screen is narrow.
            SizedBox(
              height: 120,
              child: ListView.separated(
                key: const ValueKey('badge-row'),
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: LearnTaskChain.taskOrder.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final taskId = LearnTaskChain.taskOrder[index];
                  return SizedBox(
                    width: 92,
                    child: _BadgeTile(
                      title: LearnTaskChain.titleFor(taskId),
                      unlocked: _progress.isLearnTaskComplete(taskId),
                    ),
                  );
                },
              ),
            ),
            const _Heading('Saved captions'),
            if (captions.isEmpty)
              const _NothingYet()
            else
              for (final caption in captions) CopyCard(text: caption),
            const _SubHeading('Caption ideas'),
            for (final idea in captionIdeas) CopyCard(text: tr(idea)),
            const _Heading('Saved bio'),
            if (bio == null || bio.isEmpty)
              const _NothingYet()
            else
              CopyCard(label: _work.name, text: bio),
            const _SubHeading('Bio ideas'),
            for (final idea in bioIdeas) CopyCard(text: tr(idea)),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 10),
      child: Text(
        tr(text),
        style: appType(
          color: MeScreen.ink,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SubHeading extends StatelessWidget {
  const _SubHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 10),
      child: Text(
        tr(text),
        style: appType(
          color: MeScreen.muted,
          fontSize: 14,
          fontWeight: FontWeight.w700,
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
      style: appType(color: MeScreen.muted, fontSize: 14),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.title, required this.unlocked});

  final String title;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unlocked ? MeScreen.gold : const Color(0xFFE4EEEC),
          width: unlocked ? 1.8 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: unlocked
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFF6E7C8), MeScreen.gold],
                      )
                    : null,
                color: unlocked ? null : MeScreen.track,
              ),
              child: Icon(
                unlocked ? Icons.military_tech_rounded : Icons.lock_rounded,
                color: unlocked ? Colors.white : MeScreen.muted,
                size: unlocked ? 26 : 20,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                tr(title),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: appType(
                  color: unlocked ? MeScreen.ink : MeScreen.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
