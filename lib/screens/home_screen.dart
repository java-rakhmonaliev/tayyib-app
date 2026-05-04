import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/community_service.dart';
import '../services/preferences_service.dart';
import '../models/analysis_result.dart';
import 'result_screen.dart';
import 'scanner_screen.dart';
import 'login_screen.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _ingredientsCtrl = TextEditingController();
  final _productNameCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController();
  String _madhab = 'hanafi';
  bool _isLoading = false;

  static const _madhabs = [
    {'value': 'hanafi', 'label': 'Hanafi'},
    {'value': 'maliki', 'label': 'Maliki'},
    {'value': 'shafii', 'label': "Shafi'i"},
    {'value': 'hanbali', 'label': 'Hanbali'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    PreferencesService.getMadhab().then((v) => setState(() => _madhab = v));
  }

  Future<void> _setMadhab(String v) async {
    HapticFeedback.selectionClick();
    await PreferencesService.setMadhab(v);
    setState(() => _madhab = v);
  }

  Future<void> _analyzeText() async {
    if (_ingredientsCtrl.text.trim().isEmpty) {
      _err('Please enter ingredients.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final r = await ApiService.analyzeText(
        ingredients: _ingredientsCtrl.text.trim(),
        madhab: _madhab,
        productName: _productNameCtrl.text.trim(),
      );
      _go(r);
    } catch (e) {
      _err(e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _analyzeBarcode() async {
    final barcode = _barcodeCtrl.text.trim();
    if (barcode.isEmpty) {
      _err('Please enter a barcode.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final r = await ApiService.analyzeBarcode(
        barcode: barcode,
        madhab: _madhab,
      );
      _go(r);
    } on BarcodeNotFoundException {
      // Don't show a red toast — show the helpful fallback sheet instead
      _showProductNotFoundSheet(barcode);
    } catch (e) {
      _err(e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource src) async {
    final p = await ImagePicker().pickImage(source: src, imageQuality: 85);
    if (p == null) return;
    setState(() => _isLoading = true);
    try {
      final r =
          await ApiService.analyzeImage(image: File(p.path), madhab: _madhab);
      _go(r);
    } catch (e) {
      _err(e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _go(AnalysisResult r) => Navigator.push(
      context, MaterialPageRoute(builder: (_) => ResultScreen(result: r)));

  void _err(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: TayyibText.callout(color: Colors.white)),
      backgroundColor: TayyibColors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  void _showProductNotFoundSheet(String barcode) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      builder: (_) => _ProductNotFoundSheet(
        barcode: barcode,
        madhab: _madhab,
        onScanLabel: () {
          Navigator.pop(context);
          // Switch to the Image tab and open camera immediately
          _tabController.animateTo(2);
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) _pickImage(ImageSource.camera);
          });
        },
        onRetry: () => Navigator.pop(context),
      ),
    );
  }

  void _showProfile() async {
    final user = await AuthService.getSavedUser();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _ProfileSheet(
        username: user?.username ?? '',
        email: user?.email ?? '',
        madhab: user?.madhab ?? '',
        onLogout: () async {
          Navigator.pop(context);
          await AuthService.logout();
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (_) => false,
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final labelColor = TayyibColors.lbl(context);
    final bgColor = TayyibColors.bg(context);
    final cardColor = TayyibColors.cardBg(context);
    final secColor = TayyibColors.secondLbl(context);

    return Scaffold(
      backgroundColor: bgColor,
      body: _isLoading
          ? _buildLoading(secColor)
          : _buildBody(labelColor, bgColor, cardColor, secColor),
    );
  }

  Widget _buildLoading(Color secColor) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircularProgressIndicator(strokeWidth: 2),
          const SizedBox(height: 16),
          Text('Analyzing...', style: TayyibText.callout(color: secColor)),
        ]),
      );

  Widget _buildBody(
      Color labelColor, Color bgColor, Color cardColor, Color secColor) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
            child: Row(
              children: [
                Expanded(
                    child: Text('Tayyib',
                        style: TayyibText.largeTitle(color: labelColor))),
                IconButton(
                  onPressed: _showProfile,
                  icon: Icon(Icons.person_outline_rounded,
                      color: labelColor, size: 26),
                  style: IconButton.styleFrom(
                    backgroundColor: TayyibColors.fillC(context),
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Madhab chips
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _madhabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final m = _madhabs[i];
                final selected = _madhab == m['value'];
                return GestureDetector(
                  onTap: () => _setMadhab(m['value']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? labelColor : cardColor,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      m['label']!,
                      style: TayyibText.callout(
                        color: selected ? bgColor : secColor,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Tab bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                  color: cardColor, borderRadius: BorderRadius.circular(12)),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: TayyibColors.fillC(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(3),
                labelColor: labelColor,
                unselectedLabelColor: secColor,
                labelStyle: TayyibText.callout(weight: FontWeight.w700),
                unselectedLabelStyle:
                    TayyibText.callout(weight: FontWeight.w500),
                tabs: const [
                  Tab(text: 'Text'),
                  Tab(text: 'Barcode'),
                  Tab(text: 'Image'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 4),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _textTab(labelColor, cardColor, secColor),
                _barcodeTab(labelColor, cardColor, secColor),
                _imageTab(cardColor, secColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Text Tab ──────────────────────────────────────────────────────────────

  Widget _textTab(Color lbl, Color card, Color sec) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('INGREDIENTS', style: TayyibText.sectionHeader(color: sec)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
              color: card, borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            TextField(
              controller: _ingredientsCtrl,
              maxLines: 5,
              minLines: 4,
              style: TayyibText.body(color: lbl),
              decoration: InputDecoration(
                hintText: 'Paste ingredient list here...',
                hintStyle: TayyibText.body(color: TayyibColors.tertiaryLabel),
                filled: true,
                fillColor: card,
                border: OutlineInputBorder(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            Divider(height: 1, color: TayyibColors.sep(context)),
            TextField(
              controller: _productNameCtrl,
              style: TayyibText.body(color: lbl),
              decoration: InputDecoration(
                hintText: 'Product name (optional)',
                hintStyle: TayyibText.body(color: TayyibColors.tertiaryLabel),
                filled: true,
                fillColor: card,
                border: OutlineInputBorder(
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(16)),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 20),
        _btn('Analyze ingredients', _analyzeText),
      ]),
    );
  }

  // ─── Barcode Tab ───────────────────────────────────────────────────────────

  Widget _barcodeTab(Color lbl, Color card, Color sec) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('BARCODE', style: TayyibText.sectionHeader(color: sec)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
              color: card, borderRadius: BorderRadius.circular(16)),
          child: TextField(
            controller: _barcodeCtrl,
            keyboardType: TextInputType.number,
            style: TayyibText.body(color: lbl),
            decoration: InputDecoration(
              hintText: 'e.g. 737628064502',
              hintStyle: TayyibText.body(color: TayyibColors.tertiaryLabel),
              prefixIcon: Icon(Icons.barcode_reader, color: sec, size: 20),
              filled: true,
              fillColor: card,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _btn('Scan barcode', () async {
          final code = await Navigator.push<String>(context,
              MaterialPageRoute(builder: (_) => const ScannerScreen()));
          if (code != null) _barcodeCtrl.text = code;
        }, secondary: true),
        const SizedBox(height: 10),
        _btn('Fetch & analyze', _analyzeBarcode),
        const SizedBox(height: 16),
        Center(
            child: Text('Powered by Open Food Facts — 3M+ products',
                style: TayyibText.footnote(color: sec))),
      ]),
    );
  }

  // ─── Image Tab ─────────────────────────────────────────────────────────────

  Widget _imageTab(Color card, Color sec) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TayyibColors.orangeTint,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.info_outline_rounded,
                color: TayyibColors.orange, size: 20),
            const SizedBox(width: 12),
            Expanded(
                child: Text(
              'If the product has a Halal logo (MUI, JAKIM, IFANCA), trust that certification directly.',
              style: TayyibText.footnote(color: const Color(0xFF7A5000)),
            )),
          ]),
        ),
        const SizedBox(height: 16),
        _btn('Choose from gallery', () => _pickImage(ImageSource.gallery)),
        const SizedBox(height: 10),
        _btn('Take photo', () => _pickImage(ImageSource.camera),
            secondary: true),
        const SizedBox(height: 12),
        Center(
            child: Text('Clear photo of ingredient list only',
                style: TayyibText.footnote(color: sec))),
      ]),
    );
  }

  // ─── Shared button ─────────────────────────────────────────────────────────

  Widget _btn(String label, VoidCallback onTap, {bool secondary = false}) {
    final labelColor = TayyibColors.lbl(context);
    final bgColor = TayyibColors.bg(context);
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: secondary ? TayyibColors.fillC(context) : labelColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          elevation: 0,
        ),
        child: Text(label,
            style: TayyibText.buttonLarge(
                color: secondary ? TayyibColors.secondLbl(context) : bgColor)),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ingredientsCtrl.dispose();
    _productNameCtrl.dispose();
    _barcodeCtrl.dispose();
    super.dispose();
  }
}

// ─── Product Not Found Sheet ──────────────────────────────────────────────────

class _ProductNotFoundSheet extends StatefulWidget {
  final String barcode;
  final String madhab;
  final VoidCallback onScanLabel;
  final VoidCallback onRetry;

  const _ProductNotFoundSheet({
    required this.barcode,
    required this.madhab,
    required this.onScanLabel,
    required this.onRetry,
  });

  @override
  State<_ProductNotFoundSheet> createState() => _ProductNotFoundSheetState();
}

class _ProductNotFoundSheetState extends State<_ProductNotFoundSheet>
    with SingleTickerProviderStateMixin {
  bool _showCrowdsource = false;
  bool _submitting = false;
  bool _submitted = false;
  final _nameCtrl = TextEditingController();

  late final AnimationController _expandCtrl;
  late final Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _expandCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _expandAnim = CurvedAnimation(
      parent: _expandCtrl,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _expandCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _toggleCrowdsource() {
    HapticFeedback.selectionClick();
    setState(() => _showCrowdsource = !_showCrowdsource);
    if (_showCrowdsource) {
      _expandCtrl.forward();
    } else {
      _expandCtrl.reverse();
    }
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    setState(() => _submitting = true);
    try {
      await CommunityService.submitMissingProduct(
        barcode: widget.barcode,
        productName: name,
      );
      HapticFeedback.lightImpact();
      setState(() {
        _submitted = true;
        _submitting = false;
      });
      await Future.delayed(const Duration(milliseconds: 1400));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _submitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
            style: TayyibText.callout(color: Colors.white),
          ),
          backgroundColor: TayyibColors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lbl = TayyibColors.lbl(context);
    final sec = TayyibColors.secondLbl(context);
    final card = TayyibColors.cardBg(context);
    final fill = TayyibColors.fillC(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Drag handle ─────────────────────────────────────────────────
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: TayyibColors.sep(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Status zone ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: fill,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.inventory_2_outlined, color: sec, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product not found',
                        style: TayyibText.headline(color: lbl),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Not in Open Food Facts or our database.',
                        style: TayyibText.footnote(color: sec),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Barcode chip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.tag_rounded, size: 12, color: sec),
                  const SizedBox(width: 4),
                  Text(
                    widget.barcode,
                    style: TayyibText.caption1(color: sec),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          Divider(
              height: 1,
              color: TayyibColors.sep(context),
              indent: 20,
              endIndent: 20),
          const SizedBox(height: 20),

          // ── Primary CTA: Scan label ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _SheetActionButton(
              icon: Icons.photo_camera_outlined,
              iconColor: TayyibColors.blue,
              iconBg: TayyibColors.blue.withOpacity(isDark ? 0.18 : 0.1),
              title: 'Scan the ingredient label',
              subtitle: 'Point camera at the back of the package',
              onTap: widget.onScanLabel,
            ),
          ),

          const SizedBox(height: 10),

          // ── Secondary CTA: Crowdsource ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SheetActionButton(
                  icon: _submitted
                      ? Icons.check_circle_rounded
                      : Icons.people_outline_rounded,
                  iconColor:
                      _submitted ? TayyibColors.green : TayyibColors.orange,
                  iconBg:
                      (_submitted ? TayyibColors.green : TayyibColors.orange)
                          .withOpacity(isDark ? 0.18 : 0.1),
                  title:
                      _submitted ? 'Thanks for helping!' : 'Help the community',
                  subtitle: _submitted
                      ? 'Product name saved for others'
                      : 'Do you know this product? Tell us',
                  trailing: _submitted
                      ? null
                      : Icon(
                          _showCrowdsource
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: sec,
                          size: 20,
                        ),
                  onTap: _submitted ? null : _toggleCrowdsource,
                ),

                // Expandable input
                SizeTransition(
                  sizeFactor: _expandAnim,
                  axisAlignment: -1,
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: fill,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: TextField(
                          controller: _nameCtrl,
                          style: TayyibText.body(color: lbl),
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            hintText: 'Product name (e.g. Oreo Original)',
                            hintStyle: TayyibText.body(
                                color: TayyibColors.tertiaryLabel),
                            filled: true,
                            fillColor: fill,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                  color: TayyibColors.primary, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: _submitting ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: TayyibColors.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50)),
                            elevation: 0,
                          ),
                          child: _submitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text('Submit', style: TayyibText.buttonLarge()),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Ghost: try again ─────────────────────────────────────────────
          Center(
            child: GestureDetector(
              onTap: widget.onRetry,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'Try scanning again',
                  style: TayyibText.callout(color: sec),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── Reusable action row inside the sheet ─────────────────────────────────────

class _SheetActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SheetActionButton({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lbl = TayyibColors.lbl(context);
    final sec = TayyibColors.secondLbl(context);
    final fill = TayyibColors.fillC(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TayyibText.callout(
                          color: lbl, weight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TayyibText.footnote(color: sec)),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Profile Bottom Sheet ─────────────────────────────────────────────────────

class _ProfileSheet extends StatefulWidget {
  final String username;
  final String email;
  final String madhab;
  final VoidCallback onLogout;

  const _ProfileSheet({
    required this.username,
    required this.email,
    required this.madhab,
    required this.onLogout,
  });

  @override
  State<_ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<_ProfileSheet> {
  late ThemeMode _mode;

  @override
  void initState() {
    super.initState();
    _mode = themeModeNotifier.value;
  }

  Future<void> _setMode(ThemeMode mode) async {
    setState(() => _mode = mode);
    themeModeNotifier.value = mode;
    await PreferencesService.setThemeMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    final lbl = TayyibColors.lbl(context);
    final sec = TayyibColors.secondLbl(context);
    final card = TayyibColors.cardBg(context);
    final fill = TayyibColors.fillC(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: TayyibColors.sep(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 28),

          // Avatar + name
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
            child: Icon(Icons.person_rounded, size: 32, color: sec),
          ),
          const SizedBox(height: 14),
          Text(widget.username, style: TayyibText.title2(color: lbl)),
          const SizedBox(height: 4),
          Text(widget.email, style: TayyibText.callout(color: sec)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              widget.madhab.toUpperCase(),
              style: TayyibText.caption1(color: sec),
            ),
          ),

          const SizedBox(height: 28),

          // Appearance picker
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _modeChip(
                    icon: Icons.wb_sunny_rounded,
                    label: 'Light',
                    active: _mode == ThemeMode.light,
                    onTap: () => _setMode(ThemeMode.light),
                    lbl: lbl,
                    card: card,
                  ),
                  _modeChip(
                    icon: Icons.brightness_auto_rounded,
                    label: 'Auto',
                    active: _mode == ThemeMode.system,
                    onTap: () => _setMode(ThemeMode.system),
                    lbl: lbl,
                    card: card,
                  ),
                  _modeChip(
                    icon: Icons.nightlight_round,
                    label: 'Dark',
                    active: _mode == ThemeMode.dark,
                    onTap: () => _setMode(ThemeMode.dark),
                    lbl: lbl,
                    card: card,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Sign out
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: widget.onLogout,
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: TayyibColors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded,
                        color: TayyibColors.red, size: 18),
                    const SizedBox(width: 8),
                    Text('Sign out',
                        style: TayyibText.buttonLarge(color: TayyibColors.red)),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _modeChip({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
    required Color lbl,
    required Color card,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? card : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: active
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 20, color: active ? lbl : TayyibColors.secondaryLabel),
              const SizedBox(height: 4),
              Text(
                label,
                style: TayyibText.caption1(
                  color: active ? lbl : TayyibColors.secondaryLabel,
                  weight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
