import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/coupon_provider.dart';
import '../../../models/coupon_model.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/add_edit_coupon_dialog.dart'; 
import 'package:flutter_vibrate/flutter_vibrate.dart';

class CouponManagementScreen extends StatelessWidget {
  static const routeName = '/chef/coupons';

  const CouponManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'إدارة كوبونات الخصم'),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildCouponsList(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddCouponDialog(context),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Text(
            'كوبونات الخصم المتاحة',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildCouponsList(BuildContext context) {
    final coupons = Provider.of<CouponProvider>(context).coupons;
    
    if (coupons.isEmpty) {
      return Center(
        child: Text(
          'لا يوجد كوبونات متاحة',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return ListView.builder(
      itemCount: coupons.length,
      itemBuilder: (ctx, index) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildCouponItem(context, coupons[index], key: ValueKey(coupons[index].id)),
      ),
    );
  }

  Widget _buildCouponItem(BuildContext context, Coupon coupon, {Key? key}) {
    return Card(
      key: key,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  coupon.code,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: Chip(
                    label: Text(
                      coupon.isPercentage 
                        ? '${coupon.discountValue}%'
                        : '${coupon.discountValue} ر.س',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: coupon.isPercentage 
                      ? Colors.green
                      : Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 500),
              child: Text(
                'ينتهي في: ${coupon.expiryDate.day}/${coupon.expiryDate.month}/${coupon.expiryDate.year}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedScale(
                  scale: 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: IconButton(
                    icon: const Icon(Icons.edit),
                    color: Colors.blue,
                    onPressed: () => _showEditCouponDialog(context, coupon),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedScale(
                  scale: 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: () => _deleteCoupon(context, coupon.id),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCouponDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      pageBuilder: (ctx, a1, a2) {
        return const AddEditCouponDialog();
      },
      transitionBuilder: (ctx, a1, a2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: a1,
            curve: Curves.fastOutSlowIn,
          ),
          child: FadeTransition(
            opacity: a1,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  void _showEditCouponDialog(BuildContext context, Coupon coupon) {
    showGeneralDialog(
      context: context,
      pageBuilder: (ctx, a1, a2) {
        return AddEditCouponDialog(coupon: coupon);
      },
      transitionBuilder: (ctx, a1, a2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: a1,
            curve: Curves.easeOutQuint,
          )),
          child: FadeTransition(
            opacity: a1,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  void _deleteCoupon(BuildContext context, String id) async {
    final couponProvider = Provider.of<CouponProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (await Vibrate.canVibrate) {
      Vibrate.feedback(FeedbackType.light);
    }
    
    couponProvider.deleteCoupon(id);
    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text('تم حذف الكوبون بنجاح')),
    );
  }
}
