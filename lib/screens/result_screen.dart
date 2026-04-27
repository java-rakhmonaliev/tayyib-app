import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    // Haptic feedback
    if (result.overallStatus == 'haram') {
      HapticFeedback.heavyImpact();
    } else if (result.overallStatus == 'halal') {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.mediumImpact();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('RESULT',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 3)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            _buildVerdictBanner(),
            const SizedBox(height: 16),
            if (result.hasHalalLogo) ...[_buildHalalLogoBanner(), const SizedBox(height: 16)],
            if (result.product != null) ...[_buildProductCard(), const SizedBox(height: 16)],
            _buildSectionHeader('🔬 INGREDIENT BREAKDOWN', '${result.ingredients.length}'),
            const SizedBox(height: 8),
            ...result.ingredients.map((ing) => _ingredientRow(ing)),
            if (result.unknownIngredients.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSectionHeader('❓ UNRECOGNIZED', '${result.unknownIngredients.length}'),
              const SizedBox(height: 8),
              _buildUnknowns(),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildVerdictBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _statusColor,
        border: Border.all(color: Colors.black, width: 4),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(8, 8), blurRadius: 0)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_statusEmoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              result.overallStatus.toUpperCase(),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
                height: 1,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 6),
          if (result.productName.isNotEmpty) ...[
            Text(result.productName,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 2),
          ],
          Text(
            '${result.madhab.toUpperCase()} MADHAB${result.aiUsed ? ' · AI-ASSISTED' : ''}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 1.5, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildHalalLogoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF6EE7B7),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)],
      ),
      child: Row(
        children: [
          const Text('☑️', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('HALAL CERTIFIED',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5)),
                if (result.halalLogoName != null)
                  Text(result.halalLogoName!,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(5, 5), blurRadius: 0)],
      ),
      child: Row(
        children: [
          if (result.product!['image_url'] != null &&
              result.product!['image_url'].toString().isNotEmpty)
            Container(
              width: 64,
              height: 64,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
              child: Image.network(result.product!['image_url'], fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox()),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.product!['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                if (result.product!['brands'] != null)
                  Text(result.product!['brands'],
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String count) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          color: Colors.black,
          child: Text(count,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
        ),
      ],
    );
  }

  Widget _ingredientRow(IngredientResult ing) {
    Color borderColor;
    Color bgColor;
    Color badgeColor;

    switch (ing.status) {
      case 'halal':
        borderColor = const Color(0xFF10b981);
        bgColor = const Color(0xFFf0fdf4);
        badgeColor = const Color(0xFF10b981);
        break;
      case 'haram':
      case 'hanafi_haram':
      case 'shafii_haram':
        borderColor = const Color(0xFFFF6B6B);
        bgColor = const Color(0xFFfff0f0);
        badgeColor = const Color(0xFFFF6B6B);
        break;
      default:
        borderColor = const Color(0xFFf59e0b);
        bgColor = const Color(0xFFfffbeb);
        badgeColor = const Color(0xFFf59e0b);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          left: BorderSide(color: borderColor, width: 5),
          top: BorderSide(color: Colors.black12, width: 1),
          right: BorderSide(color: Colors.black12, width: 1),
          bottom: BorderSide(color: Colors.black12, width: 1),
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                ing.status == 'halal' ? '✅' : ing.status.contains('haram') ? '❌' : '⚠️',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(ing.original,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.black)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor,
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Text(
                  ing.status.toUpperCase().replaceAll('_', ' '),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 8, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          if (ing.source.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(ing.source,
                style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600, height: 1.4)),
          ],
          if (ing.aiClassified) ...[
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFede9fe),
                border: Border.all(color: const Color(0xFF7c3aed), width: 1),
              ),
              child: const Text('AI',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF7c3aed), letterSpacing: 1)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUnknowns() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: result.unknownIngredients
          .map((u) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD93D),
                  border: Border.all(color: Colors.black, width: 2),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 0)],
                ),
                child: Text(u, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              ))
          .toList(),
    );
  }
}