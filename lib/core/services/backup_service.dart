import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class BackupService {
  Future<String> exportJsonBackup(Map<String, dynamic> data) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${directory.path}\\azan_backup_$timestamp.json');
    final payload = jsonEncode(data);
    await file.writeAsString(payload);
    return file.path;
  }

  Future<Map<String, dynamic>?> pickAndReadBackupFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['json'],
    );
    if (result == null || result.files.single.path == null) {
      return null;
    }

    final file = File(result.files.single.path!);
    final content = await file.readAsString();
    final decoded = jsonDecode(content);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid backup file format.');
    }
    return decoded;
  }
}
