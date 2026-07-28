import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../providers/app_settings_provider.dart';
import 'main_navigation_wrapper.dart';
import 'sign_in_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _animDone = false;
  bool _sessionLoaded = false;
  bool? _isSignedIn;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _animController.forward();

    // Setelah animasi selesai (1.5s) + sedikit tambahan waktu tampil (1s)
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      _animDone = true;
      _tryNavigate();
    });
  }

  /// Baca sesi langsung dari SharedPreferences (reliable, non-race-condition)
  void _onSessionLoaded(bool isSignedIn) {
    if (!mounted) return;
    _isSignedIn = isSignedIn;
    _sessionLoaded = true;
    _tryNavigate();
  }

  /// Navigasi hanya saat animasi SUDAH selesai DAN sesi SUDAH dibaca
  void _tryNavigate() {
    if (!_animDone || !_sessionLoaded) return;
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (ctx, animation, secondaryAnimation) => _isSignedIn == true
            ? const MainNavigationWrapper()
            : const _SignInEntry(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryAccent : AppColors.primary;
    final bgColor = isDark ? AppColors.darkBackground : Colors.white;

    // Dengarkan authSessionProvider — saat selesai dibaca, putuskan navigasi.
    // ref.listen aman dipanggil di build() karena hanya memicu callback, tidak rebuild.
    ref.listen<AsyncValue<bool>>(authSessionProvider, (previous, next) {
      next.whenData((isSignedIn) => _onSessionLoaded(isSignedIn));
    });

    // Juga handle kasus di mana data sudah tersedia saat build pertama kali
    final sessionValue = ref.read(authSessionProvider);
    if (sessionValue is AsyncData<bool> && !_sessionLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onSessionLoaded(sessionValue.value);
      });
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            
            // Animasi Logo dan Teks
            AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Column(
                children: [
                  // Box Logo
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.3)
                              : Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Image.asset(
                      'assets/icons/app_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // App Name
                  Text(
                    'AnySave',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Tagline
                  Text(
                    'Simpan video favoritmu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Loading Bar dan 3 Titik
            AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: child,
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 56.0, vertical: 48.0),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        backgroundColor: isDark 
                            ? AppColors.borderDark 
                            : const Color(0xFFE5E7EB),
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        minHeight: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDot(primaryColor),
                        const SizedBox(width: 8),
                        _buildDot(primaryColor),
                        const SizedBox(width: 8),
                        _buildDot(primaryColor),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Wrapper aman untuk SignInScreen. Navigasi dilakukan dari dalam widget
/// sehingga [context] selalu valid (tidak detach seperti dari pageBuilder).
class _SignInEntry extends ConsumerWidget {
  const _SignInEntry();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SignInScreen(
      showGuestButton: false,
      onBackPressed: () {},
      onSignInSuccess: (name) {
        ref.read(authStateProvider.notifier).signIn(name);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigationWrapper()),
          (route) => false,
        );
      },
    );
  }
}
