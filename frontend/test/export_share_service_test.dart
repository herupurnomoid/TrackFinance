import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';
import 'package:track_finance/features/export/data/export_share_service.dart';

void main() {
  group('ExportShareService Unit Tests (SYNC-04)', () {
    late Directory tempDir;
    late List<XFile> sharedFiles;
    late String? capturedSubject;
    late String? capturedText;
    late Rect? capturedPositionOrigin;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('tf_test_export_');
      sharedFiles = [];
      capturedSubject = null;
      capturedText = null;
      capturedPositionOrigin = null;
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    ExportShareService createTestService() {
      return ExportShareService(
        tempDirProvider: () async => tempDir,
        shareFilesLauncher: (
          List<XFile> files, {
          String? subject,
          String? text,
          Rect? sharePositionOrigin,
        }) async {
          sharedFiles = files;
          capturedSubject = subject;
          capturedText = text;
          capturedPositionOrigin = sharePositionOrigin;
          return const ShareResult('success', ShareResultStatus.success);
        },
      );
    }

    test('saveTempFile writes bytes to the provided temporary directory', () async {
      final service = createTestService();
      final testBytes = [1, 2, 3, 4, 5];

      final file = await service.saveTempFile(
        fileName: 'test_file.csv',
        bytes: testBytes,
      );

      expect(file.existsSync(), isTrue);
      expect(file.path, equals('${tempDir.path}/test_file.csv'));
      expect(file.readAsBytesSync(), equals(testBytes));
    });

    test('shareFile triggers the share launcher with correct parameters', () async {
      final service = createTestService();
      const origin = Rect.fromLTWH(0, 0, 100, 100);

      final result = await service.shareFile(
        filePath: '/tmp/test.pdf',
        mimeType: 'application/pdf',
        subject: 'Subjek Laporan',
        text: 'Teks pesan',
        sharePositionOrigin: origin,
      );

      expect(result.status, equals(ShareResultStatus.success));
      expect(sharedFiles.length, equals(1));
      expect(sharedFiles.first.path, equals('/tmp/test.pdf'));
      expect(sharedFiles.first.mimeType, equals('application/pdf'));
      expect(capturedSubject, equals('Subjek Laporan'));
      expect(capturedText, equals('Teks pesan'));
      expect(capturedPositionOrigin, equals(origin));
    });

    test('saveAndShareFile writes file and immediately launches share sheet', () async {
      final service = createTestService();
      final testData = [65, 66, 67]; // 'ABC'

      final file = await service.saveAndShareFile(
        fileName: 'report.csv',
        bytes: testData,
        mimeType: 'text/csv',
        subject: 'Ekspor CSV',
        text: 'Ini file Anda',
      );

      expect(file.existsSync(), isTrue);
      expect(sharedFiles.length, equals(1));
      expect(sharedFiles.first.path, equals(file.path));
      expect(capturedSubject, equals('Ekspor CSV'));
    });
  });
}
