import 'package:azan_app/core/localization/app_localizations.dart';
import 'package:azan_app/core/widgets/app_surface_card.dart';
import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final items = <({String question, String answer})>[
      (
        question: l10n.tr('faqQiblaQuestion'),
        answer: l10n.tr('faqQiblaAnswer'),
      ),
      (
        question: l10n.tr('faqLocationQuestion'),
        answer: l10n.tr('faqLocationAnswer'),
      ),
      (
        question: l10n.tr('faqBackupQuestion'),
        answer: l10n.tr('faqBackupAnswer'),
      ),
      (
        question: l10n.tr('faqAudioQuestion'),
        answer: l10n.tr('faqAudioAnswer'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tr('helpFaqButton'))),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 24 + bottomPadding),
        children: <Widget>[
          Text(
            l10n.tr('helpQaSub'),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          AppSurfaceCard(
            child: Column(
              children: items
                  .map(
                    (item) =>
                        _FaqTile(question: item.question, answer: item.answer),
                  )
                  .toList(growable: false),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 10),
        title: Text(
          question,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(answer, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
