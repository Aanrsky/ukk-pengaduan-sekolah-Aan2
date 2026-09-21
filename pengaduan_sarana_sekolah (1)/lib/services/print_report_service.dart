import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrintReportService {
  /// Mencetak laporan pengaduan dalam bentuk PDF.
  ///
  /// Tidak menggunakan Printing.convertHtml(),
  /// sehingga aman digunakan pada Flutter Web.
  static Future<void> printReport({
    required int total,
    required int menunggu,
    required int diproses,
    required int selesai,
    required int ditolak,
    required List<MapEntry<String, int>> categories,
  }) async {
    final pw.Document pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            // ==================================================
            // HEADER
            // ==================================================

            pw.Text(
              'SMP NEGERI 3',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 6),

            pw.Text(
              'Laporan Pengaduan Sarana dan Prasarana Sekolah',
              style: const pw.TextStyle(
                fontSize: 12,
                color: PdfColors.grey700,
              ),
            ),

            pw.SizedBox(height: 25),

            // ==================================================
            // STATISTIK UTAMA
            // ==================================================

            pw.Table(
              border: pw.TableBorder.all(
                color: PdfColors.grey400,
              ),
              children: [
                pw.TableRow(
                  children: [
                    _statCell(
                      'TOTAL',
                      total.toString(),
                    ),
                    _statCell(
                      'MENUNGGU',
                      menunggu.toString(),
                    ),
                    _statCell(
                      'DIPROSES',
                      diproses.toString(),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _statCell(
                      'SELESAI',
                      selesai.toString(),
                    ),
                    _statCell(
                      'DITOLAK',
                      ditolak.toString(),
                    ),
                    _statCell(
                      'DITANGANI',
                      (diproses + selesai).toString(),
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 28),

            // ==================================================
            // REKAP STATUS
            // ==================================================

            pw.Text(
              'Rekap Status Pengaduan',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 10),

            pw.TableHelper.fromTextArray(
              headers: const [
                'Status',
                'Jumlah',
              ],
              data: [
                [
                  'Menunggu',
                  menunggu.toString(),
                ],
                [
                  'Diproses',
                  diproses.toString(),
                ],
                [
                  'Selesai',
                  selesai.toString(),
                ],
                [
                  'Ditolak',
                  ditolak.toString(),
                ],
              ],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blueGrey900,
              ),
              cellPadding: const pw.EdgeInsets.all(8),
              border: pw.TableBorder.all(
                color: PdfColors.grey400,
              ),
            ),

            pw.SizedBox(height: 28),

            // ==================================================
            // DISTRIBUSI KATEGORI
            // ==================================================

            pw.Text(
              'Distribusi Kategori',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 10),

            if (categories.isEmpty)
              pw.Text(
                'Belum ada data kategori.',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              )
            else
              pw.TableHelper.fromTextArray(
                headers: const [
                  'Kategori',
                  'Jumlah',
                  'Persentase',
                ],
                data: categories.map((entry) {
                  final double percentage =
                      total == 0 ? 0.0 : (entry.value / total) * 100;

                  return [
                    entry.key,
                    entry.value.toString(),
                    '${percentage.toStringAsFixed(1)}%',
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.blueGrey900,
                ),
                cellPadding: const pw.EdgeInsets.all(8),
                border: pw.TableBorder.all(
                  color: PdfColors.grey400,
                ),
              ),

            pw.SizedBox(height: 35),

            pw.Divider(),

            pw.SizedBox(height: 8),

            // ==================================================
            // FOOTER
            // ==================================================

            pw.Text(
              'Dicetak dari Sistem Pengaduan Sarana Sekolah.',
              style: const pw.TextStyle(
                fontSize: 9,
                color: PdfColors.grey600,
              ),
            ),
          ];
        },
      ),
    );

    // ========================================================
    // PRINT
    // ========================================================

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async {
        return pdf.save();
      },
    );
  }

  // ==========================================================
  // CELL STATISTIK
  // ==========================================================

  static pw.Widget _statCell(
    String title,
    String value,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: const pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
