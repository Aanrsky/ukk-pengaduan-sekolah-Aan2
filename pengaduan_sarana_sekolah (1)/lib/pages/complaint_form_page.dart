import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../services/firestore_service.dart';

class ComplaintFormPage extends StatefulWidget {
  const ComplaintFormPage({super.key});

  @override
  State<ComplaintFormPage> createState() => _ComplaintFormPageState();
}

class _ComplaintFormPageState extends State<ComplaintFormPage> {
  final _formKey = GlobalKey<FormState>();

  final namaController = TextEditingController();
  final judulController = TextEditingController();
  final deskripsiController = TextEditingController();

  String kategori = 'Sarana Rusak';
  bool loading = false;

  Uint8List? selectedImage;
  String? imageName;

  final FirestoreService firestoreService = FirestoreService();

  final ImagePicker picker = ImagePicker();

  @override
  void dispose() {
    namaController.dispose();
    judulController.dispose();
    deskripsiController.dispose();
    super.dispose();
  }

  Future<void> pilihFoto() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image == null) return;

    final bytes = await image.readAsBytes();

    setState(() {
      selectedImage = bytes;
      imageName = image.name;
    });
  }

  Future<String> uploadFoto() async {
    if (selectedImage == null) return '';

    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${imageName ?? 'foto.jpg'}';

    final ref =
        FirebaseStorage.instance.ref().child('foto_pengaduan').child(fileName);

    await ref.putData(selectedImage!);

    return await ref.getDownloadURL();
  }

  Future<void> kirimPengaduan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });

    try {
      String fotoUrl = '';

      if (selectedImage != null) {
        fotoUrl = await uploadFoto();
      }

      await firestoreService.addComplaint(
        nama: namaController.text.trim(),
        kategori: kategori,
        judul: judulController.text.trim(),
        deskripsi: deskripsiController.text.trim(),
        fotoUrl: fotoUrl,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengaduan berhasil dikirim'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Pengaduan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama wajib diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: kategori,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Sarana Rusak',
                    child: Text('Sarana Rusak'),
                  ),
                  DropdownMenuItem(
                    value: 'Kebersihan',
                    child: Text('Kebersihan'),
                  ),
                  DropdownMenuItem(
                    value: 'Keamanan',
                    child: Text('Keamanan'),
                  ),
                  DropdownMenuItem(
                    value: 'Lainnya',
                    child: Text('Lainnya'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    kategori = value!;
                  });
                },
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: judulController,
                decoration: const InputDecoration(
                  labelText: 'Judul Pengaduan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul wajib diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: deskripsiController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Pengaduan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Deskripsi wajib diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // TOMBOL PILIH FOTO
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: loading ? null : pilihFoto,
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('PILIH FOTO KERUSAKAN'),
                ),
              ),

              const SizedBox(height: 15),

              // PREVIEW FOTO
              if (selectedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    selectedImage!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

              if (selectedImage != null)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('Foto berhasil dipilih'),
                ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : kirimPengaduan,
                  child: loading
                      ? const CircularProgressIndicator()
                      : const Text('KIRIM PENGADUAN'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
