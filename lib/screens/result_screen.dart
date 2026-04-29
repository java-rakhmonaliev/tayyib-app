import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../models/analysis_result.dart';
import '../services/community_service.dart';
import '../services/auth_service.dart';

class ResultScreen extends StatefulWidget {
  final AnalysisResult result;
  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  CommunityScore? _communityScore;
  String? _myVote;
  bool _loadingScore = false;
  bool _submittingVote = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    if (widget.result.barcode.isNotEmpty) _loadCommunityData();
    _checkLogin();
    _triggerHaptic();
  }

  void _triggerHaptic() {
    if (widget.result.overallStatus == 'haram') {
      HapticFeedback.heavyImpact();
    } else if (widget.result.overallStatus == 'halal') {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> _checkLogin() async {
    final loggedIn = await AuthService.isLoggedIn();
    setState(() => _isLoggedIn = loggedIn);
  }

  Future<void> _loadCommunityData() async {
    setState(() => _loadingScore = true);
    try {
      final score = await CommunityService.getScore(widget.result.barcode);
      final myVote = await CommunityService.getMyVote(widget.result.barcode);
      setState(() { _communityScore = score; _myVote = myVote; });
    } catch (_) {}
    setState(() => _loadingScore = false);
  }

  Future<void> _submitVote(String vote) async {
    setState(() => _submittingVote = true);
    try {
      await CommunityService.submitVote(
        barcode: widget.result.barcode,
        vote: vote,
        madhab: widget.result.madhab,
        productName: widget.result.productName,
      );
      setState(() => _myVote = vote);
      await _loadCommunityData();
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title: const Text('JazakAllahu Khayran'),
            content: const Text('Your vote helps the community find halal food.'),
            actions: [CupertinoDialogAction(child: const Text('OK'), onPressed: () => Navigator.pop(context))],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text(e.toString()),
            actions: [CupertinoDialogAction(child: const Text('OK'), onPressed: () => Navigator.pop(context))],
          ),
        );
      }
    }
    setState(() => _submittingVote = false);
  }

  Color get _statusColor {
    switch (widget.result.overallStatus) {
      case 'halal': return const Color(0xFF34C759);
      case 'haram': return const Color(0xFFFF3B30);
      default: return const Color(0xFFFF9500);
    }
  }

  String get _statusEmoji {
    switch (widget.result.overallStatus) {
      case 'halal': return '✅';
      case 'haram': return '❌';
      default: return '⚠️';
    }
  }

  String get _statusLabel {
    switch (widget.result.overallStatus) {
      case 'halal': return 'Halal';
      case 'haram': return 'Haram';
      default: return 'Questionable';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text('Result', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Icon(CupertinoIcons.back, color: Color(0xFF007AFF)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVerdictCard(),
            const SizedBox(height: 16),
            if (widget.result.hasHalalLogo) ...[_buildHalalLogoBanner(), const SizedBox(height: 16)],
            if (widget.result.product != null) ...[_buildProductCard(), const SizedBox(height: 16)],
            if (widget.result.barcode.isNotEmpty) ...[_buildCommunityScore(), const SizedBox(height: 16)],
            _buildIngredientSection(),
            if (widget.result.unknownIngredients.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildUnknownsSection(),
            ],
            if (widget.result.barcode.isNotEmpty && _isLoggedIn) ...[
              const SizedBox(height: 16),
              _buildVotingSection(),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildVerdictCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _statusColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: _statusColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_statusEmoji, style: const TextStyle(fontSize: 44)),
          const SizedBox(height: 8),
          Text(_statusLabel,
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1, height: 1)),
          const SizedBox(height: 8),
          if (widget.result.productName.isNotEmpty)
            Text(widget.result.productName, style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w500)),
          Text(
            '${widget.result.madhab.toUpperCase()} MADHAB${widget.result.aiUsed ? ' · AI' : ''}',
            style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildHalalLogoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF34C759).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.checkmark_seal_fill, color: Color(0xFF34C759), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Halal Certified', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1A7A3F))),
                if (widget.result.halalLogoName != null)
                  Text(widget.result.halalLogoName!, style: const TextStyle(fontSize: 13, color: Color(0xFF34C759))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          if (widget.result.product!['image_url'] != null && widget.result.product!['image_url'].toString().isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(widget.result.product!['image_url'], width: 56, height: 56, fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox()),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.result.product!['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                if (widget.result.product!['brands'] != null)
                  Text(widget.result.product!['brands'], style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityScore() {
    if (_loadingScore) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: const Row(
          children: [
            CupertinoActivityIndicator(),
            SizedBox(width: 12),
            Text('Loading community data...', style: TextStyle(color: Color(0xFF8E8E93), fontSize: 14)),
          ],
        ),
      );
    }

    final score = _communityScore;
    if (score == null) return const SizedBox();

    Color verdictColor;
    String verdictLabel;
    IconData verdictIcon;

    switch (score.communityVerdict) {
      case 'halal':
        verdictColor = const Color(0xFF34C759);
        verdictLabel = 'Community says: Halal';
        verdictIcon = CupertinoIcons.checkmark_circle_fill;
        break;
      case 'haram':
        verdictColor = const Color(0xFFFF3B30);
        verdictLabel = 'Community flagged issues';
        verdictIcon = CupertinoIcons.xmark_circle_fill;
        break;
      case 'unverified':
        verdictColor = const Color(0xFF8E8E93);
        verdictLabel = 'Not yet verified';
        verdictIcon = CupertinoIcons.question_circle_fill;
        break;
      default:
        verdictColor = const Color(0xFFFF9500);
        verdictLabel = 'Community: Mixed opinions';
        verdictIcon = CupertinoIcons.exclamationmark_circle_fill;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.person_2_fill, color: const Color(0xFF8E8E93), size: 18),
              const SizedBox(width: 6),
              const Text('Community', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF8E8E93), letterSpacing: 0.3)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(verdictIcon, color: verdictColor, size: 22),
              const SizedBox(width: 8),
              Text(verdictLabel, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: verdictColor)),
            ],
          ),
          if (score.totalVotes > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _votePill('✅ ${score.confirmedHalalCount}', const Color(0xFFE8F8ED), const Color(0xFF34C759)),
                const SizedBox(width: 8),
                _votePill('❌ ${score.foundIssueCount}', const Color(0xFFFFEBEA), const Color(0xFFFF3B30)),
                const SizedBox(width: 8),
                _votePill('⚠️ ${score.notSureCount}', const Color(0xFFFFF3E0), const Color(0xFFFF9500)),
              ],
            ),
            const SizedBox(height: 8),
            Text('${score.totalVotes} ${score.totalVotes == 1 ? 'person' : 'people'} verified this product',
                style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
          ] else
            const Text('Be the first to verify this product',
                style: TextStyle(fontSize: 13, color: Color(0xFF8E8E93))),
        ],
      ),
    );
  }

  Widget _votePill(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: fg)),
    );
  }

  Widget _buildVotingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Did you buy this?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Help other Muslims make the right choice.', style: TextStyle(fontSize: 13, color: Color(0xFF8E8E93))),
          const SizedBox(height: 16),
          if (_submittingVote)
            const Center(child: CupertinoActivityIndicator())
          else
            Row(
              children: [
                Expanded(child: _voteButton('✅', 'Halal', 'confirmed_halal', const Color(0xFF34C759))),
                const SizedBox(width: 8),
                Expanded(child: _voteButton('❌', 'Issue', 'found_issue', const Color(0xFFFF3B30))),
                const SizedBox(width: 8),
                Expanded(child: _voteButton('⚠️', 'Unsure', 'not_sure', const Color(0xFFFF9500))),
              ],
            ),
          if (_myVote != null) ...[
            const SizedBox(height: 10),
            Text('Your vote: ${_myVote!.replaceAll('_', ' ')}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
          ],
        ],
      ),
    );
  }

  Widget _voteButton(String emoji, String label, String value, Color color) {
    final selected = _myVote == value;
    return GestureDetector(
      onTap: () => _submitVote(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? color : Colors.transparent, width: 2),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? color : const Color(0xFF8E8E93))),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              const Text('INGREDIENTS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF8E8E93), letterSpacing: 0.5)),
              const Spacer(),
              Text('${widget.result.ingredients.length} items',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: widget.result.ingredients.asMap().entries.map((entry) {
              final i = entry.key;
              final ing = entry.value;
              final isLast = i == widget.result.ingredients.length - 1;
              return Column(
                children: [
                  _ingredientRow(ing),
                  if (!isLast) const Divider(height: 1, indent: 52),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _ingredientRow(IngredientResult ing) {
    Color statusColor;
    IconData statusIcon;

    switch (ing.status) {
      case 'halal':
        statusColor = const Color(0xFF34C759);
        statusIcon = CupertinoIcons.checkmark_circle_fill;
        break;
      case 'haram':
      case 'hanafi_haram':
      case 'shafii_haram':
      case 'maliki_haram':
      case 'hanbali_haram':
        statusColor = const Color(0xFFFF3B30);
        statusIcon = CupertinoIcons.xmark_circle_fill;
        break;
      default:
        statusColor = const Color(0xFFFF9500);
        statusIcon = CupertinoIcons.exclamationmark_circle_fill;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(statusIcon, color: statusColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(ing.original,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black)),
                    ),
                    if (ing.aiClassified)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE9FE),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('AI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF7C3AED))),
                      ),
                  ],
                ),
                if (ing.source.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(ing.source, style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93), height: 1.3)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnknownsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text('UNRECOGNIZED', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF8E8E93), letterSpacing: 0.5)),
        ),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('These ingredients were not found in our database.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF8E8E93))),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.result.unknownIngredients.map((u) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(u, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                )).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}