import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../models/address_type.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;
        
        if (user == null) {
          return _buildNotLoggedInView(context);
        }

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () => authProvider.loadUserData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Profile header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withAlpha((255 * 0.1).round()),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: user.profileImageUrl.isNotEmpty
                              ? NetworkImage(user.profileImageUrl)
                              : null,
                          child: user.profileImageUrl.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatColumn(
                              '${user.orderHistory?.length ?? 0}',
                              'طلباتي',
                            ),
                            _buildStatColumn(
                              user.rating?.toStringAsFixed(1) ?? '0.0',
                              'التقييم',
                            ),
                            _buildStatColumn(
                              '${user.coupons?.length ?? 0}',
                              'كوبوناتي',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Menu items
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          context,
                          icon: Icons.person,
                          title: 'تعديل الملف الشخصي',
                          onTap: () => _showComingSoonSnackBar(context),
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.location_on,
                          title: 'عناويني',
                          onTap: () => _showAddressesDialog(context, authProvider),
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.credit_card,
                          title: 'طرق الدفع',
                          onTap: () => _showPaymentMethodsDialog(context, authProvider),
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.history,
                          title: 'سجل الطلبات',
                          onTap: () => _showComingSoonSnackBar(context),
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.favorite_border,
                          title: 'المفضلة',
                          onTap: () => _showComingSoonSnackBar(context),
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.local_offer_outlined,
                          title: 'العروض والخصومات',
                          onTap: () => _showComingSoonSnackBar(context),
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.settings,
                          title: 'الإعدادات',
                          onTap: () => _showSettingsSheet(context, authProvider, user),
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.help_outline,
                          title: 'المساعدة والدعم',
                          onTap: () => _showHelpDialog(context),
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.logout,
                          title: 'تسجيل الخروج',
                          textColor: Colors.red,
                          onTap: () => _showLogoutConfirmation(context, authProvider),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha((255 * 0.2).round()),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // Dialogs and Bottom Sheets
  void _showComingSoonSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم تنفيذ هذه الميزة قريباً'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              authProvider.logout();
              // Show a confirmation message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم تسجيل الخروج بنجاح'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              );
            },
            child: const Text(
              'تسجيل خروج',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('مساعدة'),
        content: const Text(
          'للاستفسارات والمساعدة، يرجى التواصل مع فريق الدعم على:\n\n'
          'البريد الإلكتروني: support@example.com\n'
          'الهاتف: 920000000',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _showSettingsSheet(
      BuildContext context, AuthProvider authProvider, UserModel user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'الإعدادات',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('تفعيل الوضع الليلي'),
              value: false, // TODO: Implement theme provider
              onChanged: (value) {
                // TODO: Toggle dark mode
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('اللغة'),
              trailing: const Text('العربية'),
              onTap: () {
                // TODO: Change language
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('الإشعارات'),
              trailing: Switch(
                value: user.notificationsEnabled,
                onChanged: (value) {
                  authProvider.toggleNotifications(value);
                  Navigator.pop(context);
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('سياسة الخصوصية'),
              onTap: () {
                // TODO: Show privacy policy
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('الشروط والأحكام'),
              onTap: () {
                // TODO: Show terms and conditions
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Address Management
  void _showAddressesDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Create a dummy list of addresses for demonstration
        final List<dynamic> addresses = authProvider.currentUser?.addresses ?? [];
        return AlertDialog(
          title: const Text('عناويني'),
          content: SizedBox(
            width: double.maxFinite,
            child: addresses.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'لم يتم إضافة عناوين بعد',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: addresses.length,
                    itemBuilder: (context, index) {
                      final address = addresses[index];
                      if (address == null) {
                        return const SizedBox.shrink();
                      }
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            address.type == AddressType.home
                                ? Icons.home
                                : address.type == AddressType.work
                                    ? Icons.work
                                    : Icons.location_on,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: Text(address.street),
                          subtitle: Text('${address.city}, ${address.country}'),
                          trailing: address.isDefault
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'افتراضي',
                                    style: TextStyle(
                                      color: Colors.green[800],
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                              : null,
                          onTap: () {
                            // TODO: Select address
                          },
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('إغلاق'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Add new address
                Navigator.of(dialogContext).pop();
              },
              child: const Text('إضافة عنوان جديد'),
            ),
          ],
        );
      },
    );
  }

  // Payment Methods Management
  void _showPaymentMethodsDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('طرق الدفع'),
        content: SizedBox(
          width: double.maxFinite,
          child: authProvider.currentUser?.paymentMethods.isEmpty ?? true
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'لم يتم إضافة طرق دفع بعد',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: authProvider.currentUser?.paymentMethods.length ?? 0,
                  itemBuilder: (context, index) {
                    final method = authProvider.currentUser?.paymentMethods[index];
                    if (method == null) {
                      return const SizedBox.shrink();
                    }
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          method.cardType.toLowerCase().contains('visa') ||
                          method.cardType.toLowerCase().contains('master')
                              ? Icons.credit_card
                              : Icons.account_balance_wallet,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(method.cardNumber.isNotEmpty
                            ? '**** **** **** ${method.lastFourDigits}'
                            : method.cardType),
                        subtitle: method.expiryDate.isNotEmpty
                            ? Text('ينتهي في ${method.expiryDate}')
                            : null,
                        trailing: method.isDefault
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'افتراضي',
                                  style: TextStyle(
                                    color: Colors.green[800],
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            : null,
                        onTap: () {
                          // TODO: Select payment method
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Add new payment method
              Navigator.of(ctx).pop();
            },
            child: const Text('إضافة طريقة دفع جديدة'),
          ),
        ],
      ),
    );
  }

  // Helper methods for dialogs and UI components
  Widget _buildNotLoggedInView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_circle_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'مرحباً بك!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'سجل الدخول لعرض الملف الشخصي وحفظ التفضيلات',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to login screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('سيتم تنفيذ شاشة تسجيل الدخول قريباً'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('تسجيل الدخول / إنشاء حساب'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 0.5,
      child: ListTile(
        leading: Icon(icon, color: textColor ?? Colors.grey[700]),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? Colors.black87, 
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[500]),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
