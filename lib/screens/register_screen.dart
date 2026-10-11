import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/app_logo.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2)); // محاكاة طلب للسيرفر
    if (!mounted) return;
    setState(() => _isLoading = false);

    // DummyJSON ما فيه تسجيل حساب حقيقي، فنرجع لشاشة Login مع تنبيه
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Demo only: log in with emilys / emilyspass')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.pagePadding),
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: AppSizes.formMaxWidth),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AppLogo(size: 48, showName: false),
                    const SizedBox(height: 24),
                    CustomTextField(
                      label: 'Full name',
                      icon: Icons.person_outline,
                      controller: _nameController,
                      validator: Validators.name,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Email',
                      icon: Icons.email_outlined,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Password',
                      icon: Icons.lock_outline,
                      controller: _passwordController,
                      isPassword: true,
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Confirm password',
                      icon: Icons.lock_outline,
                      controller: _confirmController,
                      isPassword: true,
                      validator:
                          Validators.matches(() => _passwordController.text),
                    ),
                    const SizedBox(height: 24),
                    LoadingButton(
                      label: 'Register',
                      onPressed: _submit,
                      isLoading: _isLoading,
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('I already have an account'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}