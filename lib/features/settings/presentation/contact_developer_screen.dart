import 'dart:async';

import 'package:azan_app/core/constants/app_constants.dart';
import 'package:azan_app/core/localization/app_localizations.dart';
import 'package:azan_app/core/widgets/app_gradient_button.dart';
import 'package:azan_app/core/widgets/app_surface_card.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactDeveloperScreen extends StatefulWidget {
  const ContactDeveloperScreen({super.key});

  @override
  State<ContactDeveloperScreen> createState() => _ContactDeveloperScreenState();
}

class _ContactDeveloperScreenState extends State<ContactDeveloperScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _sendEmailInBackground = true;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tr('contactDeveloperButton'))),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 24 + bottomPadding),
        children: <Widget>[
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.tr('developerFeedbackHint'),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _messageController,
                  maxLines: 6,
                  maxLength: 1000,
                  decoration: InputDecoration(
                    labelText: l10n.tr('sendSuggestionTitle'),
                    hintText: l10n.tr('sendSuggestionHint'),
                  ),
                ),
                const SizedBox(height: 4),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.tr('sendEmailInBackground')),
                  value: _sendEmailInBackground,
                  onChanged: (value) {
                    setState(() => _sendEmailInBackground = value);
                  },
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: AppGradientButton(
                    onPressed: _sendMessage,
                    icon: Icons.send_rounded,
                    label: l10n.tr('sendMessage'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _openEmailComposer(_messageController.text.trim()),
                    icon: const Icon(Icons.alternate_email_rounded),
                    label: Text(l10n.tr('sendViaEmail')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final l10n = context.l10n;
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      _showSnack(l10n.tr('suggestionEmpty'));
      return;
    }

    if (_sendEmailInBackground) {
      _showSnack(l10n.tr('sendingEmailInBackground'));
      unawaited(_openEmailComposer(message));
    } else {
      _showSnack(l10n.tr('messageSavedLocally'));
    }
    _messageController.clear();
  }

  Future<void> _openEmailComposer(String message) async {
    final l10n = context.l10n;
    final uri = Uri(
      scheme: 'mailto',
      path: AppConstants.developerSupportEmail,
      queryParameters: <String, String>{
        'subject': l10n.tr('suggestionEmailSubject'),
        if (message.isNotEmpty) 'body': message,
      },
    );
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    if (!launched) {
      _showSnack(l10n.tr('openEmailFailed'));
      return;
    }
    _showSnack(l10n.tr('suggestionSentPrompt'));
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
