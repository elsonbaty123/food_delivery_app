import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/addresses_provider.dart';
import '../widgets/app_drawer.dart';
import 'add_edit_address_screen.dart';

class AddressesScreen extends StatefulWidget {
  static const routeName = '/addresses';
  
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  bool _isLoading = false;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _loadAddresses();
    }
    _isInit = false;
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<AddressesProvider>(context, listen: false)
          .fetchAndSetAddresses();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ أثناء تحميل العناوين'),
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

  @override
  Widget build(BuildContext context) {
    final addressesData = Provider.of<AddressesProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('عناويني'),
        centerTitle: true,
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AddEditAddressScreen.routeName);
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAddresses,
              child: addressesData.addresses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_off,
                            size: 100,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'لا توجد عناوين',
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'اضغط على + لإضافة عنوان جديد',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: addressesData.addresses.length,
                      itemBuilder: (ctx, i) {
                        final address = addressesData.addresses[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: address.isDefault
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[300],
                              child: Icon(
                                Icons.location_on,
                                color: address.isDefault
                                    ? Colors.white
                                    : Colors.grey[600],
                              ),
                            ),
                            title: Text(
                              address.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${address.fullAddress}\n${address.additionalDirections.isNotEmpty ? address.additionalDirections + '\n' : ''}مبنى ${address.buildingNumber} - الطابق ${address.floor} - شقة ${address.apartment}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      AddEditAddressScreen.routeName,
                                      arguments: address.id,
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    try {
                                      await showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('تأكيد الحذف'),
                                          content: const Text(
                                              'هل أنت متأكد من حذف هذا العنوان؟'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(false),
                                              child: const Text('إلغاء'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(true),
                                              child: const Text('حذف'),
                                            ),
                                          ],
                                        ),
                                      );
                                    } catch (error) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'حدث خطأ أثناء حذف العنوان'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
