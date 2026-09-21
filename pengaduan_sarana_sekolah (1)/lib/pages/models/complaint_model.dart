import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintModel {
  final String id;
  final String userId;
  final String nama;
  final String kategori;
  final String judul;
  final String deskripsi;
  final String status;
  final String feedback;
  final String fotoUrl;
  final DateTime tanggal;

  ComplaintModel({
    required this.id,
    required this.userId,
    required this.nama,
    required this.kategori,
    required this.judul,
    required this.deskripsi,
    required this.status,
    required this.feedback,
    required this.fotoUrl,
    required this.tanggal,
  });

  factory ComplaintModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return ComplaintModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      nama: data['nama'] ?? '',
      kategori: data['kategori'] ?? '',
      judul: data['judul'] ?? '',
      deskripsi: data['deskripsi'] ?? '',
      status: data['status'] ?? 'Menunggu',
      feedback: data['feedback'] ?? '',
      fotoUrl: data['fotoUrl'] ?? '',
      tanggal: data['tanggal'] != null
          ? (data['tanggal'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
