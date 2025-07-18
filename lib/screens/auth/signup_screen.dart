import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_delivery_app/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import 'login_screen.dart';
import '../../utils/validators.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/signup';

  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  UserType _userType = UserType.customer; // Default to customer
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await authProvider.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        userType: _userType,
        password: _passwordController.text,
      );

      if (navigator.mounted) {
        navigator.pushReplacementNamed('/');
      }
    } catch (e) {
      if (scaffoldMessenger.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('خطأ في إنشاء الحساب: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب جديد'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo and Welcome Text
                const SizedBox(height: 16),
                Icon(
                  Icons.restaurant_menu_rounded,
                  size: 60,
                  color: theme.primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'إنشاء حساب جديد',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'انشئ حسابك للبدء في طلب وجباتك المفضلة',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.hintColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Name Field
                CustomTextField(
                  controller: _nameController,
                  label: 'الاسم الكامل',
                  hint: 'أدخل اسمك الكامل',
                  prefixIcon: const Icon(Icons.person_outline),
                  textInputAction: TextInputAction.next,
                  validator: Validators.validateName,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 16),

                // Email Field
                CustomTextField(
                  controller: _emailController,
                  label: 'البريد الإلكتروني',
                  hint: 'أدخل بريدك الإلكتروني',
                  prefixIcon: const Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validateEmail,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 16),

                // Phone Field
                CustomTextField(
                  controller: _phoneController,
                  label: 'رقم الهاتف',
                  hint: 'أدخل رقم هاتفك',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validatePhone,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 16),

                // Password Field
                CustomTextField(
                  controller: _passwordController,
                  label: 'كلمة المرور',
                  hint: 'أدخل كلمة مرور قوية',
                  prefixIcon: const Icon(Icons.lock_outline),
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validatePassword,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.right,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm Password Field
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'تأكيد كلمة المرور',
                  hint: 'أعد إدخال كلمة المرور',
                  prefixIcon: const Icon(Icons.lock_reset_outlined),
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  validator: (value) => Validators.validateConfirmPassword(
                    value,
                    _passwordController.text,
                  ),
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.right,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                // User Type Selection
                const SizedBox(height: 16),
                const Text(
                  "نوع المستخدم",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<UserType>(
                        title: const Text('عميل'),
                        value: UserType.customer,
                        groupValue: _userType,
                        onChanged: (UserType? value) {
                          if (value != null) {
                            setState(() {
                              _userType = value;
                            });
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<UserType>(
                        title: const Text('طاهٍ'),
                        value: UserType.chef,
                        groupValue: _userType,
                        onChanged: (UserType? value) {
                          if (value != null) {
                            setState(() {
                              _userType = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Sign Up Button
                PrimaryButton(
                  onPressed: _isLoading ? null : _signUp,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('إنشاء الحساب'),
                ),
                const SizedBox(height: 24),

                // Already have an account? Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'لديك حساب بالفعل؟',
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          LoginScreen.routeName,
                        );
                      },
                      child: Text(
                        'تسجيل الدخول',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
