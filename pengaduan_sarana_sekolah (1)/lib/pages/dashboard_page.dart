import 'package:flutter/material.dart';
import 'pengaduan_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMP Negeri 3 Bantul'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Icon(
              Icons.school,
              size: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              'APLIKASI PENGADUAN SARANA',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'SMP Negeri 3 Bantul',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 60,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.report_problem),
                label: const Text(
                  'BUAT PENGADUAN',
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PengaduanPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 60,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.history),
                label: const Text(
                  'RIWAYAT PENGADUAN',
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Halaman riwayat akan dibuat'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
