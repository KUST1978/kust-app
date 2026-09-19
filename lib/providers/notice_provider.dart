import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:image_picker/image_picker.dart';
import '../models/notice_model.dart';

class NoticeProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<NoticeItem> _notices = [];
  List<NoticeItem> get notices => _notices;

  bool _isAdmin = false;
  AuthorizationStatus _notificationStatus = AuthorizationStatus.notDetermined;
  AuthorizationStatus get notificationStatus => _notificationStatus;

  NoticeItem? get homeNotice {
    if (_notices.isEmpty) return null;
    try {
      return _notices.firstWhere((n) => n.isPinned);
    } catch (e) {
      return _notices.first;
    }
  }

  NoticeProvider() {
    _listenToNotices();
    checkNotificationStatus();
  }

  void setAdminStatus(bool isAdmin) {
    _isAdmin = isAdmin;
    notifyListeners();
  }

  Future<void> checkNotificationStatus() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    _notificationStatus = settings.authorizationStatus;
    notifyListeners();
  }

  Future<bool> setupNotifications() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission(alert: true, badge: true, sound: true);
      _notificationStatus = settings.authorizationStatus;
      notifyListeners();

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? token = await messaging.getToken(vapidKey: "BMkK18nQuhq3wGivZk_2HfDiQ9ojEW6U9WT3c0F-_6zn-8O0XNFYjdJ1eHopIR65gBQGzhq_0xnzLkxyxjvm9bU");
        if (token != null) {
          await _db.collection('fcm_tokens').doc(token).set({
            'token': token,
            'updatedAt': FieldValue.serverTimestamp(),
            'platform': kIsWeb ? 'web' : 'mobile',
          });
          return true;
        }
      }
    } catch (e) { debugPrint("알림 설정 에러: $e"); }
    return false;
  }

  void _listenToNotices() {
    _db.collection('notices').orderBy('timestamp', descending: true).snapshots().listen((snapshot) {
      _notices = snapshot.docs.map((doc) => NoticeItem.fromMap(doc.id, doc.data())).toList();
      notifyListeners();
    });
  }

  // Push delivery is paused until a server-side sender is available.
  // Never embed service-account credentials in a client application.
  Future<void> sendNoticePush(NoticeItem notice, {Function(String)? logger}) async {
    if (!_isAdmin) {
      logger?.call('발송 권한이 없습니다.');
      return;
    }
    logger?.call('공지 푸시 알림 발송은 현재 중단되어 있습니다.');
  }

  // 💡 메서드 이름을 uploadNoticeImages에서 uploadImages로 변경하여 Screen과 일치시킴
  Future<List<String>> uploadImages(List<XFile> images) async {
    List<String> urls = [];
    for (var image in images) {
      try {
        String fileName = "${DateTime.now().millisecondsSinceEpoch}_${image.name}";
        Reference ref = _storage.ref().child('notices/$fileName');
        final bytes = await image.readAsBytes();
        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
        urls.add(await ref.getDownloadURL());
      } catch (e) { debugPrint("이미지 업로드 에러: $e"); }
    }
    return urls;
  }

  Future<void> addNotice(String title, String content, {List<String> imageUrls = const [], String tag = ''}) async {
    await _db.collection('notices').add({
      'title': title, 'content': content, 'timestamp': DateTime.now().toIso8601String(),
      'isPinned': false, 'imageUrls': imageUrls, 'tag': tag,
    });
  }

  Future<void> updateNotice(String id, String title, String content, {List<String> imageUrls = const [], String tag = ''}) async {
    await _db.collection('notices').doc(id).update({'title': title, 'content': content, 'imageUrls': imageUrls, 'tag': tag});
  }

  Future<void> deleteNotice(String id) async {
    final notice = _notices.firstWhere((n) => n.id == id);
    for (String url in notice.imageUrls) { try { await _storage.refFromURL(url).delete(); } catch (_) {} }
    await _db.collection('notices').doc(id).delete();
  }

  Future<void> pinNotice(String id) async {
    final batch = _db.batch();
    for (var n in _notices) { if (n.isPinned) batch.update(_db.collection('notices').doc(n.id), {'isPinned': false}); }
    batch.update(_db.collection('notices').doc(id), {'isPinned': true});
    await batch.commit();
  }
}