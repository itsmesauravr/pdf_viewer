// ignore_for_file: use_build_context_synchronously, must_be_immutable
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf_viewer_app/presentation/pdf/widgets/pdf_over_view_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/app_color.dart';
import '../core/utils/app_style.dart';
import '../core/utils/app_url.dart';

class PdfPage extends StatelessWidget {
  PdfPage({super.key});

  String? filename;
  String? path;

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        title: const Text(
          'PDF View',
          style: kTextTitle,
        ),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
      ),
      body: Stack(
        children: [
          const PdfOverviewPage(),
          ValueListenableBuilder(
            valueListenable: isLoading,
            builder: (context, value, child) => value
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : const SizedBox(),
          ),
        ],
      ),
      bottomSheet: Container(
        height: 60,
        color: kPrimaryColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: kPurpleColor,
                child: IconButton(
                  onPressed: () async {
                    await _shareFile();
                  },
                  icon: const Icon(Icons.share),
                  color: kPrimaryColor,
                ),
              ),
              CircleAvatar(
                backgroundColor: kPurpleColor,
                child: IconButton(
                  onPressed: () async {
                    _downloadFile(context);
                  },
                  icon: const Icon(Icons.download),
                  color: kPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadFile(BuildContext context) async {
    isLoading.value = true;
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    final localPath = (await _findLocalPath())!;
    final savedDir = Directory(localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    var client = http.Client();
    try {
      var response = await client.get(Uri.parse(kPdfUrl));
      if (response.statusCode == 200) {
        File file = File(
            "${savedDir.path}/${DateTime.now().microsecondsSinceEpoch}.pdf");
        await file.writeAsBytes(response.bodyBytes);
        await _saveFilePath(file.path);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File downloaded successfully'),
          ),
        );
        debugPrint("File downloaded successfully: ${file.path}");
      } else {
        debugPrint("Failed to download file.: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error during download: $e");
    } finally {
      client.close();
      isLoading.value = false;
    }
  }

  Future<void> _saveFilePath(String path) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('downloaded_file_path', path);
  }

  Future<String?> _getFilePath() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString('downloaded_file_path');
  }

  Future<void> _shareFile() async {
    String? filePath = await _getFilePath();
    if (filePath != null) {
      // ignore: deprecated_member_use
      await Share.shareFiles([filePath]);
    } else {
      debugPrint('File path not found in shared preferences');
    }
  }

  Future<String?> _findLocalPath() async {
    if (Platform.isAndroid) {
      return "/sdcard/download";
    } else {
      var directory = await getApplicationDocumentsDirectory();
      return '${directory.path}${Platform.pathSeparator}Download';
    }
  }
}
