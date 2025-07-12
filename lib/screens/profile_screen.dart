import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'notification_settings_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/section_header.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
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
                  // User Info Section
                  _buildUserInfoSection(context, user, theme),
                  const SizedBox(height: 24),
                  
                  // Settings Section
                  const SectionHeader(
                    title: 'الإعدادات',
                    subtitle: 'إدارة إعدادات حسابك',
                  ),
                  _buildSettingsList(context, theme),
                  const SizedBox(height: 24),
                  
                  // Logout Button
                  _buildLogoutButton(context, authProvider),
                ],
              ),
            ),
    );
  }

  Widget _buildUserInfoSection(
      BuildContext context, UserModel? user, ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Avatar
            CircleAvatar(
              radius: 50,
              backgroundImage: user?.profileImageUrl != null
                  ? NetworkImage(user!.profileImageUrl!)
                  : const AssetImage('assets/images/default_avatar.png')
                      as ImageProvider,
            ),
            const SizedBox(height: 16),
            
            // User Name
            Text(
              user?.name ?? 'زائر',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            // User Email
            if (user?.email != null) ...[
              const SizedBox(height: 8),
              Text(
                user!.email!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            // Join Date
            if (user?.joinDate != null) ...[
              const SizedBox(height: 8),
              Text(
                'منضم منذ ${_formatJoinDate(user!.joinDate!)}',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context, ThemeData theme) {
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
                  'العربية',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            onTap: () {
              // TODO: Implement language change
            },
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
                  'فاتح',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            onTap: () {
              // TODO: Implement theme change
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(
      BuildContext context, AuthProvider authProvider) {
    return Center(
      child: TextButton.icon(
        onPressed: () async {
          final shouldLogout = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('تسجيل الخروج'),
              content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('إلغاء'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('تسجيل خروج'),
                ),
              ],
            ),
          );

          if (shouldLogout == true) {
            setState(() {
              _isLoading = true;
            });

            try {
              await authProvider.logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/');
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('حدث خطأ أثناء تسجيل الخروج'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } finally {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            }
          }
        },
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
