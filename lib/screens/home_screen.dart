import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../services/preferences_service.dart';
import '../models/analysis_result.dart';
import '../widgets/brutal_button.dart';
import 'result_screen.dart';
import 'scanner_screen.dart';

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
      _showError(e.toString());
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
      _showError(e.toString());
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
      final result = await ApiService.analyzeImage(
        image: File(picked.path),
        madhab: _madhab,
      );
      _navigateToResult(result);
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToResult(AnalysisResult result) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => ResultScreen(result: result),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
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
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD93D),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [BoxShadow(color: Colors.white, offset: Offset(3, 3), blurRadius: 0)],
              ),
              child: const Text('☪', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TAYYIB', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 3)),
                Text('HALAL CHECKER', style: TextStyle(color: Color(0xFFFFD93D), fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2)),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.black,
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFFFFD93D),
              indicatorWeight: 3,
              labelColor: const Color(0xFFFFD93D),
              unselectedLabelColor: Colors.white38,
              labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5),
              tabs: const [
                Tab(icon: Icon(Icons.text_fields, size: 18), text: 'TEXT'),
                Tab(icon: Icon(Icons.qr_code_scanner, size: 18), text: 'BARCODE'),
                Tab(icon: Icon(Icons.camera_alt, size: 18), text: 'IMAGE'),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading ? _buildLoading() : Column(
        children: [
          _buildMadhabToggle(),
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

  Widget _buildLoading() {
    return Container(
      color: const Color(0xFFFFFDF5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(6, 6), blurRadius: 0)],
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3),
              ),
              SizedBox(height: 16),
              Text('ANALYZING...', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2)),
              SizedBox(height: 4),
              Text('Checking Islamic dietary rules', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMadhabToggle() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          const Text('MADHAB:', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(width: 12),
          _madhabBtn('hanafi', 'Hanafi'),
          const SizedBox(width: 8),
          _madhabBtn('shafii', "Shafi'i"),
        ],
      ),
    );
  }

  Widget _madhabBtn(String value, String label) {
    final selected = _madhab == value;
    return GestureDetector(
      onTap: () => _setMadhab(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFD93D) : Colors.transparent,
          border: Border.all(
            color: selected ? const Color(0xFFFFD93D) : Colors.white24,
            width: 2,
          ),
          boxShadow: selected
              ? const [BoxShadow(color: Color(0xFFFFD93D), offset: Offset(3, 3), blurRadius: 0)]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white54,
            fontWeight: FontWeight.w900,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
        ),
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
          _label('INGREDIENT LIST'),
          const SizedBox(height: 8),
          _brutalTextField(controller: _ingredientsController, hint: 'e.g. Water, Sugar, E471, Gelatin...', maxLines: 5),
          const SizedBox(height: 16),
          _label('PRODUCT NAME (OPTIONAL)'),
          const SizedBox(height: 8),
          _brutalTextField(controller: _productNameController, hint: 'e.g. Oreo Cookies'),
          const SizedBox(height: 24),
          BrutalButton(label: 'ANALYZE →', bg: Colors.black, fg: Colors.white, onTap: _analyzeText),
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
          _label('BARCODE NUMBER'),
          const SizedBox(height: 8),
          _brutalTextField(controller: _barcodeController, hint: 'e.g. 737628064502', keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          BrutalButton(
            label: '📷  SCAN BARCODE',
            bg: const Color(0xFFFFD93D),
            fg: Colors.black,
            onTap: () async {
              final barcode = await Navigator.push<String>(
                context,
                MaterialPageRoute(builder: (_) => const ScannerScreen()),
              );
              if (barcode != null) _barcodeController.text = barcode;
            },
          ),
          const SizedBox(height: 12),
          BrutalButton(label: 'FETCH & ANALYZE →', bg: Colors.black, fg: Colors.white, onTap: _analyzeBarcode),
          const SizedBox(height: 16),
          const Text('Powered by Open Food Facts — 3M+ products',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildImageTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD93D),
              border: Border.all(color: Colors.black, width: 3),
              boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)],
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('⚠', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'If the product has a Halal certification logo (MUI, JAKIM, IFANCA, HMC), trust that certification directly. This tool is for products without one.',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          BrutalButton(
            label: '📁  CHOOSE FROM GALLERY',
            bg: const Color(0xFFC4B5FD),
            fg: Colors.black,
            onTap: () => _pickAndAnalyzeImage(ImageSource.gallery),
          ),
          const SizedBox(height: 12),
          BrutalButton(
            label: '📷  TAKE PHOTO',
            bg: Colors.black,
            fg: Colors.white,
            onTap: () => _pickAndAnalyzeImage(ImageSource.camera),
          ),
          const SizedBox(height: 16),
          const Text('Clear photo of ingredient list only — JPG/PNG up to 10MB',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.black));
  }

  Widget _brutalTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 14),
          filled: true,
          fillColor: Colors.white,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
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