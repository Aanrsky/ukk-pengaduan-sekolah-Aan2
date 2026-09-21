import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../pages/models/complaint_model.dart';

class FirestoreService {
  final CollectionReference<Map<String, dynamic>> complaints =
      FirebaseFirestore.instance.collection('pengaduan');

  // ==========================================
  // SEMUA PENGADUAN - ADMIN
  // ==========================================
  Stream<List<ComplaintModel>> getComplaints() {
    return complaints.orderBy('tanggal', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => ComplaintModel.fromFirestore(doc))
              .toList(),
        );
  }

  // ==========================================
  // PENGADUAN MILIK SISWA YANG LOGIN
  // ==========================================
  Stream<List<ComplaintModel>> getMyComplaints() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Stream<List<ComplaintModel>>.value(
        <ComplaintModel>[],
      );
    }

    return complaints
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      final List<ComplaintModel> data = snapshot.docs
          .map((doc) => ComplaintModel.fromFirestore(doc))
          .toList();

      // Urutkan berdasarkan tanggal terbaru
      data.sort(
        (a, b) => b.tanggal.compareTo(a.tanggal),
      );

      return data;
    });
  }

  // ==========================================
  // TAMBAH PENGADUAN
  // ==========================================
  Future<void> addComplaint({
    required String nama,
    required String kategori,
    required String judul,
    required String deskripsi,
    required String fotoUrl,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Kamu belum login');
    }

    await complaints.add({
      'userId': user.uid,
      'nama': nama,
      'kategori': kategori,
      'judul': judul,
      'deskripsi': deskripsi,
      'fotoUrl': fotoUrl,
      'status': 'Menunggu',
      'feedback': '',
      'tanggal': Timestamp.now(),
    });
  }

  // ==========================================
  // UPDATE STATUS + FEEDBACK
  // ==========================================
  Future<void> updateComplaint({
    required String id,
    required String status,
    required String feedback,
  }) async {
    await complaints.doc(id).update({
      'status': status,
      'feedback': feedback,
    });
  }
}
