import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
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
    if (mounted) setState(() => _isLoggedIn = loggedIn);
  }

  Future<void> _loadCommunityData() async {
    setState(() => _loadingScore = true);
    try {
      final score = await CommunityService.getScore(widget.result.barcode);
      final myVote = await CommunityService.getMyVote(widget.result.barcode);
      if (mounted)
        setState(() {
          _communityScore = score;
          _myVote = myVote;
        });
    } catch (_) {}
    if (mounted) setState(() => _loadingScore = false);
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
      if (mounted) setState(() => _myVote = vote);
      await _loadCommunityData();
      if (mounted) {
        _showDialog(
          title: 'JazakAllahu Khayran',
          message: 'Your vote helps the community find halal food.',
        );
      }
    } catch (e) {
      if (mounted) {
        _showDialog(title: 'Error', message: e.toString());
      }
    }
    if (mounted) setState(() => _submittingVote = false);
  }

  void _showDialog({required String title, required String message}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: TayyibColors.cardBg(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title,
            style: TayyibText.headline(color: TayyibColors.lbl(context))),
        content: Text(message,
            style: TayyibText.callout(color: TayyibColors.secondLbl(context))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK',
                style: TayyibText.callout(
                    color: TayyibColors.lbl(context), weight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Color get _statusColor {
    switch (widget.result.overallStatus) {
      case 'halal':
        return TayyibColors.green;
      case 'haram':
        return TayyibColors.red;
      default:
        return TayyibColors.orange;
    }
  }

  Color get _statusTintColor {
    switch (widget.result.overallStatus) {
      case 'halal':
        return TayyibColors.greenTint;
      case 'haram':
        return TayyibColors.redTint;
      default:
        return TayyibColors.orangeTint;
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

  String get _statusLabel {
    switch (widget.result.overallStatus) {
      case 'halal':
        return 'Halal';
      case 'haram':
        return 'Haram';
      default:
        return 'Questionable';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: TayyibColors.bg(context),
      appBar: AppBar(
        backgroundColor: TayyibColors.bg(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TayyibColors.fillC(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: TayyibColors.lbl(context),
              size: 20,
            ),
          ),
        ),
        title: Text(
          'Result',
          style: TayyibText.headline(color: TayyibColors.lbl(context)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVerdictCard(isDark),
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
            _buildIngredientSection(),
            if (widget.result.unknownIngredients.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildUnknownsSection(),
            ],
            if (widget.result.barcode.isNotEmpty && _isLoggedIn) ...[
              const SizedBox(height: 16),
              _buildVotingSection(),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Verdict Card ───────────────────────────────────────────────────────────

  Widget _buildVerdictCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _statusColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _statusColor.withOpacity(isDark ? 0.2 : 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_statusEmoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 10),
          Text(
            _statusLabel,
            style: TayyibText.largeTitle(color: Colors.white),
          ),
          const SizedBox(height: 6),
          if (widget.result.productName.isNotEmpty)
            Text(
              widget.result.productName,
              style: TayyibText.callout(color: Colors.white70),
            ),
          const SizedBox(height: 4),
          Text(
            '${widget.result.madhab.toUpperCase()} MADHAB'
            '${widget.result.aiUsed ? '  ·  AI' : ''}',
            style: TayyibText.caption1(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  // ─── Halal Logo Banner ───────────────────────────────────────────────────────

  Widget _buildHalalLogoBanner() {
    return _card(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: TayyibColors.greenTint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.verified_rounded,
                color: TayyibColors.green, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halal Certified',
                  style: TayyibText.headline(color: TayyibColors.lbl(context)),
                ),
                if (widget.result.halalLogoName != null)
                  Text(
                    widget.result.halalLogoName!,
                    style: TayyibText.footnote(color: TayyibColors.green),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Product Card ────────────────────────────────────────────────────────────

  Widget _buildProductCard() {
    final p = widget.result.product!;
    return _card(
      child: Row(
        children: [
          if (p['image_url'] != null && p['image_url'].toString().isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                p['image_url'],
                width: 52,
                height: 52,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          if (p['image_url'] != null && p['image_url'].toString().isNotEmpty)
            const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p['name'] ?? '',
                  style: TayyibText.callout(
                    color: TayyibColors.lbl(context),
                    weight: FontWeight.w600,
                  ),
                ),
                if (p['brands'] != null)
                  Text(
                    p['brands'],
                    style: TayyibText.footnote(
                        color: TayyibColors.secondLbl(context)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Community Score ─────────────────────────────────────────────────────────

  Widget _buildCommunityScore() {
    if (_loadingScore) {
      return _card(
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: TayyibColors.secondLbl(context),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Loading community data...',
              style: TayyibText.callout(color: TayyibColors.secondLbl(context)),
            ),
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
        verdictColor = TayyibColors.green;
        verdictLabel = 'Community says: Halal';
        verdictIcon = Icons.check_circle_rounded;
        break;
      case 'haram':
        verdictColor = TayyibColors.red;
        verdictLabel = 'Community flagged issues';
        verdictIcon = Icons.cancel_rounded;
        break;
      case 'unverified':
        verdictColor = TayyibColors.secondLbl(context);
        verdictLabel = 'Not yet verified';
        verdictIcon = Icons.help_rounded;
        break;
      default:
        verdictColor = TayyibColors.orange;
        verdictLabel = 'Community: Mixed opinions';
        verdictIcon = Icons.warning_rounded;
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'COMMUNITY',
            style: TayyibText.sectionHeader(
                color: TayyibColors.secondLbl(context)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(verdictIcon, color: verdictColor, size: 22),
              const SizedBox(width: 8),
              Text(
                verdictLabel,
                style: TayyibText.callout(
                    color: verdictColor, weight: FontWeight.w700),
              ),
            ],
          ),
          if (score.totalVotes > 0) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                _votePill('✅ ${score.confirmedHalalCount}',
                    TayyibColors.greenTint, TayyibColors.green),
                const SizedBox(width: 8),
                _votePill('❌ ${score.foundIssueCount}', TayyibColors.redTint,
                    TayyibColors.red),
                const SizedBox(width: 8),
                _votePill('⚠️ ${score.notSureCount}', TayyibColors.orangeTint,
                    TayyibColors.orange),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${score.totalVotes} ${score.totalVotes == 1 ? 'person' : 'people'} verified this product',
              style:
                  TayyibText.footnote(color: TayyibColors.secondLbl(context)),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Be the first to verify this product',
                style:
                    TayyibText.callout(color: TayyibColors.secondLbl(context)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _votePill(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        text,
        style: TayyibText.footnote(color: fg, weight: FontWeight.w700),
      ),
    );
  }

  // ─── Voting Section ──────────────────────────────────────────────────────────

  Widget _buildVotingSection() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Did you buy this?',
            style: TayyibText.headline(color: TayyibColors.lbl(context)),
          ),
          const SizedBox(height: 4),
          Text(
            'Help other Muslims make the right choice.',
            style: TayyibText.footnote(color: TayyibColors.secondLbl(context)),
          ),
          const SizedBox(height: 18),
          if (_submittingVote)
            Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: TayyibColors.lbl(context),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                    child: _voteButton(
                        '✅', 'Halal', 'confirmed_halal', TayyibColors.green)),
                const SizedBox(width: 8),
                Expanded(
                    child: _voteButton(
                        '❌', 'Issue', 'found_issue', TayyibColors.red)),
                const SizedBox(width: 8),
                Expanded(
                    child: _voteButton(
                        '⚠️', 'Unsure', 'not_sure', TayyibColors.orange)),
              ],
            ),
          if (_myVote != null) ...[
            const SizedBox(height: 12),
            Text(
              'Your vote: ${_myVote!.replaceAll('_', ' ')}',
              style:
                  TayyibText.footnote(color: TayyibColors.secondLbl(context)),
            ),
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
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color:
              selected ? color.withOpacity(0.12) : TayyibColors.fillC(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TayyibText.footnote(
                color: selected ? color : TayyibColors.secondLbl(context),
                weight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Ingredients ─────────────────────────────────────────────────────────────

  Widget _buildIngredientSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Text(
                'INGREDIENTS',
                style: TayyibText.sectionHeader(
                    color: TayyibColors.secondLbl(context)),
              ),
              const Spacer(),
              Text(
                '${widget.result.ingredients.length} items',
                style:
                    TayyibText.caption1(color: TayyibColors.secondLbl(context)),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: TayyibColors.cardBg(context),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: widget.result.ingredients.asMap().entries.map((entry) {
              final i = entry.key;
              final ing = entry.value;
              final isLast = i == widget.result.ingredients.length - 1;
              return Column(
                children: [
                  _ingredientRow(ing),
                  if (!isLast)
                    Divider(
                      height: 1,
                      color: TayyibColors.sep(context),
                      indent: 54,
                    ),
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
        statusColor = TayyibColors.green;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'haram':
      case 'hanafi_haram':
      case 'shafii_haram':
      case 'maliki_haram':
      case 'hanbali_haram':
        statusColor = TayyibColors.red;
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = TayyibColors.orange;
        statusIcon = Icons.warning_rounded;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                      child: Text(
                        ing.original,
                        style: TayyibText.callout(
                          color: TayyibColors.lbl(context),
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (ing.aiClassified) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE9FE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'AI',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF7C3AED),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (ing.source.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    ing.source,
                    style: TayyibText.footnote(
                      color: TayyibColors.secondLbl(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Unknowns ─────────────────────────────────────────────────────────────────

  Widget _buildUnknownsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            'UNRECOGNIZED',
            style: TayyibText.sectionHeader(
                color: TayyibColors.secondLbl(context)),
          ),
        ),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'These ingredients were not found in our database.',
                style:
                    TayyibText.footnote(color: TayyibColors.secondLbl(context)),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.result.unknownIngredients
                    .map((u) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: TayyibColors.fillC(context),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            u,
                            style: TayyibText.footnote(
                              color: TayyibColors.lbl(context),
                              weight: FontWeight.w600,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TayyibColors.cardBg(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
