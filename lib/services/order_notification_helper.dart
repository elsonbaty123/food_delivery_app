import 'package:food_delivery_app/models/order_model.dart';
import 'package:food_delivery_app/services/notification_service.dart';

class OrderNotificationHelper {
  final NotificationService _notificationService = NotificationService();

  // تهيئة المساعد
  Future<void> init() async {
    await _notificationService.init();
  }

  // إرسال إشعار لتغيير حالة الطلب
  Future<void> handleOrderStatusChange(Order order) async {
    final status = order.status;
    String title = 'تحديث حالة الطلب';
    String body = '';
    
    switch (status) {
      case OrderStatus.pending:
        body = 'تم استلام طلبك بنجاح وجاري التحضير';
        break;
      case OrderStatus.confirmed:
        body = 'تم تأكيد طلبك وسيتم تحضيره قريباً';
        break;
      case OrderStatus.preparing:
        body = 'جاري تحضير طلبك الآن';
        break;
      case OrderStatus.readyForDelivery:
        body = 'تم تجهيز طلبك وجاهز للتسليم';
        break;
      case OrderStatus.onTheWay:
        body = 'ساعي التوصيل في طريقه إليك';
        break;
      case OrderStatus.delivered:
        title = 'تم التسليم';
        body = 'شكراً لاستخدامك تطبيقنا، نتمنى لك وجبة شهية!';
        break;
      case OrderStatus.cancelled:
        title = 'تم إلغاء الطلب';
        body = order.cancellationReason != null && order.cancellationReason!.isNotEmpty 
            ? 'تم إلغاء طلبك. السبب: ${order.cancellationReason}'
            : 'تم إلغاء طلبك';
        break;
    }

    // إرسال الإشعار الفوري
    await _notificationService.showSimpleNotification(
      title: title,
      body: body,
      payload: 'order_${order.id}',
    );

    // جدولة إشعارات إضافية بناءً على حالة الطلب
    await _scheduleOrderNotifications(order);
  }

  // جدولة إشعارات إضافية للطلب
  Future<void> _scheduleOrderNotifications(Order order) async {
    final now = DateTime.now();
    
    switch (order.status) {
      case OrderStatus.preparing:
        // إشعار بعد 15 دقيقة إذا كان الطلب لا يزال قيد التحضير
        await _notificationService.scheduleOrderNotification(
          orderId: order.id,
          title: 'طلبك لا يزال قيد التحضير',
          body: 'نعمل على تحضير طلبك وسنخبرك فور الانتهاء',
          scheduledDate: now.add(const Duration(minutes: 15)),
        );
        break;
        
      case OrderStatus.readyForDelivery:
        // إشعار تذكير بعد 10 دقائق إذا لم يتم استلام الطلب
        await _notificationService.scheduleOrderNotification(
          orderId: order.id,
          title: 'طلبك جاهز للتسليم',
          body: 'يرجى الاستعداد لاستلام طلبك قريباً',
          scheduledDate: now.add(const Duration(minutes: 10)),
        );
        break;
        
      case OrderStatus.onTheWay:
        // إشعار بعد 5 دقائق لتذكير العميل
        await _notificationService.scheduleOrderNotification(
          orderId: order.id,
          title: 'ساعي التوصيل في طريقه',
          body: 'يرجى التأهب لاستلام طلبك قريباً',
          scheduledDate: now.add(const Duration(minutes: 5)),
        );
        break;
        
      default:
        break;
    }
  }

  // إلغاء جميع الإشعارات المرتبطة بطلب معين
  Future<void> cancelOrderNotifications(String orderId) async {
    await _notificationService.cancelOrderNotifications(orderId);
  }

  // تفعيل/تعطيل الإشعارات
  Future<void> toggleNotifications(bool enabled) async {
    await _notificationService.toggleNotifications(enabled);
  }

  // التحقق من حالة تفعيل الإشعارات
  Future<bool> areNotificationsEnabled() async {
    return await _notificationService.isNotificationsEnabled();
  }
}
