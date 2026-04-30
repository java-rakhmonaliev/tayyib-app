import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/preferences_service.dart';
import '../models/analysis_result.dart';
import 'result_screen.dart';
import 'scanner_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  String _madhab = 'hanafi';
  bool _isLoading = false;

  final _madhabs = ['hanafi', 'maliki', 'shafii', 'hanbali'];
  final _madhabLabels = ['Hanafi', 'Maliki', "Shafi'i", 'Hanbali'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMadhab();
  }

  Future<void> _loadMadhab() async {
    final madhab = await PreferencesService.getMadhab();
    setState(() => _madhab = madhab);
  }

  Future<void> _setMadhab(String madhab) async {
    HapticFeedback.selectionClick();
    await PreferencesService.setMadhab(madhab);
    setState(() => _madhab = madhab);
  }

  Future<void> _analyzeText() async {
    if (_ingredientsController.text.trim().isEmpty) {
      _showError('Please enter ingredients.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.analyzeText(
        ingredients: _ingredientsController.text.trim(),
        madhab: _madhab,
        productName: _productNameController.text.trim(),
      );
      _navigateToResult(result);
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _analyzeBarcode() async {
    if (_barcodeController.text.trim().isEmpty) {
      _showError('Please enter a barcode.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.analyzeBarcode(
        barcode: _barcodeController.text.trim(),
        madhab: _madhab,
      );
      _navigateToResult(result);
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndAnalyzeImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.analyzeImage(image: File(picked.path), madhab: _madhab);
      _navigateToResult(result);
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToResult(AnalysisResult result) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => ResultScreen(result: result)),
    );
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [CupertinoDialogAction(child: const Text('OK'), onPressed: () => Navigator.pop(context))],
      ),
    );
  }

  void _showProfileSheet() async {
    final user = await AuthService.getSavedUser();
    if (!mounted) return;
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: Text(user?.username ?? ''),
        message: Text(user?.email ?? ''),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
              }
            },
            isDestructiveAction: true,
            child: const Text('Sign Out'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: _isLoading ? _buildLoading() : _buildContent(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoActivityIndicator(radius: 16),
          SizedBox(height: 16),
          Text('Analyzing...', style: TextStyle(fontSize: 15, color: Color(0xFF8E8E93))),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        CupertinoSliverNavigationBar(
          largeTitle: const Text('Tayyib'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _showProfileSheet,
            child: const Icon(CupertinoIcons.person_circle, size: 28, color: Color(0xFF007AFF)),
          ),
          backgroundColor: const Color(0xFFF2F2F7),
          border: null,
        ),
      ],
      body: Column(
        children: [
          _buildMadhabPicker(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTextTab(),
                _buildBarcodeTab(),
                _buildImageTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

Widget _buildMadhabPicker() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
    child: SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'hanafi', label: Text('Hanafi')),
        ButtonSegment(value: 'maliki', label: Text('Maliki')),
        ButtonSegment(value: 'shafii', label: Text("Shafi'i")),
        ButtonSegment(value: 'hanbali', label: Text('Hanbali')),
      ],
      selected: {_madhab},
      onSelectionChanged: (v) => _setMadhab(v.first),
      style: ButtonStyle(
        padding: WidgetStateProperty.all(EdgeInsets.zero), 
        textStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 10, fontWeight: FontWeight.w500), // Slightly smaller font
        ),
      ),
    ),
  );
}

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: const Color(0xFF007AFF),
        unselectedLabelColor: const Color(0xFF8E8E93),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Text'),
          Tab(text: 'Barcode'),
          Tab(text: 'Image'),
        ],
      ),
    );
  }

  Widget _buildTextTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _sectionHeader('INGREDIENTS'),
          _appleCard(
            child: Column(
              children: [
                CupertinoTextField(
                  controller: _ingredientsController,
                  placeholder: 'Paste ingredient list here...',
                  maxLines: 5,
                  minLines: 4,
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(),
                  style: const TextStyle(fontSize: 16),
                  placeholderStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 16),
                ),
                const Divider(height: 1),
                CupertinoTextField(
                  controller: _productNameController,
                  placeholder: 'Product name (optional)',
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(),
                  style: const TextStyle(fontSize: 16),
                  placeholderStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _primaryButton('Analyze Ingredients', const Color(0xFF007AFF), _analyzeText),
        ],
      ),
    );
  }

  Widget _buildBarcodeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _sectionHeader('BARCODE'),
          _appleCard(
            child: CupertinoTextField(
              controller: _barcodeController,
              placeholder: 'e.g. 737628064502',
              keyboardType: TextInputType.number,
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(),
              style: const TextStyle(fontSize: 16),
              placeholderStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 16),
              prefix: const Padding(
                padding: EdgeInsets.only(left: 14),
                child: Icon(CupertinoIcons.barcode, color: Color(0xFF8E8E93), size: 20),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _primaryButton('Scan Barcode', const Color(0xFF8E8E93), () async {
            final barcode = await Navigator.push<String>(
              context,
              CupertinoPageRoute(builder: (_) => const ScannerScreen()),
            );
            if (barcode != null) _barcodeController.text = barcode;
          }),
          const SizedBox(height: 10),
          _primaryButton('Fetch & Analyze', const Color(0xFF007AFF), _analyzeBarcode),
          const SizedBox(height: 12),
          const Center(
            child: Text('Powered by Open Food Facts — 3M+ products',
                style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
          ),
        ],
      ),
    );
  }

  Widget _buildImageTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFD60A).withOpacity(0.5)),
            ),
            child: const Row(
              children: [
                Icon(CupertinoIcons.exclamationmark_triangle, color: Color(0xFFFF9500), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'If the product has a Halal certification logo (MUI, JAKIM, IFANCA), trust that directly.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF7A5C00), height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _primaryButton('Choose from Gallery', const Color(0xFF007AFF),
              () => _pickAndAnalyzeImage(ImageSource.gallery)),
          const SizedBox(height: 10),
          _primaryButton('Take Photo', const Color(0xFF34C759),
              () => _pickAndAnalyzeImage(ImageSource.camera)),
          const SizedBox(height: 12),
          const Center(
            child: Text('Clear photo of ingredient list only',
                style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF8E8E93), letterSpacing: 0.5)),
    );
  }

  Widget _appleCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: child,
    );
  }

Widget _primaryButton(String label, Color color, VoidCallback onTap) {
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
    ),
  );
}

  @override
  void dispose() {
    _tabController.dispose();
    _ingredientsController.dispose();
    _productNameController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }
}