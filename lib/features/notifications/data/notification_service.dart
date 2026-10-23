import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// المفتاح العام (Web Push certificate) من Firebase Console.
/// هو مفتاح عام مش سر، بس لازم تلصق قيمتك هون.
const String kVapidKey =
    'BAjO30s8QRivSGW0R7iNkC-0pjEpf0B4f8sp1beff8_GvqiLX5lZbv2hTpW0842vYL4EJVIxSnI5siTFcVgkGz4';

/// المسارات المسموح فتحها من إشعار (whitelist). وسّعها لاحقًا عند الحاجة.
const Set<String> kAllowedDeepLinks = {'/notification'};

/// نسخة مبسّطة من الإشعار (مستقلة عن مكتبة Firebase)
class PushMessage {
  const PushMessage({this.title, this.body, this.data = const {}});

  final String? title;
  final String? body;
  final Map<String, dynamic> data;

  factory PushMessage.fromRemote(RemoteMessage m) => PushMessage(
    title: m.notification?.title,
    body: m.notification?.body,
    data: Map<String, dynamic>.from(m.data),
  );

  /// الـ deep link القادم من الـ payload. أي قيمة غير مسموحة بتروح للشاشة الافتراضية.
  String get route {
    final r = data['route'];
    return (r is String && kAllowedDeepLinks.contains(r)) ? r : '/notification';
  }
}

class NotificationService {
  NotificationService(this._messaging);

  final FirebaseMessaging _messaging;

  /// FCM مدعوم بالويب وأندرويد وiOS وmacOS فقط (مش Windows/Linux).
  static bool get isSupported =>
      kIsWeb ||
      const {
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.macOS,
      }.contains(defaultTargetPlatform);

  Future<AuthorizationStatus> currentStatus() async =>
      (await _messaging.getNotificationSettings()).authorizationStatus;

  Future<AuthorizationStatus> requestPermission() async =>
      (await _messaging.requestPermission()).authorizationStatus;

  Future<String?> getToken() =>
      _messaging.getToken(vapidKey: kIsWeb ? kVapidKey : null);

  Stream<PushMessage> get onForeground =>
      FirebaseMessaging.onMessage.map(PushMessage.fromRemote);

  Stream<PushMessage> get onOpened =>
      FirebaseMessaging.onMessageOpenedApp.map(PushMessage.fromRemote);

  Future<PushMessage?> initialMessage() async {
    final m = await _messaging.getInitialMessage();
    return m == null ? null : PushMessage.fromRemote(m);
  }
}
