import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/coupon_model.dart';
import '../../providers/coupon_provider.dart';
import '../../providers/meal_provider.dart';

class AddEditCouponDialog extends StatefulWidget {
  final Coupon? coupon;
  
  const AddEditCouponDialog({this.coupon, super.key});

  @override
  State<AddEditCouponDialog> createState() => _AddEditCouponDialogState();
}

class _AddEditCouponDialogState extends State<AddEditCouponDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _code;
  late double _discountValue;
  late bool _isPercentage;
  late DateTime _expiryDate;
  int? _maxUses;
  final List<String> _selectedMealIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.coupon != null) {
      _code = widget.coupon!.code;
      _discountValue = widget.coupon!.discountValue;
      _isPercentage = widget.coupon!.isPercentage;
      _expiryDate = widget.coupon!.expiryDate;
      _maxUses = widget.coupon!.maxUses;
      _selectedMealIds.addAll(widget.coupon!.eligibleMealIds);
    } else {
      _code = '';
      _discountValue = 10;
      _isPercentage = true;
      _expiryDate = DateTime.now().add(const Duration(days: 30));
      _maxUses = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mealProvider = Provider.of<MealProvider>(context);
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        widget.coupon == null ? 'إنشاء كوبون جديد' : 'تعديل الكوبون',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextFormField(
                  initialValue: _code,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: const InputDecoration(
                    labelText: 'كود الكوبون',
                    border: InputBorder.none,
                  ),
                  validator: (value) => value!.isEmpty ? 'يجب إدخال كود الكوبون' : null,
                  onSaved: (value) => _code = value!,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('إعدادات الخصم', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _discountValue.toString(),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'قيمة الخصم',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) => value!.isEmpty ? 'يجب إدخال قيمة الخصم' : null,
                              onSaved: (value) => _discountValue = double.parse(value!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                            child: DropdownButton<bool>(
                              value: _isPercentage,
                              items: const [
                                DropdownMenuItem(value: true, child: Text('نسبة %')),
                                DropdownMenuItem(value: false, child: Text('مبلغ ثابت')),
                              ],
                              onChanged: (value) => setState(() => _isPercentage = value!),
                              underline: const SizedBox(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _maxUses?.toString() ?? '',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'الحد الأقصى للاستخدام (فارغ لعدد غير محدود)',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) {
                  if (value == null || value.trim().isEmpty) {
                    _maxUses = null;
                  } else {
                    _maxUses = int.tryParse(value);
                  }
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_expiryDate.day}/${_expiryDate.month}/${_expiryDate.year}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const Icon(Icons.calendar_month, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('الوجبات المؤهلة:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...mealProvider.chefMeals.map((meal) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
                child: CheckboxListTile(
                  title: Text(meal.name),
                  value: _selectedMealIds.contains(meal.id),
                  onChanged: (selected) {
                    setState(() {
                      if (selected!) {
                        _selectedMealIds.add(meal.id);
                      } else {
                        _selectedMealIds.remove(meal.id);
                      }
                    });
                  },
                ),
              )),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: _submit,
          child: const Text('حفظ', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() => _expiryDate = pickedDate);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final coupon = Coupon(
        id: widget.coupon?.id ?? DateTime.now().toString(),
        code: _code,
        discountValue: _discountValue,
        isPercentage: _isPercentage,
        expiryDate: _expiryDate,
        eligibleMealIds: _selectedMealIds,
        maxUses: _maxUses,
        createdAt: widget.coupon?.createdAt ?? DateTime.now(),
      );
      
      if (widget.coupon == null) {
        Provider.of<CouponProvider>(context, listen: false).addCoupon(coupon);
      } else {
        Provider.of<CouponProvider>(context, listen: false).updateCoupon(coupon.id, coupon);
      }
      
      Navigator.of(context).pop();
    }
  }
}
