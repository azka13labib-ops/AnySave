import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_constants.dart';

class SignInScreen extends StatefulWidget {
  final VoidCallback onBackPressed;
  final Function(String name) onSignInSuccess;
  final bool showGuestButton;

  const SignInScreen({
    super.key,
    required this.onBackPressed,
    required this.onSignInSuccess,
    this.showGuestButton = false,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleQuickLogin() async {
    final rawName = _nameController.text.trim();

    if (rawName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masukkan nama kamu terlebih dahulu'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 1. Persist Local Session
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_signed_in', true);
      await prefs.setString('user_name', rawName);
    } catch (_) {}

    // 2. Record Pure Name directly to Supabase Database Table `users_list`
    try {
      await Supabase.instance.client.from('users_list').insert({
        'name': rawName,
      });
      debugPrint('Successfully recorded user $rawName to Supabase users_list');
    } catch (e) {
      debugPrint('Failed to record user to Supabase: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
      widget.onSignInSuccess(rawName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: widget.showGuestButton
          ? AppBar(
              leading: IconButton(
                onPressed: widget.onBackPressed,
                icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : AppColors.primary),
              ),
              title: const Text('Profil Pengguna'),
            )
          : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.containerMargin),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo AnySave
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.download_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),

                const SizedBox(height: 28),

                Text(
                  'Selamat Datang di AnySave',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Masukkan nama kamu untuk personalisasi aplikasi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 36),

                // 1-KOLOM INPUT NAMA / USERNAME
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'NAMA KAMU',
                    style: TextStyle(
                      color: isDark ? AppColors.textSecondaryDark : const Color(0xFF8E8E93),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Misal: Azka / Alex',
                    prefixIcon: Icon(
                      Icons.person_outline_rounded,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  onSubmitted: (_) => _handleQuickLogin(),
                ),

                const SizedBox(height: 28),

                // TOMBOL UTAMA START USING ANYSAVE
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleQuickLogin,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward_rounded, size: 22),
                  label: const Text(
                    'Mulai Gunakan AnySave',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),

                const SizedBox(height: 16),

                // Skip / Continue as Guest Option (Only if shown)
                if (widget.showGuestButton)
                  TextButton(
                    onPressed: widget.onBackPressed,
                    child: Text(
                      'Lewati Dulu (Masuk Tamu)',
                      style: TextStyle(
                        color: isDark ? AppColors.textSecondaryDark : const Color(0xFF8E8E93),
                        fontWeight: FontWeight.w500,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
