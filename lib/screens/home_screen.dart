import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../services/preferences_service.dart';
import '../models/analysis_result.dart';
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

  Future<void> _analyzeImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
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
      MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF6B6B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD93D),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [BoxShadow(color: Colors.white, offset: Offset(3, 3))],
              ),
              child: const Text('☪', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TAYYIB', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 2)),
                Text('HALAL CHECKER', style: TextStyle(color: Color(0xFFFFD93D), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
              ],
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFFD93D),
          indicatorWeight: 4,
          labelColor: const Color(0xFFFFD93D),
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1),
          tabs: const [
            Tab(icon: Icon(Icons.text_fields), text: 'TEXT'),
            Tab(icon: Icon(Icons.qr_code_scanner), text: 'BARCODE'),
            Tab(icon: Icon(Icons.camera_alt), text: 'IMAGE'),
          ],
        ),
      ),
      body: _isLoading
          ? _buildLoading()
          : Column(
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
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.black),
          SizedBox(height: 16),
          Text('Analyzing...', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildMadhabToggle() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          const Text('MADHAB:', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
          const SizedBox(width: 12),
          _madhabButton('hanafi', 'Hanafi'),
          const SizedBox(width: 8),
          _madhabButton('shafii', "Shafi'i"),
        ],
      ),
    );
  }

  Widget _madhabButton(String value, String label) {
    final selected = _madhab == value;
    return GestureDetector(
      onTap: () => _setMadhab(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFC4B5FD) : Colors.transparent,
          border: Border.all(color: selected ? const Color(0xFFC4B5FD) : Colors.white38, width: 2),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white60,
            fontWeight: FontWeight.w900,
            fontSize: 12,
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
          _label('INGREDIENT LIST'),
          const SizedBox(height: 6),
          _brutalTextField(
            controller: _ingredientsController,
            hint: 'e.g. Water, Sugar, E471, Gelatin...',
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          _label('PRODUCT NAME (OPTIONAL)'),
          const SizedBox(height: 6),
          _brutalTextField(
            controller: _productNameController,
            hint: 'e.g. Oreo Cookies',
          ),
          const SizedBox(height: 24),
          _brutalButton('ANALYZE →', Colors.black, Colors.white, _analyzeText),
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
          _label('BARCODE NUMBER'),
          const SizedBox(height: 6),
          _brutalTextField(
            controller: _barcodeController,
            hint: 'e.g. 737628064502',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _brutalButton(
            '📷  SCAN BARCODE',
            const Color(0xFFFFD93D),
            Colors.black,
            () async {
              final barcode = await Navigator.push<String>(
                context,
                MaterialPageRoute(builder: (_) => const ScannerScreen()),
              );
              if (barcode != null) {
                _barcodeController.text = barcode;
              }
            },
          ),
          const SizedBox(height: 12),
          _brutalButton('FETCH & ANALYZE →', Colors.black, Colors.white, _analyzeBarcode),
          const SizedBox(height: 16),
          const Text(
            'Powered by Open Food Facts — 3M+ products',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 0.5),
          ),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD93D),
              border: Border.all(color: Colors.black, width: 3),
              boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
            ),
            child: const Text(
              '⚠ If the product already has a Halal certification logo (MUI, JAKIM, IFANCA), trust that certification directly.',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
          const SizedBox(height: 24),
          _brutalButton(
            '📁  CHOOSE FROM GALLERY',
            const Color(0xFFC4B5FD),
            Colors.black,
            _analyzeImage,
          ),
          const SizedBox(height: 12),
          _brutalButton(
            '📷  TAKE PHOTO',
            Colors.black,
            Colors.white,
            () async {
              final picker = ImagePicker();
              final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
              if (picked == null) return;
              setState(() => _isLoading = true);
              try {
                final result = await ApiService.analyzeImage(image: File(picked.path), madhab: _madhab);
                _navigateToResult(result);
              } catch (e) {
                _showError(e.toString());
              } finally {
                setState(() => _isLoading = false);
              }
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Clear photo of ingredient list only — JPG/PNG',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5),
    );
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
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          filled: true,
          fillColor: Colors.white,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(12),
        ),
      ),
    );
  }

  Widget _brutalButton(String label, Color bg, Color fg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(5, 5))],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(color: fg, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5),
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