import 'package:flutter/material.dart';
import '../models/analysis_result.dart';

class ResultScreen extends StatelessWidget {
  final AnalysisResult result;

  const ResultScreen({super.key, required this.result});

  Color get _statusColor {
    switch (result.overallStatus) {
      case 'halal': return const Color(0xFF6EE7B7);
      case 'haram': return const Color(0xFFFF6B6B);
      default: return const Color(0xFFFFD93D);
    }
  }

  String get _statusEmoji {
    switch (result.overallStatus) {
      case 'halal': return '✅';
      case 'haram': return '❌';
      default: return '⚠️';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('RESULT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Verdict banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _statusColor,
                border: Border.all(color: Colors.black, width: 4),
                boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(8, 8))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_statusEmoji, style: const TextStyle(fontSize: 36)),
                  const SizedBox(height: 8),
                  Text(
                    result.overallStatus.toUpperCase(),
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  ),
                  if (result.productName.isNotEmpty)
                    Text(result.productName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(
                    '${result.madhab.toUpperCase()} MADHAB${result.aiUsed ? ' · AI-ASSISTED' : ''}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Halal logo banner
            if (result.hasHalalLogo) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6EE7B7),
                  border: Border.all(color: Colors.black, width: 3),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                ),
                child: Row(
                  children: [
                    const Text('☑️', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Halal certified${result.halalLogoName != null ? ': ${result.halalLogoName}' : ''}',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Product info
            if (result.product != null) ...[
              _card(
                child: Row(
                  children: [
                    if (result.product!['image_url'] != null && result.product!['image_url'].toString().isNotEmpty)
                      Container(
                        width: 70,
                        height: 70,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
                        child: Image.network(result.product!['image_url'], fit: BoxFit.contain),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(result.product!['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                          if (result.product!['brands'] != null)
                            Text(result.product!['brands'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Ingredients
            _sectionHeader('🔬 INGREDIENT BREAKDOWN', '${result.ingredients.length}'),
            const SizedBox(height: 8),
            ...result.ingredients.map((ing) => _ingredientRow(ing)),

            // Unknowns
            if (result.unknownIngredients.isNotEmpty) ...[
              const SizedBox(height: 16),
              _sectionHeader('❓ UNRECOGNIZED', '${result.unknownIngredients.length}'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: result.unknownIngredients.map((u) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD93D),
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
                  ),
                  child: Text(u, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                )).toList(),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(5, 5))],
      ),
      child: child,
    );
  }

  Widget _sectionHeader(String title, String count) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Text(count, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
        ),
      ],
    );
  }

  Widget _ingredientRow(IngredientResult ing) {
    Color borderColor;
    Color bgColor;
    switch (ing.status) {
      case 'halal':
        borderColor = const Color(0xFF10b981);
        bgColor = const Color(0xFFf0fdf4);
        break;
      case 'haram':
      case 'hanafi_haram':
      case 'shafii_haram':
        borderColor = const Color(0xFFFF6B6B);
        bgColor = const Color(0xFFfff0f0);
        break;
      default:
        borderColor = const Color(0xFFf59e0b);
        bgColor = const Color(0xFFfffbeb);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(left: BorderSide(color: borderColor, width: 5)),
        boxShadow: const [BoxShadow(color: Colors.black12, offset: Offset(2, 2))],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                ing.status == 'halal' ? '✅' : ing.status == 'haram' ? '❌' : '⚠️',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  ing.original,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: borderColor,
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Text(
                  ing.status.toUpperCase().replaceAll('_', ' '),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          if (ing.source.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(ing.source, style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600)),
          ],
          if (ing.aiClassified) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              color: const Color(0xFFede9fe),
              child: const Text('AI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF7c3aed), letterSpacing: 1)),
            ),
          ],
        ],
      ),
    );
  }
}