import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../models/debt_model.dart';

class ImportExportService {
  Future<void> exportDebts(List<Debt> debts, String format) async {
    bool hasPermission = false;
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      if (deviceInfo.version.sdkInt >= 33) {
        hasPermission = true;
      } else {
        hasPermission = await Permission.storage.request().isGranted;
      }
    } else {
      hasPermission = await Permission.storage.request().isGranted;
    }

    if (hasPermission) {
      String? content;
      String fileName = 'debts_export_${DateTime.now().toIso8601String().replaceAll(':', '-').replaceAll('.', '-').replaceAll('T', '_')}';

      if (format == 'json') {
        content = jsonEncode(debts.map((d) => d.toMap()).toList());
        fileName += '.json';
      } else if (format == 'csv') {
        List<List<dynamic>> rows = [];
        rows.add([
          'phoneNumber',
          'name',
          'amount',
          'date',
          'note',
          'status',
          'lastUpdated',
        ]);
        for (var debt in debts) {
          rows.add([
            debt.phoneNumber,
            debt.name,
            debt.amount,
            debt.date.toIso8601String(),
            debt.note,
            debt.status,
            debt.lastUpdated.millisecondsSinceEpoch,
          ]);
        }
        content = const ListToCsvConverter().convert(rows);
        fileName += '.csv';
      }

      if (content != null) {
        if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
          String? outputFile = await FilePicker.platform.saveFile(
            fileName: fileName,
            type: FileType.custom,
            allowedExtensions: [format],
          );
          final file = File(outputFile);
          await file.writeAsString(content);
          // Optionally, provide user feedback that the file has been saved.
          // For example, using a SnackBar in Flutter.
          // Since this is a service, we can't directly show UI,
          // but the calling UI layer can handle this.
                } else {
          final directory = await getTemporaryDirectory();
          final file = File('${directory.path}/$fileName');
          await file.writeAsString(content);
          await Share.shareXFiles([XFile(file.path)]);
        }
      }
    }
  }

  Future<List<Debt>?> importDebts() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'csv'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final extension = result.files.single.extension;

      List<Debt> importedDebts = [];

      if (extension == 'json') {
        final List<dynamic> jsonList = jsonDecode(content);
        importedDebts = jsonList.map((json) => Debt.fromMap(json)).toList();
      } else if (extension == 'csv') {
        final List<List<dynamic>> rows = const CsvToListConverter().convert(
          content,
        );
        if (rows.length > 1) {
          // Skip header row
          for (int i = 1; i < rows.length; i++) {
            final row = rows[i];
            importedDebts.add(
              Debt(
                phoneNumber: row[0].toString(),
                name: row[1].toString(),
                amount: double.parse(row[2].toString()),
                date: DateTime.parse(row[3].toString()),
                note: row[4].toString(),
                status: row[5].toString(),
                lastUpdated: DateTime.fromMillisecondsSinceEpoch(
                  int.parse(row[6].toString()),
                ),
              ),
            );
          }
        }
      }
      return importedDebts;
    }
    return null;
  }
}