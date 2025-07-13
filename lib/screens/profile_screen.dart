import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../models/user_model.dart';
import 'notification_settings_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/section_header.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _toggleTheme() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    themeProvider.toggleTheme();

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(themeProvider.isDarkMode
            ? 'تم التبديل إلى الوضع الليلي'
            : 'تم التبديل إلى الوضع النهاري'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _changeLanguage() async {
    final scaffoldContext = context; // Capture the context before async gap

    final selectedLanguage = await showDialog<String>(
      context: scaffoldContext,
      builder: (ctx) => AlertDialog(
        title: const Text('تغيير اللغة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('العربية'),
              onTap: () => Navigator.pop(ctx, 'ar'),
            ),
            ListTile(
              title: const Text('English'),
              onTap: () => Navigator.pop(ctx, 'en'),
            ),
          ],
        ),
      ),
    );

    if (selectedLanguage != null && scaffoldContext.mounted) {
      final localeProvider =
          Provider.of<LocaleProvider>(scaffoldContext, listen: false);
      final locale = Locale(selectedLanguage);
      localeProvider.setLocale(locale);

      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text(
              'تم تغيير اللغة إلى ${selectedLanguage == 'ar' ? 'العربية' : 'English'}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _showLogoutDialog() async {
    final scaffoldContext = context; // Capture the context before async gap

    final shouldLogout = await showDialog<bool>(
          context: scaffoldContext,
          builder: (ctx) => AlertDialog(
            title: const Text('تأكيد تسجيل الخروج'),
            content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('تسجيل خروج'),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldLogout && scaffoldContext.mounted) {
      await Provider.of<AuthProvider>(scaffoldContext, listen: false).logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        centerTitle: true,
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Section
            const SectionHeader(title: 'المعلومات الشخصية'),
            const SizedBox(height: 16),
            _buildUserInfoSection(context, user),
            const SizedBox(height: 24),

            // Settings Section
            const SectionHeader(title: 'الإعدادات'),
            const SizedBox(height: 16),
            _buildSettingsList(context),
            const SizedBox(height: 24),

            // Logout Button
            _buildLogoutButton(context, authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoSection(BuildContext context, UserModel? user) {
    if (user == null) {
      return const Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(
            child: Text('لا يمكن تحميل بيانات المستخدم.'),
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: user.profileImageUrl.isNotEmpty
                  ? NetworkImage(user.profileImageUrl)
                  : const AssetImage('assets/images/default_avatar.png')
                      as ImageProvider,
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              user.email,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            if (user.joinDate != null) ...[
              const SizedBox(height: 8),
              Text(
                'منضم منذ ${_formatJoinDate(user.joinDate!)}',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final theme = Theme.of(context);

    final currentLanguage = localeProvider.locale.languageCode == 'ar' ? 'العربية' : 'English';
    final currentTheme = themeProvider.isDarkMode ? 'ليلي' : 'فاتح';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Notification Settings
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('إعدادات الإشعارات'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(context, NotificationSettingsScreen.routeName);
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),

          // Language Settings
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: const Text('اللغة'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentLanguage,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            onTap: _changeLanguage,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),

          // Theme Settings
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text('المظهر'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentTheme,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            onTap: _toggleTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return Center(
      child: TextButton.icon(
        onPressed: _showLogoutDialog,
        icon: const Icon(Icons.logout, color: Colors.red),
        label: Text(
          'تسجيل الخروج',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }

  String _formatJoinDate(DateTime joinDate) {
    final now = DateTime.now();
    final difference = now.difference(joinDate);
    final days = difference.inDays;

    if (days < 30) {
      return '$days يوم';
    } else if (days < 365) {
      final months = (days / 30).floor();
      return '$months شهر';
    } else {
      final years = (days / 365).floor();
      return '$years سنة';
    }
  }
}
