import 'package:azan_app/core/localization/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Amharic app locale loads non-English app strings from assets', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('am'));
    final title = l10n.tr('titleSettings');
    final navHome = l10n.tr('navHome');

    expect(title, isNot('Settings'));
    expect(navHome, isNot('Home'));
  });
}
