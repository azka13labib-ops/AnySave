import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_constants.dart';

class SignInScreen extends StatefulWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onSignInSuccess;

  const SignInScreen({
    super.key,
    required this.onBackPressed,
    required this.onSignInSuccess,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: widget.onBackPressed,
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
        title: const Text('Sign In'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.containerMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent,
                    borderRadius: AppConstants.borderRadiusLarge,
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.darkBackground,
                    size: 38,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Welcome to AnySave',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'Sign in to sync your download history across devices',
                  style: TextStyle(
                    color: AppColors.textSecondaryDark,
                    fontSize: 13.5,
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.sectionGap),

              // Email Input Field
              const Text(
                'EMAIL ADDRESS',
                style: TextStyle(
                  color: AppColors.textSecondaryDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'name@example.com',
                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondaryDark),
                ),
              ),

              const SizedBox(height: AppConstants.stackGap),

              // Password Input Field
              const Text(
                'PASSWORD',
                style: TextStyle(
                  color: AppColors.textSecondaryDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondaryDark),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textSecondaryDark,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.sectionGap),

              // Sign In Primary Button
              ElevatedButton(
                onPressed: widget.onSignInSuccess,
                child: const Text('Sign In'),
              ),

              const SizedBox(height: AppConstants.stackGap),

              // Continue as Guest Option
              Center(
                child: TextButton(
                  onPressed: widget.onBackPressed,
                  child: const Text(
                    'Continue as Guest',
                    style: TextStyle(
                      color: AppColors.textSecondaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
