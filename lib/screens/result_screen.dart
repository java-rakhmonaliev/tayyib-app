import 'package:flutter/material.dart';
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
    if (widget.result.barcode.isNotEmpty) {
      _loadCommunityData();
    }
    _checkLogin();
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
      setState(() {
        _communityScore = score;
        _myVote = myVote;
      });
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vote submitted. JazakAllahu Khayran! 🙏',
                style: TextStyle(fontWeight: FontWeight.w700)),
            backgroundColor: Colors.black,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: const Color(0xFFFF6B6B),
          ),
        );
      }
    }
    setState(() => _submittingVote = false);
  }

  Color get _statusColor {
    switch (widget.result.overallStatus) {
      case 'halal':
        return const Color(0xFF6EE7B7);
      case 'haram':
        return const Color(0xFFFF6B6B);
      default:
        return const Color(0xFFFFD93D);
    }
  }

  String get _statusEmoji {
    switch (widget.result.overallStatus) {
      case 'halal':
        return '✅';
      case 'haram':
        return '❌';
      default:
        return '⚠️';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.result.overallStatus == 'haram') {
      HapticFeedback.heavyImpact();
    } else if (widget.result.overallStatus == 'halal') {
      HapticFeedback.lightImpact();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('RESULT',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 3)),
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
            if (widget.result.hasHalalLogo) ...[
              _buildHalalLogoBanner(),
              const SizedBox(height: 16),
            ],
            if (widget.result.product != null) ...[
              _buildProductCard(),
              const SizedBox(height: 16),
            ],
            if (widget.result.barcode.isNotEmpty) ...[
              _buildCommunityScore(),
              const SizedBox(height: 16),
            ],
            _buildSectionHeader(
                '🔬 INGREDIENT BREAKDOWN',
                '${widget.result.ingredients.length}'),
            const SizedBox(height: 8),
            ...widget.result.ingredients.map((ing) => _ingredientRow(ing)),
            if (widget.result.unknownIngredients.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSectionHeader(
                  '❓ UNRECOGNIZED',
                  '${widget.result.unknownIngredients.length}'),
              const SizedBox(height: 8),
              _buildUnknowns(),
            ],
            if (widget.result.barcode.isNotEmpty && _isLoggedIn) ...[
              const SizedBox(height: 24),
              _buildVotingSection(),
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
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(8, 8), blurRadius: 0)
        ],
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
              widget.result.overallStatus.toUpperCase(),
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
          if (widget.result.productName.isNotEmpty) ...[
            Text(widget.result.productName,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.black87)),
            const SizedBox(height: 2),
          ],
          Text(
            '${widget.result.madhab.toUpperCase()} MADHAB${widget.result.aiUsed ? ' · AI-ASSISTED' : ''}',
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 1.5,
                color: Colors.black54),
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
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)
        ],
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
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 1.5)),
                if (widget.result.halalLogoName != null)
                  Text(widget.result.halalLogoName!,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13)),
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
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(5, 5), blurRadius: 0)
        ],
      ),
      child: Row(
        children: [
          if (widget.result.product!['image_url'] != null &&
              widget.result.product!['image_url'].toString().isNotEmpty)
            Container(
              width: 64,
              height: 64,
              margin: const EdgeInsets.only(right: 12),
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
              child: Image.network(widget.result.product!['image_url'],
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox()),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.result.product!['name'] ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 15)),
                if (widget.result.product!['brands'] != null)
                  Text(widget.result.product!['brands'],
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Colors.grey)),
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
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)
          ],
        ),
        child: const Row(
          children: [
            SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.black)),
            SizedBox(width: 12),
            Text('Loading community data...',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          ],
        ),
      );
    }

    final score = _communityScore;
    if (score == null) return const SizedBox();

    Color verdictColor;
    String verdictLabel;
    switch (score.communityVerdict) {
      case 'halal':
        verdictColor = const Color(0xFF6EE7B7);
        verdictLabel = '✅ COMMUNITY: HALAL';
        break;
      case 'haram':
        verdictColor = const Color(0xFFFF6B6B);
        verdictLabel = '❌ COMMUNITY: FLAGGED';
        break;
      case 'unverified':
        verdictColor = const Color(0xFFE2E8F0);
        verdictLabel = '👥 NOT YET VERIFIED';
        break;
      default:
        verdictColor = const Color(0xFFFFD93D);
        verdictLabel = '⚠️ COMMUNITY: MIXED';
    }

    return Container(
      decoration: BoxDecoration(
        color: verdictColor,
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(verdictLabel,
              style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 1)),
          const SizedBox(height: 8),
          if (score.totalVotes > 0) ...[
            Row(
              children: [
                _voteBar('✅', score.confirmedHalalCount, score.totalVotes,
                    const Color(0xFF10b981)),
                const SizedBox(width: 8),
                _voteBar('❌', score.foundIssueCount, score.totalVotes,
                    const Color(0xFFFF6B6B)),
                const SizedBox(width: 8),
                _voteBar('⚠️', score.notSureCount, score.totalVotes,
                    const Color(0xFFf59e0b)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${score.totalVotes} ${score.totalVotes == 1 ? 'person' : 'people'} from the community verified this product',
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54),
            ),
          ] else
            const Text('Be the first to verify this product',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _voteBar(String emoji, int count, int total, Color color) {
    final pct = total > 0 ? count / total : 0.0;
    return Expanded(
      child: Column(
        children: [
          Text('$emoji $count',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Container(
            height: 6,
            decoration: BoxDecoration(
                color: Colors.black12,
                border: Border.all(color: Colors.black, width: 1)),
            child: FractionallySizedBox(
              widthFactor: pct,
              alignment: Alignment.centerLeft,
              child: Container(color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVotingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(5, 5), blurRadius: 0)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('👥 COMMUNITY VERIFICATION',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1)),
          const SizedBox(height: 4),
          const Text('Did you buy this product? Help the community.',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          if (_submittingVote)
            const Center(
                child: CircularProgressIndicator(
                    color: Colors.black, strokeWidth: 2))
          else
            Row(
              children: [
                Expanded(
                    child: _voteButton(
                        '✅', 'HALAL', 'confirmed_halal',
                        const Color(0xFF6EE7B7))),
                const SizedBox(width: 8),
                Expanded(
                    child: _voteButton(
                        '❌', 'ISSUE', 'found_issue',
                        const Color(0xFFFF6B6B))),
                const SizedBox(width: 8),
                Expanded(
                    child: _voteButton(
                        '⚠️', 'UNSURE', 'not_sure',
                        const Color(0xFFFFD93D))),
              ],
            ),
          if (_myVote != null) ...[
            const SizedBox(height: 10),
            Text(
              'Your vote: ${_myVote!.replaceAll('_', ' ').toUpperCase()}',
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _voteButton(
      String emoji, String label, String value, Color color) {
    final selected = _myVote == value;
    return GestureDetector(
      onTap: () => _submitVote(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          border: Border.all(
              color: selected ? Colors.black : Colors.black38,
              width: selected ? 3 : 2),
          boxShadow: selected
              ? const [
                  BoxShadow(
                      color: Colors.black,
                      offset: Offset(3, 3),
                      blurRadius: 0)
                ]
              : [],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String count) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1)),
        const Spacer(),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          color: Colors.black,
          child: Text(count,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 11)),
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
      case 'maliki_haram':
      case 'hanbali_haram':
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
          top: const BorderSide(color: Colors.black12, width: 1),
          right: const BorderSide(color: Colors.black12, width: 1),
          bottom: const BorderSide(color: Colors.black12, width: 1),
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                ing.status == 'halal'
                    ? '✅'
                    : ing.status.contains('haram')
                        ? '❌'
                        : '⚠️',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(ing.original,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.black)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor,
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Text(
                  ing.status.toUpperCase().replaceAll('_', ' '),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 8,
                      letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          if (ing.source.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(ing.source,
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                    height: 1.4)),
          ],
          if (ing.aiClassified) ...[
            const SizedBox(height: 5),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFede9fe),
                border:
                    Border.all(color: const Color(0xFF7c3aed), width: 1),
              ),
              child: const Text('AI',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF7c3aed),
                      letterSpacing: 1)),
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
      children: widget.result.unknownIngredients
          .map((u) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD93D),
                  border: Border.all(color: Colors.black, width: 2),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black,
                        offset: Offset(2, 2),
                        blurRadius: 0)
                  ],
                ),
                child: Text(u,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 12)),
              ))
          .toList(),
    );
  }
}