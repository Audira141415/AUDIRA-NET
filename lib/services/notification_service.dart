import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap - payload: ${response.payload}
  }

  Future<void> requestPermissions() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  Future<void> showBillReminderNotification({
    required String month,
    required String dueDate,
    required double amount,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'bill_reminder',
      'Pengingat Tagihan',
      channelDescription: 'Notifikasi pengingat tagihan bulanan',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1,
      'Tagihan Jatuh Tempo',
      'Tagihan $month sebesar Rp ${_formatNumber(amount)} jatuh tempo pada $dueDate',
      details,
      payload: 'bill_reminder',
    );
  }

  Future<void> showTicketUpdateNotification({
    required String ticketId,
    required String status,
    required String message,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'ticket_update',
      'Update Tiket',
      channelDescription: 'Notifikasi update status tiket bantuan',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      2,
      'Update Tiket #$ticketId',
      '$status: $message',
      details,
      payload: 'ticket_update:$ticketId',
    );
  }

  Future<void> showNetworkUpdateNotification({
    required String title,
    required String message,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'network_update',
      'Info Jaringan',
      channelDescription: 'Notifikasi informasi jaringan dan pemeliharaan',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      3,
      title,
      message,
      details,
      payload: 'network_update',
    );
  }

  Future<void> scheduleMonthlyBillReminder({
    required String month,
    required DateTime dueDate,
    required double amount,
  }) async {
    // Remind 3 days before due date
    final reminderDate = dueDate.subtract(const Duration(days: 3));

    const androidDetails = AndroidNotificationDetails(
      'bill_reminder',
      'Pengingat Tagihan',
      channelDescription: 'Notifikasi pengingat tagihan bulanan',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Note: For actual scheduling, you'd need to use a plugin like flutter_local_notifications
    // with timezone support. This is a simplified version.
    await _notifications.show(
      100 + reminderDate.day,
      'Tagihan Segera Jatuh Tempo',
      'Tagihan $month sebesar Rp ${_formatNumber(amount)} akan jatuh tempo pada ${_formatDate(dueDate)}',
      details,
      payload: 'bill_reminder_scheduled',
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  String _formatNumber(double value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
