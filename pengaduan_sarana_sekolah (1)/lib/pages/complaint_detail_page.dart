import 'package:flutter/material.dart';

import 'models/complaint_model.dart';

class ComplaintDetailPage extends StatelessWidget {
  final ComplaintModel complaint;

  const ComplaintDetailPage({
    super.key,
    required this.complaint,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengaduan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              complaint.judul,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _info('Nama', complaint.nama),
            _info('Kategori', complaint.kategori),
            _info('Status', complaint.status),
            _info(
              'Tanggal',
              complaint.tanggal.toString().substring(0, 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Deskripsi:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(complaint.deskripsi),
            const SizedBox(height: 25),
            const Text(
              'Feedback Admin:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              complaint.feedback.isEmpty
                  ? 'Belum ada feedback dari admin'
                  : complaint.feedback,
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        '$title: $value',
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }
}
