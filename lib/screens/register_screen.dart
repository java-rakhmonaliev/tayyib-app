import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/brutal_button.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('CREATE ACCOUNT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text('JOIN\nTAYYIB', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: -1, height: 1.1)),
              const SizedBox(height: 8),
              const Text('Create your account to start scanning', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 3),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(6, 6), blurRadius: 0)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('USERNAME'),
                    const SizedBox(height: 8),
                    _textField(controller: _usernameController, hint: 'choose a username'),
                    const SizedBox(height: 16),
                    _label('EMAIL'),
                    const SizedBox(height: 8),
                    _textField(controller: _emailController, hint: 'your@email.com', keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 16),
                    _label('PASSWORD'),
                    const SizedBox(height: 8),
                    _passwordField(),
                    const SizedBox(height: 20),
                    _label('SCHOOL OF THOUGHT (MADHAB)'),
                    const SizedBox(height: 10),
                    _buildMadhabSelector(),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
                  : BrutalButton(label: 'CREATE ACCOUNT →', bg: const Color(0xFFFFD93D), fg: Colors.black, onTap: _register),

              const SizedBox(height: 16),
              const Text(
                '* Your madhab determines how ambiguous ingredients are classified. You can change it anytime.',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMadhabSelector() {
    final madhabs = [
      {'value': 'hanafi', 'label': 'Hanafi', 'desc': 'South Asia, Central Asia, Turkey'},
      {'value': 'maliki', 'label': 'Maliki', 'desc': 'North & West Africa'},
      {'value': 'shafii', 'label': "Shafi'i", 'desc': 'SE Asia, East Africa'},
      {'value': 'hanbali', 'label': 'Hanbali', 'desc': 'Gulf countries'},
    ];

    return Column(
      children: madhabs.map((m) {
        final selected = _madhab == m['value'];
        return GestureDetector(
          onTap: () => setState(() => _madhab = m['value']!),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFFFD93D) : const Color(0xFFFFFDF5),
              border: Border.all(color: Colors.black, width: selected ? 3 : 2),
              boxShadow: selected ? const [BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)] : [],
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: selected ? Colors.black : Colors.transparent,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: selected ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m['label']!, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: selected ? Colors.black : Colors.black87)),
                    Text(m['desc']!, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: selected ? Colors.black54 : Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _label(String text) {
    return Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2));
  }

  Widget _textField({required TextEditingController controller, required String hint, TextInputType keyboardType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          filled: true,
          fillColor: const Color(0xFFFFFDF5),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }

  Widget _passwordField() {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'min 8 characters',
          hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          filled: true,
          fillColor: const Color(0xFFFFFDF5),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
            child: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
          ),
        ),
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