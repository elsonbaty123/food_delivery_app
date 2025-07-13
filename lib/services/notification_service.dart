import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  // قناة الإشعارات
  static const String _channelId = 'order_updates_channel';
  static const String _channelName = 'Order Updates';
  static const String _channelDescription = 'إشعارات تحديثات الطلبات';

  // تهيئة الإشعارات
  Future<void> init() async {
    // تهيئة مناطق التوقيت
    tz.initializeTimeZones();
    
    // طلب أذونات الإشعارات
    await _requestPermissions();
    
    // تهيئة الإشعارات المحلية
    await _initLocalNotifications();
  }

  Future<void> _requestPermissions() async {
    // طلب أذونات الإشعارات
    final status = await Permission.notification.request();
    
    if (status.isGranted) {
      // Permission granted
    } else if (status.isDenied) {
      // Permission denied
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, navigate to app settings
      // await openAppSettings();
    }
  }

  Future<void> _initLocalNotifications() async {
    // إعدادات التهيئة لنظام Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // إعدادات التهيئة لنظام iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    // إعدادات التهيئة لكلا النظامين
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // إنشاء قناة إشعارات للأندرويد
    await _createNotificationChannel();

    // تهيئة الإضافة
    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // التعامل مع النقر على الإشعار
        _onNotificationTap(response.payload);
      },
    );
  }
  
  // إنشاء قناة إشعارات للأندرويد (مطلوب للإصدار 8.0 فما فوق)
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // عرض إشعار محلي
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // التحقق من تفعيل الإشعارات
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    
    if (!notificationsEnabled) return;

    // تفاصيل الإشعار لنظام Android
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    // تفاصيل الإشعار لنظام iOS
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // تفاصيل الإشعار لكلا النظامين
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // عرض الإشعار
    await _localNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // معرف فريد للإشعار
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  void _onNotificationTap(String? payload) {
    // يمكنك إضافة منطق التنقل عند النقر على الإشعار
    if (payload != null) {
      // TODO: Handle notification tap, e.g., navigate to a specific screen
      // Example: Navigator.pushNamed(context, payload);
    }
  }

  // الاشتراك في تحديثات الطلب
  Future<void> scheduleOrderNotification({
    required String orderId,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // التحقق من تفعيل الإشعارات
    if (!(await isNotificationsEnabled())) return;

    // تفاصيل الإشعار
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );

    // جدولة الإشعار
    await _localNotificationsPlugin.zonedSchedule(
      orderId.hashCode, // معرف فريد للإشعار
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'order_$orderId',
    );
  }

  // إلغاء إشعارات الطلب
  Future<void> cancelOrderNotifications(String orderId) async {
    await _localNotificationsPlugin.cancel(orderId.hashCode);
  }

  // التحقق من تفعيل الإشعارات
  Future<bool> isNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }

  // تفعيل/تعطيل الإشعارات
  Future<void> toggleNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
    
    if (enabled) {
      await _requestPermissions();
    } else {
      // إلغاء جميع الإشعارات المجدولة عند تعطيل الإشعارات
      await _localNotificationsPlugin.cancelAll();
    }
  }
  
  // إظهار إشعار بسيط
  Future<void> showSimpleNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await showLocalNotification(
      title: title,
      body: body,
      payload: payload,
    );
  }
}
