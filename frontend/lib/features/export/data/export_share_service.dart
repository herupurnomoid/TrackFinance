import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Service utility untuk penyimpanan berkas sementara ke direktori cache perangkat
/// ([path_provider]) dan pemicu dialog lembar berbagi sistem ([share_plus]) (SYNC-04).
class ExportShareService {
  final Future<Directory> Function() _tempDirProvider;
  final Future<ShareResult> Function(
    List<XFile> files, {
    String? subject,
    String? text,
    Rect? sharePositionOrigin,
  }) _shareFilesLauncher;

  ExportShareService({
    Future<Directory> Function()? tempDirProvider,
    Future<ShareResult> Function(
      List<XFile> files, {
      String? subject,
      String? text,
      Rect? sharePositionOrigin,
    })? shareFilesLauncher,
  })  : _tempDirProvider = tempDirProvider ?? getTemporaryDirectory,
        _shareFilesLauncher = shareFilesLauncher ?? Share.shareXFiles;

  static ExportShareService? _instance;

  /// Singleton instance default untuk [ExportShareService]
  static ExportShareService get instance => _instance ??= ExportShareService();

  @visibleForTesting
  static set instance(ExportShareService service) => _instance = service;

  /// Menyimpan [bytes] berkas ke direktori cache sementara perangkat dengan nama [fileName].
  Future<File> saveTempFile({
    required String fileName,
    required List<int> bytes,
  }) async {
    final dir = await _tempDirProvider();
    final file = File('${dir.path}/$fileName');
    file.writeAsBytesSync(bytes, flush: true);
    return file;
  }

  /// Membuka System Share Sheet untuk berkas di [filePath].
  Future<ShareResult> shareFile({
    required String filePath,
    String? mimeType,
    String? subject,
    String? text,
    Rect? sharePositionOrigin,
  }) async {
    final xFile = XFile(filePath, mimeType: mimeType);
    return await _shareFilesLauncher(
      [xFile],
      subject: subject,
      text: text,
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  /// Menyimpan data berkas ke cache lokal dan langsung memunculkan System Share Sheet.
  Future<File> saveAndShareFile({
    required String fileName,
    required List<int> bytes,
    String? mimeType,
    String? subject,
    String? text,
    Rect? sharePositionOrigin,
  }) async {
    final file = await saveTempFile(fileName: fileName, bytes: bytes);
    await shareFile(
      filePath: file.path,
      mimeType: mimeType,
      subject: subject,
      text: text,
      sharePositionOrigin: sharePositionOrigin,
    );
    return file;
  }
}
