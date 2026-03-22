import 'package:barcode/barcode.dart';
import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/pdf/pdf_branding.dart';

/// Génère un PDF téléchargeable / partageable avec le même QR que dans l’app.
Future<void> shareBilletPdf(BilletGroupResponse billet) async {
  final qrData = 'CINEPASS-${billet.id}';
  final header = await cinePassPdfHeader(title: 'CinePass — Billet');
  final pdf = pw.Document();
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context ctx) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            header,
            pw.SizedBox(height: 12),
            pw.Divider(thickness: 1),
            pw.SizedBox(height: 16),
            pw.Text(
              billet.title,
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Réservation n° ${billet.id}'),
            pw.SizedBox(height: 6),
            pw.Text(billet.location),
            pw.SizedBox(height: 6),
            pw.Text(billet.dateTime),
            if (billet.room != null && billet.room!.isNotEmpty) ...[
              pw.SizedBox(height: 6),
              pw.Text('Salle : ${billet.room}'),
            ],
            if (billet.seats != null && billet.seats!.isNotEmpty) ...[
              pw.SizedBox(height: 6),
              pw.Text('Sièges : ${billet.seats!.join(', ')}'),
            ],
            pw.SizedBox(height: 10),
            pw.Text(
              'Montant : ${billet.totalAmount.toStringAsFixed(2)} MAD',
            ),
            pw.SizedBox(height: 28),
            pw.Center(
              child: pw.Column(
                children: [
                  pw.BarcodeWidget(
                    barcode: Barcode.qrCode(),
                    data: qrData,
                    width: 180,
                    height: 180,
                  ),
                  pw.SizedBox(height: 12),
                  pw.Text(
                    'Présentez ce QR code à l’entrée',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    qrData,
                    style: pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
            pw.Spacer(),
            pw.Text(
              'Un seul QR code pour l’ensemble des billets de cette réservation.',
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          ],
        );
      },
    ),
  );

  await Printing.sharePdf(
    bytes: await pdf.save(),
    filename: 'cinepass-billet-${billet.id}.pdf',
  );
}
