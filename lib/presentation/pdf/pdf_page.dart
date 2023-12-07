// ignore_for_file: use_build_context_synchronously
import 'dart:io';

import 'package:another_flushbar/flushbar_helper.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_viewer_app/presentation/core/utils/app_url.dart';
import 'package:pdf_viewer_app/presentation/pdf/widgets/pdf_over_view_page.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/utils/app_color.dart';
import '../core/utils/app_style.dart';

class PdfPage extends StatelessWidget {
  PdfPage({super.key});

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
                  onPressed: () {},
                  icon: const Icon(Icons.share),
                  color: kPrimaryColor,
                ),
              ),
              CircleAvatar(
                backgroundColor: kPurpleColor,
                child: IconButton(
                  onPressed: () async {
                    isLoading.value = true;
                    var status = await Permission.storage.status;
                    if (!status.isGranted) {
                      await Permission.storage.request();
                    }
                    Directory? baseStorage;
                    if (Platform.isAndroid) {
                      baseStorage = await getExternalStorageDirectory();
                    } else if (Platform.isIOS) {
                      baseStorage = await getApplicationDocumentsDirectory();
                    }
                    if (baseStorage == null) return;
                    var task = DownloadTask(
                      url: kPdfUrl,
                      filename: '${DateTime.now().millisecondsSinceEpoch}.pdf',
                      directory: '',
                    );
                    final completedTask = await FileDownloader().download(task);
                    if (completedTask.status == TaskStatus.complete) {
                      debugPrint('downloaded');
                      debugPrint("Download Path ${completedTask.task.directory}");
                    }
                    await FileDownloader().openFile(task: task);
                    isLoading.value = false;
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
}
