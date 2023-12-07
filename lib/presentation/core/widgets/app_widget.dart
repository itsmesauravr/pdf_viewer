import 'package:flutter/material.dart';
import 'package:pdf_viewer_app/presentation/pdf/pdf_page.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'PDF Viewer App',
      debugShowCheckedModeBanner: false,
      home: PdfPage(),
    );
  }
}
