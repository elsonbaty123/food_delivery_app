import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/notification_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/section_header.dart';

class NotificationSettingsScreen extends StatefulWidget {
  static const routeName = '/notification-settings';

  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _isLoading = false;
  late Map<String, bool> _notificationSettings;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      
      if (user != null) {
        _notificationSettings = Map<String, bool>.from(user.notificationPreferences);
      } else {
        // Default settings if user is not logged in
        _notificationSettings = {
          'order_updates': true,
          'promotions': true,
          'newsletter': false,
        };
      }
    } catch (e) {
      debugPrint('خطأ في تحميل إعدادات الإشعارات: $e');
      // Show error to user if needed
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateNotificationSetting(String key, bool value) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final originalValue = _notificationSettings[key];

    try {
      setState(() {
        _notificationSettings[key] = value;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.updateNotificationPreference(key, value);

      if (key == 'order_updates') {
        await _notificationService.toggleNotifications(value);
      }

      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('تم تحديث الإعدادات بنجاح'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('خطأ في تحديث إعدادات الإشعارات: $e');

      if (mounted) {
        setState(() {
          _notificationSettings[key] = originalValue!;
        });

        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ أثناء تحديث الإعدادات'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات الإشعارات'),
        centerTitle: true,
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'تفضيلات الإشعارات',
                    subtitle: 'اختر أنواع الإشعارات التي ترغب في تلقيها',
                  ),
                  const SizedBox(height: 16),
                  _buildNotificationSwitch(
                    context,
                    title: 'إشعارات الطلبات',
                    subtitle: 'تلقي تحديثات عن حالة طلباتك',
                    value: _notificationSettings['order_updates'] ?? true,
                    onChanged: (value) => _updateNotificationSetting('order_updates', value),
                    icon: Icons.shopping_bag_outlined,
                  ),
                  _buildDivider(),
                  _buildNotificationSwitch(
                    context,
                    title: 'العروض الترويجية',
                    subtitle: 'عروض خاصة وتخفيضات',
                    value: _notificationSettings['promotions'] ?? true,
                    onChanged: (value) => _updateNotificationSetting('promotions', value),
                    icon: Icons.local_offer_outlined,
                  ),
                  _buildDivider(),
                  _buildNotificationSwitch(
                    context,
                    title: 'النشرة البريدية',
                    subtitle: 'أخبار وتحديثات التطبيق',
                    value: _notificationSettings['newsletter'] ?? false,
                    onChanged: (value) => _updateNotificationSetting('newsletter', value),
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 24),
                  _buildTestNotificationButton(context),
                ],
              ),
            ),
    );
  }

  Widget _buildNotificationSwitch(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon, size: 28),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(height: 1, thickness: 1),
    );
  }

  Widget _buildTestNotificationButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () async {
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          try {
            await _notificationService.showSimpleNotification(
              title: 'اختبار الإشعارات',
              body: 'هذا إشعار تجريبي للتحقق من عمل الإشعارات بشكل صحيح',
              payload: 'test_notification',
            );
          } catch (e) {
            if (!mounted) return;
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text('خطأ في إرسال الإشعار: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        icon: const Icon(Icons.notifications_active_outlined),
        label: const Text('اختبار الإشعارات'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}
