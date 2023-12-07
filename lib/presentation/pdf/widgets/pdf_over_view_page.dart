import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:pdf_viewer_app/presentation/core/utils/app_color.dart';
import 'package:pdf_viewer_app/presentation/core/utils/app_style.dart';
import 'package:pdf_viewer_app/presentation/core/utils/app_url.dart';

class PdfOverviewPage extends StatelessWidget {
  const PdfOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> isErrored = ValueNotifier<bool>(false);
    final size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: ValueListenableBuilder(
        valueListenable: isErrored,
        builder: (context, value, child) => value
            ? ErrorBody(size: size)
            : PdfBody(size: size, isErrored: isErrored),
      ),
    );
  }
}

class ErrorBody extends StatelessWidget {
  const ErrorBody({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size.height * 0.8,
      child: const Center(
        child: Text(
          'Error loading PDF',
          style: kTextError,
        ),
      ),
    );
  }
}

class PdfBody extends StatelessWidget {
  const PdfBody({
    super.key,
    required this.size,
    required this.isErrored,
  });

  final Size size;
  final ValueNotifier<bool> isErrored;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            height: size.height * 0.8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: kBorderColor,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: const PDF().cachedFromUrl(
                kPdfUrl,
                placeholder: (progress) => Center(
                  child: CircularProgressIndicator(
                    value: progress,
                  ),
                ),
                errorWidget: (error) => Center(child: Text(error.toString())),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
