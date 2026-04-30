import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _madhab = 'hanafi';
  bool _isLoading = false;
  bool _obscurePassword = true;

  final _madhabs = [
    {'value': 'hanafi', 'label': 'Hanafi', 'region': 'South Asia, Central Asia, Turkey'},
    {'value': 'maliki', 'label': 'Maliki', 'region': 'North & West Africa'},
    {'value': 'shafii', 'label': "Shafi'i", 'region': 'SE Asia, East Africa'},
    {'value': 'hanbali', 'label': 'Hanbali', 'region': 'Gulf countries'},
  ];

  Future<void> _register() async {
    if (_usernameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showError('Please fill in all fields.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await AuthService.register(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        madhab: _madhab,
      );
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (_) => false,
        );
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F7),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text('Create Account',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black)),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Color(0xFF007AFF)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/1.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text('Create your account to start scanning',
                    style: TextStyle(fontSize: 15, color: Color(0xFF8E8E93))),
              ),

              const SizedBox(height: 32),

              // Account details
              _sectionLabel('ACCOUNT DETAILS'),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _field(
                      controller: _usernameController,
                      hint: 'Username',
                      icon: CupertinoIcons.person,
                      isFirst: true,
                      isLast: false,
                    ),
                    const Divider(height: 1, indent: 52),
                    _field(
                      controller: _emailController,
                      hint: 'Email',
                      icon: CupertinoIcons.mail,
                      keyboardType: TextInputType.emailAddress,
                      isFirst: false,
                      isLast: false,
                    ),
                    const Divider(height: 1, indent: 52),
                    _field(
                      controller: _passwordController,
                      hint: 'Password (min 8 characters)',
                      icon: CupertinoIcons.lock,
                      obscure: _obscurePassword,
                      isFirst: false,
                      isLast: true,
                      suffix: GestureDetector(
                        onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Icon(
                            _obscurePassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                            color: const Color(0xFF8E8E93),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Madhab
              _sectionLabel('SCHOOL OF THOUGHT (MADHAB)'),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: _madhabs.asMap().entries.map((entry) {
                    final i = entry.key;
                    final m = entry.value;
                    final selected = _madhab == m['value'];
                    final isLast = i == _madhabs.length - 1;
                    return Column(
                      children: [
                        InkWell(
                          onTap: () => setState(() => _madhab = m['value']!),
                          borderRadius: BorderRadius.vertical(
                            top: i == 0 ? const Radius.circular(12) : Radius.zero,
                            bottom: isLast ? const Radius.circular(12) : Radius.zero,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        m['label']!,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: selected ? const Color(0xFF007AFF) : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        m['region']!,
                                        style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: selected
                                      ? const Icon(CupertinoIcons.checkmark, color: Color(0xFF007AFF), size: 18, key: ValueKey('check'))
                                      : const SizedBox(width: 18, key: ValueKey('empty')),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (!isLast) const Divider(height: 1, indent: 16),
                      ],
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Your madhab determines how ambiguous ingredients are classified. You can change this in settings.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF8E8E93), height: 1.4),
                ),
              ),

              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _isLoading ? null : _register,
                  color: const Color(0xFF007AFF),
                  borderRadius: BorderRadius.circular(12),
                  child: _isLoading
                      ? const CupertinoActivityIndicator(color: Colors.white)
                      : const Text('Create Account',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF8E8E93), letterSpacing: 0.5),
      ),
    );
  }

  // Updated Field helper
  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    bool isFirst = false,
    bool isLast = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      // FIX: Force typing color to black for Dark Mode compatibility
      style: const TextStyle(fontSize: 16, color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 16),
        prefixIcon: Icon(icon, color: const Color(0xFF8E8E93), size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(12) : Radius.zero,
            bottom: isLast ? const Radius.circular(12) : Radius.zero,
          ),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}