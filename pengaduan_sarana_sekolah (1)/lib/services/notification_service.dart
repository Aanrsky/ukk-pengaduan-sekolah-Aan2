import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _studentNotificationSubscription;

  bool _initialized = false;

  // ==========================================================
  // NOTIFICATION CHANNEL ANDROID
  // ==========================================================

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'pengaduan_updates',
    'Pembaruan Pengaduan',
    description: 'Notifikasi pembaruan pengaduan siswa.',
    importance: Importance.max,
    playSound: true,
  );

  // ==========================================================
  // INITIALIZE
  // ==========================================================

  Future<void> init() async {
    if (_initialized) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint(
          'Notifikasi ditekan: ${response.payload}',
        );
      },
    );

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(
      _channel,
    );

    await androidPlugin?.requestNotificationsPermission();

    _initialized = true;

    debugPrint(
      'NotificationService berhasil diinisialisasi.',
    );
  }

  // ==========================================================
  // TAMPILKAN LOCAL NOTIFICATION
  // ==========================================================

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await init();

    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'pengaduan_updates',
        'Pembaruan Pengaduan',
        channelDescription: 'Notifikasi pembaruan pengaduan siswa.',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        autoCancel: true,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
    );

    final int notificationId =
        DateTime.now().millisecondsSinceEpoch.remainder(2147483647);

    await _localNotifications.show(
      notificationId,
      title,
      body,
      details,
      payload: payload,
    );

    debugPrint(
      'Local notification ditampilkan: $title',
    );
  }

  // ==========================================================
  // PANTAU NOTIFIKASI SISWA
  //
  // userId = UID Firebase Auth siswa
  // ==========================================================

  Future<void> startStudentNotificationListener(
    String userId,
  ) async {
    await init();

    await stopStudentNotificationListener();

    if (userId.trim().isEmpty) {
      debugPrint(
        'Notification listener dibatalkan: userId kosong.',
      );
      return;
    }

    bool firstSnapshot = true;

    final Set<String> knownIds = {};

    debugPrint(
      'Mulai memantau notifications untuk user: $userId',
    );

    _studentNotificationSubscription = _firestore
        .collection('notifications')
        .where(
          'userId',
          isEqualTo: userId,
        )
        .snapshots()
        .listen(
      (QuerySnapshot<Map<String, dynamic>> snapshot) async {
        final Set<String> currentIds =
            snapshot.docs.map((doc) => doc.id).toSet();

        // ======================================================
        // SNAPSHOT PERTAMA
        //
        // Notifikasi lama tidak ditampilkan sebagai popup.
        // Hanya notifikasi yang benar-benar baru yang popup.
        // ======================================================

        if (firstSnapshot) {
          knownIds
            ..clear()
            ..addAll(currentIds);

          firstSnapshot = false;

          debugPrint(
            'Snapshot pertama: '
            '${snapshot.docs.length} notifikasi lama ditemukan.',
          );

          return;
        }

        // ======================================================
        // CEK DOKUMEN BARU
        // ======================================================

        for (final DocumentChange<Map<String, dynamic>> change
            in snapshot.docChanges) {
          if (change.type != DocumentChangeType.added) {
            continue;
          }

          final DocumentSnapshot<Map<String, dynamic>> doc = change.doc;

          if (knownIds.contains(doc.id)) {
            continue;
          }

          knownIds.add(doc.id);

          final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};

          final String title =
              (data['title'] ?? 'Pengaduan diperbarui').toString();

          final String body =
              (data['body'] ?? 'Ada pembaruan pada pengaduan kamu.').toString();

          final String complaintId = (data['complaintId'] ?? '').toString();

          debugPrint(
            'Notifikasi baru ditemukan: ${doc.id}',
          );

          await showNotification(
            title: title,
            body: body,
            payload: complaintId,
          );
        }

        // Hapus ID yang sudah tidak ada
        knownIds.removeWhere(
          (String id) => !currentIds.contains(id),
        );
      },
      onError: (Object error) {
        debugPrint(
          'Notification listener error: $error',
        );
      },
    );
  }

  // ==========================================================
  // HENTIKAN LISTENER
  // ==========================================================

  Future<void> stopStudentNotificationListener() async {
    await _studentNotificationSubscription?.cancel();

    _studentNotificationSubscription = null;

    debugPrint(
      'Notification listener dihentikan.',
    );
  }

  // ==========================================================
  // BUAT NOTIFIKASI UNTUK SISWA
  //
  // Dipanggil dari admin/petugas.
  // ==========================================================

  Future<void> createStudentNotification({
    required String userId,
    required String title,
    required String body,
    String? complaintId,
    String? status,
    String? feedback,
  }) async {
    if (userId.trim().isEmpty) {
      debugPrint(
        'Gagal membuat notifikasi: userId kosong.',
      );
      return;
    }

    await _firestore.collection('notifications').add({
      'userId': userId,
      'complaintId': complaintId ?? '',
      'title': title,
      'body': body,
      'status': status ?? '',
      'feedback': feedback ?? '',
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    debugPrint(
      'Notifikasi berhasil dibuat untuk user $userId',
    );
  }

  // ==========================================================
  // STREAM JUMLAH NOTIFIKASI BELUM DIBACA
  // ==========================================================

  Stream<int> unreadNotificationCount(
    String userId,
  ) {
    if (userId.trim().isEmpty) {
      return Stream.value(0);
    }

    return _firestore
        .collection('notifications')
        .where(
          'userId',
          isEqualTo: userId,
        )
        .where(
          'read',
          isEqualTo: false,
        )
        .snapshots()
        .map(
      (QuerySnapshot<Map<String, dynamic>> snapshot) {
        return snapshot.docs.length;
      },
    );
  }

  // ==========================================================
  // STREAM DAFTAR NOTIFIKASI SISWA
  // ==========================================================

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      studentNotifications(
    String userId,
  ) {
    if (userId.trim().isEmpty) {
      return Stream.value(
        <QueryDocumentSnapshot<Map<String, dynamic>>>[],
      );
    }

    return _firestore
        .collection('notifications')
        .where(
          'userId',
          isEqualTo: userId,
        )
        .snapshots()
        .map(
      (
        QuerySnapshot<Map<String, dynamic>> snapshot,
      ) {
        final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
            List.from(snapshot.docs);

        docs.sort(
          (
            a,
            b,
          ) {
            final Timestamp? aTime = a.data()['createdAt'] as Timestamp?;

            final Timestamp? bTime = b.data()['createdAt'] as Timestamp?;

            if (aTime == null && bTime == null) {
              return 0;
            }

            if (aTime == null) {
              return 1;
            }

            if (bTime == null) {
              return -1;
            }

            return bTime.compareTo(aTime);
          },
        );

        return docs;
      },
    );
  }

  // ==========================================================
  // TANDAI NOTIFIKASI SUDAH DIBACA
  // ==========================================================

  Future<void> markAsRead(
    String notificationId,
  ) async {
    if (notificationId.trim().isEmpty) {
      return;
    }

    await _firestore.collection('notifications').doc(notificationId).update({
      'read': true,
    });
  }

  // ==========================================================
  // TANDAI SEMUA NOTIFIKASI SUDAH DIBACA
  // ==========================================================

  Future<void> markAllAsRead(
    String userId,
  ) async {
    if (userId.trim().isEmpty) {
      return;
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('notifications')
        .where(
          'userId',
          isEqualTo: userId,
        )
        .where(
          'read',
          isEqualTo: false,
        )
        .get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    final WriteBatch batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.update(
        doc.reference,
        {
          'read': true,
        },
      );
    }

    await batch.commit();

    debugPrint(
      'Semua notifikasi siswa ditandai sudah dibaca.',
    );
  }
}
