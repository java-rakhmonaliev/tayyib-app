import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _userCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _madhab = 'hanafi';
  bool _loading = false;
  bool _obscure = true;

  static const _madhabs = [
    {
      'value': 'hanafi',
      'label': 'Hanafi',
      'region': 'South Asia · Central Asia · Turkey'
    },
    {'value': 'maliki', 'label': 'Maliki', 'region': 'North & West Africa'},
    {'value': 'shafii', 'label': "Shafi'i", 'region': 'SE Asia · East Africa'},
    {'value': 'hanbali', 'label': 'Hanbali', 'region': 'Gulf countries'},
  ];

  Future<void> _register() async {
    if (_userCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _passCtrl.text.trim().isEmpty) {
      _err('Please fill in all fields.');
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.register(
        username: _userCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
        madhab: _madhab,
      );
      if (mounted)
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (_) => false);
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
    final labelColor = TayyibColors.lbl(context);
    final cardColor = TayyibColors.cardBg(context);
    final secColor = TayyibColors.secondLbl(context);
    final sepColor = TayyibColors.sep(context);

    return Scaffold(
      backgroundColor: TayyibColors.bg(context),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: labelColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text('Create account',
                  style: TayyibText.largeTitle(color: labelColor)),
              const SizedBox(height: 8),
              Text('Join thousands of Muslims making informed food choices.',
                  style: TayyibText.body(color: secColor)),

              const SizedBox(height: 36),

              // Account fields
              _sectionLabel('ACCOUNT'),
              Container(
                decoration: BoxDecoration(
                    color: cardColor, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    _field(
                        ctrl: _userCtrl,
                        hint: 'Username',
                        icon: Icons.person_outline_rounded,
                        isTop: true),
                    Divider(height: 1, color: sepColor, indent: 56),
                    _field(
                        ctrl: _emailCtrl,
                        hint: 'Email',
                        icon: Icons.mail_outline_rounded,
                        keyboard: TextInputType.emailAddress),
                    Divider(height: 1, color: sepColor, indent: 56),
                    _field(
                      ctrl: _passCtrl,
                      hint: 'Password (min 8 characters)',
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

              const SizedBox(height: 32),

              // Madhab selector
              _sectionLabel('SCHOOL OF THOUGHT'),
              Container(
                decoration: BoxDecoration(
                    color: cardColor, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: List.generate(_madhabs.length, (i) {
                    final m = _madhabs[i];
                    final selected = _madhab == m['value'];
                    final isLast = i == _madhabs.length - 1;
                    return Column(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => setState(() => _madhab = m['value']!),
                            borderRadius: BorderRadius.vertical(
                              top: i == 0
                                  ? const Radius.circular(16)
                                  : Radius.zero,
                              bottom: isLast
                                  ? const Radius.circular(16)
                                  : Radius.zero,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 14),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(m['label']!,
                                            style: TayyibText.callout(
                                              color: selected
                                                  ? labelColor
                                                  : labelColor,
                                              weight: selected
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                            )),
                                        const SizedBox(height: 2),
                                        Text(m['region']!,
                                            style: TayyibText.footnote(
                                                color: secColor)),
                                      ],
                                    ),
                                  ),
                                  if (selected)
                                    Icon(Icons.check_rounded,
                                        color: labelColor, size: 20)
                                  else
                                    const SizedBox(width: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (!isLast)
                          Divider(height: 1, color: sepColor, indent: 20),
                      ],
                    );
                  }),
                ),
              ),

              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Determines how ambiguous ingredients are classified. Can be changed later.',
                  style: TayyibText.footnote(color: secColor),
                ),
              ),

              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: _loading ? null : _register,
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
                      : Text('Create account',
                          style: TayyibText.buttonLarge(
                              color: TayyibColors.bg(context))),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10),
        child: Text(text,
            style: TayyibText.sectionHeader(
                color: TayyibColors.secondLbl(context))),
      );

  Widget _field({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    bool obscure = false,
    bool isTop = false,
    bool isBottom = false,
    TextInputType keyboard = TextInputType.text,
    Widget? suffix,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboard,
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
    _userCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }
}
