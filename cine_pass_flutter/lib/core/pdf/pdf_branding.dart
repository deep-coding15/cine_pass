import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Logo optionnel : placez `assets/images/logo.png` pour l’afficher dans les PDF.
const String kCinePassPdfLogoAsset = 'assets/images/logo.png';

/// En-tête commun (logo + titre) pour les exports PDF.
Future<pw.Widget> cinePassPdfHeader({
  required String title,
  String? subtitle,
}) async {
  pw.ImageProvider? logo;
  try {
    final data = await rootBundle.load(kCinePassPdfLogoAsset);
    logo = pw.MemoryImage(data.buffer.asUint8List());
  } catch (_) {}

  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      if (logo != null)
        pw.Image(logo, width: 44, height: 44, fit: pw.BoxFit.contain)
      else
        pw.Container(
          width: 44,
          height: 44,
          decoration: pw.BoxDecoration(
            color: PdfColors.red700,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Center(
            child: pw.Text(
              'CP',
              style: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      pw.SizedBox(width: 12),
      pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            if (subtitle != null && subtitle.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Text(subtitle, style: const pw.TextStyle(fontSize: 11)),
            ],
          ],
        ),
      ),
    ],
  );
}
