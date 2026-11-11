import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors.dart';
import '../routes/app_routes.dart';
import '../services/app_session.dart';
import '../widgets/account_chooser_dialog.dart';
import '../widgets/app_alert_dialog.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/nexa_logo.dart';
import '../widgets/social_button.dart';
import 'auth/login_loading_screen.dart';

class AuthScreen extends StatefulWidget {
  final bool initialIsSignUp;

  const AuthScreen({
    super.key,
    this.initialIsSignUp = true,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late bool _isSignUp;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Entrance Animations
  late AnimationController _entranceController;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _cardFadeAnimation;
  late Animation<Offset> _cardSlideAnimation;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.initialIsSignUp;

    // Staggered Entrance Animation Setup
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _headerFadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    _cardFadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    );

    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Daftar -> Konfirmasi Akun -> Buat Profil -> ... (akun baru KOSONG)
  // Masuk  -> Loading -> Home (isi mengikuti akun yang masuk)
  void _submit() {
    final session = AppSession.instance;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final kosong = email.isEmpty ||
        password.isEmpty ||
        (_isSignUp && _confirmPasswordController.text.isEmpty);
    if (kosong) {
      showLoginFailedDialog(context); // "Gagal Ke Akun!"
      return;
    }

    if (_isSignUp) {
      if (password != _confirmPasswordController.text) {
        showFillWarningDialog(context, text: 'Kata sandi tidak sama!');
        return;
      }
      if (session.isEmailRegistered(email)) {
        showFillWarningDialog(context,
            text: 'Akun sudah terdaftar,\nsilakan Masuk.');
        return;
      }
      session.register(email, password); // akun baru: data masih kosong
      Navigator.pushNamed(context, AppRoutes.accountConfirmed);
    } else {
      if (session.signInWithEmail(email, password) == null) {
        showFillWarningDialog(context,
            text: 'E-mail atau kata sandi salah,\natau akun belum terdaftar.');
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginLoadingScreen(method: LoginMethod.email),
        ),
      );
    }
  }

  Future<void> _socialLogin(SocialProvider provider) async {
    final isGoogle = provider == SocialProvider.google;
    // Akun Google/Facebook contoh = akun Ignatius (lihat AppSession).
    final label = isGoogle ? AppSession.demoEmail : AppSession.demoFacebookName;
    final ok = await showAccountChooser(
      context,
      provider: provider,
      accountLabel: label,
    );
    if (!ok || !mounted) return;
    if (AppSession.instance.signInWithSocial(provider, label) == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginLoadingScreen(
          method: isGoogle ? LoginMethod.google : LoginMethod.facebook,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isDesktop = screenWidth > 600;

    // Build the core mobile auth layout
    Widget authContent = Column(
      children: [
        // Top Header Section (Logo + Heading) with Slide-Down Entrance
        SlideTransition(
          position: _headerSlideAnimation,
          child: FadeTransition(
            opacity: _headerFadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 24.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  NexaLogo(
                    tileSize: 38.0,
                    borderWidth: 2.0,
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Next level starts here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Bottom White Card with Slide-Up Entrance
        Expanded(
          child: SlideTransition(
            position: _cardSlideAnimation,
            child: FadeTransition(
              opacity: _cardFadeAnimation,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 16,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28.0,
                      vertical: 24.0,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Form Title with smooth text transition
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              _isSignUp
                                  ? 'Buat akun untuk jadi instruktur'
                                  : 'Masuk ke akun Anda',
                              key: ValueKey<bool>(_isSignUp),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // G-mail field
                          CustomTextField(
                            label: 'E-mail',
                            hintText: 'nama@gmail.com',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 14),

                          // Kata Sandi field
                          CustomTextField(
                            label: 'Kata Sandi',
                            hintText: '••••••••',
                            controller: _passwordController,
                            isPassword: true,
                          ),

                          // Konfirmasi Kata Sandi (hanya saat Daftar)
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: _isSignUp
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const SizedBox(height: 14),
                                      CustomTextField(
                                        label: 'Konfirmasi Kata Sandi',
                                        hintText: '••••••••',
                                        controller: _confirmPasswordController,
                                        isPassword: true,
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                          ),

                          const SizedBox(height: 22),

                          // Primary Action Button ("Daftar" / "Masuk")
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryMaroon,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: const StadiumBorder(),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Text(
                                _isSignUp ? 'Daftar' : 'Masuk',
                                key: ValueKey<bool>(_isSignUp),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // "Daftar dengan:" / "Masuk dengan:"
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Text(
                              _isSignUp ? 'Daftar dengan:' : 'Masuk dengan:',
                              key: ValueKey<bool>(_isSignUp),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4B5563),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Social Icons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SocialIconButton(
                                type: SocialType.google,
                                onTap: () => _socialLogin(SocialProvider.google),
                              ),
                              const SizedBox(width: 18),
                              SocialIconButton(
                                type: SocialType.facebook,
                                onTap: () =>
                                    _socialLogin(SocialProvider.facebook),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Toggle Sign Up / Login Footer
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isSignUp
                                    ? 'Sudah punya akun? '
                                    : 'Belum punya akun? ',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF374151),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isSignUp = !_isSignUp;
                                  });
                                },
                                child: Text(
                                  _isSignUp ? 'Masuk' : 'Daftar',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryMaroon,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Safe Area bottom padding
                          SizedBox(
                            height: mediaQuery.padding.bottom + 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.primaryMaroon,
      body: SafeArea(
        bottom: false,
        child: isDesktop
            // Responsive Desktop/Tablet container: centered with sleek max-width
            ? Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 440),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMaroon,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 32,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: authContent,
                ),
              )
            // Mobile full screen
            : authContent,
      ),
    );
  }
}