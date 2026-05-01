import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  Future<void> _login() async {
    if (_usernameCtrl.text.trim().isEmpty ||
        _passwordCtrl.text.trim().isEmpty) {
      _err('Please fill in all fields.');
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.login(
          username: _usernameCtrl.text.trim(),
          password: _passwordCtrl.text.trim());
      if (mounted)
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      _err(e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  void _err(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: TayyibText.callout(color: Colors.white)),
      backgroundColor: TayyibColors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = TayyibColors.lbl(context);
    final cardColor = TayyibColors.cardBg(context);
    final secColor = TayyibColors.secondLbl(context);

    return Scaffold(
      backgroundColor: TayyibColors.bg(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 56),

              // Logo
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Center(
                    child: Image.asset(isDark ? 'assets/2.png' : 'assets/1.png',
                        width: 32, height: 32, fit: BoxFit.contain)),
              ),

              const SizedBox(height: 32),
              Text('Sign in', style: TayyibText.largeTitle(color: labelColor)),
              const SizedBox(height: 8),
              Text('Welcome back to Tayyib',
                  style: TayyibText.body(color: secColor)),
              const SizedBox(height: 40),

              // Fields
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _field(
                        controller: _usernameCtrl,
                        hint: 'Username',
                        icon: Icons.person_outline_rounded,
                        isTop: true),
                    Divider(
                        height: 1,
                        color: TayyibColors.sep(context),
                        indent: 56),
                    _field(
                      controller: _passwordCtrl,
                      hint: 'Password',
                      icon: Icons.lock_outline_rounded,
                      obscure: _obscure,
                      isBottom: true,
                      suffix: GestureDetector(
                        onTap: () => setState(() => _obscure = !_obscure),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: secColor,
                              size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: _loading ? null : _login,
                  style: FilledButton.styleFrom(
                    backgroundColor: labelColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                  ),
                  child: _loading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: TayyibColors.bg(context)))
                      : Text('Sign in',
                          style: TayyibText.buttonLarge(
                              color: TayyibColors.bg(context))),
                ),
              ),

              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RegisterScreen())),
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: TayyibText.callout(color: secColor),
                      children: [
                        TextSpan(
                            text: 'Create one',
                            style: TayyibText.callout(
                                color: TayyibColors.blue,
                                weight: FontWeight.w700)),
                      ],
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

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    bool isTop = false,
    bool isBottom = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TayyibText.body(color: TayyibColors.lbl(context)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TayyibText.body(color: TayyibColors.tertiaryLabel),
        prefixIcon:
            Icon(icon, color: TayyibColors.secondLbl(context), size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: TayyibColors.cardBg(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.vertical(
            top: isTop ? const Radius.circular(16) : Radius.zero,
            bottom: isBottom ? const Radius.circular(16) : Radius.zero,
          ),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }
}
