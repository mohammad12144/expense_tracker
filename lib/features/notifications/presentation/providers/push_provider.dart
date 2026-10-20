import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/services/app_services.dart';
import 'package:expense_tracker/features/notifications/data/notification_service.dart';

/// null على المنصات الغير مدعومة (مثل Windows)
final notificationServiceProvider = Provider<NotificationService?>(
  (ref) => NotificationService.isSupported
      ? NotificationService(FirebaseMessaging.instance)
      : null,
);

class PushState {
  const PushState({
    this.status,
    this.token,
    this.error,
    this.busy = false,
    this.inbox = const [],
  });

  final AuthorizationStatus? status;
  final String? token;
  final String? error;
  final bool busy;
  final List<PushMessage> inbox;

  bool get enabled =>
      status == AuthorizationStatus.authorized ||
      status == AuthorizationStatus.provisional;

  PushState copyWith({
    AuthorizationStatus? status,
    String? token,
    String? error,
    bool clearError = false,
    bool? busy,
    List<PushMessage>? inbox,
  }) =>
      PushState(
        status: status ?? this.status,
        token: token ?? this.token,
        error: clearError ? null : (error ?? this.error),
        busy: busy ?? this.busy,
        inbox: inbox ?? this.inbox,
      );
}

final pushControllerProvider =
    NotifierProvider<PushController, PushState>(PushController.new);

class PushController extends Notifier<PushState> {
  final List<StreamSubscription<PushMessage>> _subs = [];

  @override
  PushState build() {
    ref.onDispose(() {
      for (final s in _subs) {
        s.cancel();
      }
    });
    return const PushState();
  }

  /// بيشتغل عند فتح Home: إذا الإذن موجود من قبل، بنفعّل الاستقبال بصمت.
  Future<void> init() async {
    final service = ref.read(notificationServiceProvider);
    if (service == null) return;
    try {
      final status = await service.currentStatus();
      state = state.copyWith(status: status);
      if (state.enabled) await _activate(service);
    } catch (e) {
      state = state.copyWith(error: 'Notifications init failed: $e');
    }
  }

  /// بيشتغل من زر Enable (لازم يكون بتفاعل من المستخدم).
  Future<void> enable() async {
    final service = ref.read(notificationServiceProvider);
    if (service == null) {
      state = state.copyWith(
          error: 'Push notifications are not supported on this platform.');
      return;
    }
    state = state.copyWith(busy: true, clearError: true);
    try {
      final status = await service.requestPermission();
      state = state.copyWith(status: status);
      if (state.enabled) await _activate(service);
    } catch (e) {
      state = state.copyWith(error: 'Could not enable notifications: $e');
    } finally {
      state = state.copyWith(busy: false);
    }
  }

  Future<void> _activate(NotificationService service) async {
    final token = await service.getToken();
    state = state.copyWith(token: token, clearError: true);

    if (_subs.isEmpty) {
      _subs.add(service.onForeground.listen(_onForeground));
      // onMessageOpenedApp للموبايل (الويب بيتعامل مع النقر بطريقة مختلفة)
      if (!kIsWeb) {
        _subs.add(service.onOpened.listen((m) {
          _remember(m);
          _go(m);
        }));
      }
    }

    // التطبيق انفتح من إشعار وهو مغلق (موبايل)
    final initial = await service.initialMessage();
    if (initial != null) {
      _remember(initial);
      _go(initial);
    }
  }

  void _remember(PushMessage m) {
    final list = [m, ...state.inbox];
    state = state.copyWith(inbox: list.length > 20 ? list.sublist(0, 20) : list);
  }

  void _go(PushMessage m) =>
      navigatorKey.currentState?.pushNamed(m.route, arguments: m);

  void _onForeground(PushMessage m) {
    _remember(m);
    messengerKey.currentState
      ?..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(m.title ?? m.body ?? 'New notification'),
          duration: const Duration(seconds: 8),
          action: SnackBarAction(label: 'Open', onPressed: () => _go(m)),
        ),
      );
  }
}