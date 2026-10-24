import 'package:flutter/material.dart';
import 'package:artisnal_app/core/l10n/app_text.dart';

class NextLearnTaskButton extends StatelessWidget {
  const NextLearnTaskButton({
    super.key,
    this.locale = 'en-US',
    required this.nextTaskTitle,
    required this.onTap,
  });

  final String locale;
  final String nextTaskTitle;
  final VoidCallback onTap;

  static const Color teal = Color(0xFF1B7574);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFD5E8E6), width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 56,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chevron_right_rounded, color: teal, size: 22),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  tr('Next task: $nextTaskTitle'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: appType(
                    color: teal,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
