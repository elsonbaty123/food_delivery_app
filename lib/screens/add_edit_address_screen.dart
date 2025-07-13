import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/addresses_provider.dart';
import '../models/address.dart';

class AddEditAddressScreen extends StatefulWidget {
  static const routeName = '/add-edit-address';
  
  const AddEditAddressScreen({super.key});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isLoading = false;
  var _isInit = true;
  
  final _titleController = TextEditingController();
  final _fullAddressController = TextEditingController();
  final _buildingNumberController = TextEditingController();
  final _floorController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _additionalDirectionsController = TextEditingController();
  var _isDefault = false;
  
  Address? _editedAddress;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (_isInit) {
      final addressId = ModalRoute.of(context)?.settings.arguments as String?;
      
      if (addressId != null) {
        _editedAddress = Provider.of<AddressesProvider>(
          context,
          listen: false,
        ).findById(addressId);
        
        if (_editedAddress != null) {
          _titleController.text = _editedAddress!.title;
          _fullAddressController.text = _editedAddress!.fullAddress;
          _buildingNumberController.text = _editedAddress!.buildingNumber;
          _floorController.text = _editedAddress!.floor;
          _apartmentController.text = _editedAddress!.apartment;
          _additionalDirectionsController.text = _editedAddress!.additionalDirections;
          _isDefault = _editedAddress!.isDefault;
        }
      }
      _isInit = false;
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _fullAddressController.dispose();
    _buildingNumberController.dispose();
    _floorController.dispose();
    _apartmentController.dispose();
    _additionalDirectionsController.dispose();
    super.dispose();
  }
  
  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    _formKey.currentState!.save();
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      if (_editedAddress == null) {
        await Provider.of<AddressesProvider>(context, listen: false).addAddress(
          _titleController.text,
          _fullAddressController.text,
          _buildingNumberController.text,
          _floorController.text,
          _apartmentController.text,
          _additionalDirectionsController.text,
          _isDefault,
        );
      } else {
        await Provider.of<AddressesProvider>(context, listen: false).updateAddress(
          _editedAddress!.id,
          _titleController.text,
          _fullAddressController.text,
          _buildingNumberController.text,
          _floorController.text,
          _apartmentController.text,
          _additionalDirectionsController.text,
          _isDefault,
        );
      }
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ أثناء حفظ العنوان'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_editedAddress == null ? 'إضافة عنوان جديد' : 'تعديل العنوان'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'عنوان مميز (مثل: المنزل، العمل)',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال عنوان مميز';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _fullAddressController,
                      decoration: const InputDecoration(
                        labelText: 'العنوان الكامل',
                        hintText: 'اسم الشارع والمنطقة والمدينة',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال العنوان الكامل';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _additionalDirectionsController,
                      decoration: const InputDecoration(
                        labelText: 'إرشادات إضافية (اختياري)',
                        border: OutlineInputBorder(),
                        hintText: 'مثل: بجانب الصيدلية، مقابل المدرسة، إلخ.',
                      ),
                      maxLines: 2,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('تعيين كعنوان افتراضي'),
                      value: _isDefault,
                      onChanged: (value) {
                        setState(() {
                          _isDefault = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        _editedAddress == null ? 'إضافة العنوان' : 'حفظ التغييرات',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
