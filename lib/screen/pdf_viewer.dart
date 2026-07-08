import 'dart:io'
    show
        Directory,
        File,
        Platform;

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// A full-screen PDF viewer that displays a local PDF file
/// with a download/share button to save it to the device's Downloads folder.
class PdfViewerScreen
    extends
        StatefulWidget {
  const PdfViewerScreen({
    super.key,
    required this.filePath,
    required this.title,
  });

  /// Absolute path to the PDF file on disk.
  final String
  filePath;

  /// Title shown in the app bar.
  final String
  title;

  @override
  State<
    PdfViewerScreen
  >
  createState() =>
      _PdfViewerScreenState();
}

class _PdfViewerScreenState
    extends
        State<
          PdfViewerScreen
        > {
  bool
  _isDownloading =
      false;

  static const Color
  _primaryBlue = Color(
    0xFF0A2E5C,
  );

  /// Saves the PDF to the device's Downloads folder directly.
  /// On Android, it writes to the public Downloads directory.
  /// On iOS, it falls back to the system share sheet.
  Future<
    void
  >
  _downloadFile() async {
    if (_isDownloading) {
      return;
    }
    setState(
      () => _isDownloading = true,
    );

    try {
      final sourceFile = File(
        widget.filePath,
      );
      if (!await sourceFile.exists()) {
        throw Exception(
          'Source file not found',
        );
      }

      final fileName = sourceFile.uri.pathSegments.last;

      if (Platform.isAndroid) {
        // ── ANDROID: Save directly to the public Downloads directory ──
        final downloadsDir = Directory(
          '/storage/emulated/0/Download/',
        );
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(
            recursive: true,
          );
        }

        final savePath =
            '${downloadsDir.path}/$fileName';

        try {
          await sourceFile.copy(
            savePath,
          );
        } catch (_) {
          // On Android < 10, WRITE_EXTERNAL_STORAGE permission may be needed
          final status = await Permission.storage.request();
          if (!status.isGranted) {
            throw Exception(
              'Storage permission denied',
            );
          }
          await sourceFile.copy(
            savePath,
          );
        }

        if (!mounted) {
          return;
        }

        // Open the saved file so the user sees it
        await OpenFilex.open(
          savePath,
        );

        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(
              0xFF1976D2,
            ),
            content: Text(
              'Downloaded to Downloads/$fileName',
            ),
            duration: const Duration(
              seconds: 4,
            ),
            action: SnackBarAction(
              label: 'OPEN',
              textColor: Colors.white,
              onPressed: () => OpenFilex.open(
                savePath,
              ),
            ),
          ),
        );
      } else {
        // ── iOS / others: fall back to system share sheet ──
        await SharePlus.instance.share(
          ShareParams(
            files: [
              XFile(
                widget.filePath,
              ),
            ],
            subject: widget.title,
          ),
        );

        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(
              0xFF1976D2,
            ),
            content: Text(
              '$fileName shared — save it from the share menu',
            ),
            duration: const Duration(
              seconds: 4,
            ),
          ),
        );
      }
    } catch (
      e
    ) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(
            0xFFC62828,
          ),
          content: Text(
            'Could not save file: ${e.toString()}',
          ),
          duration: const Duration(
            seconds: 4,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(
          () => _isDownloading = false,
        );
      }
    }
  }

  @override
  Widget
  build(
    BuildContext
    context,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
          onPressed: () => Navigator.pop(
            context,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 4,
            ),
            child: IconButton(
              icon: _isDownloading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Icon(
                      Icons.download_rounded,
                    ),
              tooltip: 'Save to Downloads',
              onPressed: _isDownloading
                  ? null
                  : _downloadFile,
            ),
          ),
        ],
        elevation: 0,
      ),
      body: SfPdfViewer.file(
        File(
          widget.filePath,
        ),
        enableDoubleTapZooming: true,
        pageSpacing: 8,
      ),
    );
  }
}
