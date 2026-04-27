class IngredientResult {
  final String original;
  final String matchedName;
  final String status;
  final String source;
  final String sourceUrl;
  final String notes;
  final bool aiClassified;

  IngredientResult({
    required this.original,
    required this.matchedName,
    required this.status,
    required this.source,
    required this.sourceUrl,
    required this.notes,
    required this.aiClassified,
  });

  factory IngredientResult.fromJson(Map<String, dynamic> json) {
    return IngredientResult(
      original: json['original'] ?? '',
      matchedName: json['matched_name'] ?? '',
      status: json['status'] ?? '',
      source: json['source'] ?? '',
      sourceUrl: json['source_url'] ?? '',
      notes: json['notes'] ?? '',
      aiClassified: json['ai_classified'] ?? false,
    );
  }
}

class AnalysisResult {
  final int id;
  final String overallStatus;
  final String madhab;
  final String productName;
  final bool aiUsed;
  final List<IngredientResult> ingredients;
  final List<String> unknownIngredients;
  final bool hasHalalLogo;
  final String? halalLogoName;
  final Map<String, dynamic>? product;

  AnalysisResult({
    required this.id,
    required this.overallStatus,
    required this.madhab,
    required this.productName,
    required this.aiUsed,
    required this.ingredients,
    required this.unknownIngredients,
    this.hasHalalLogo = false,
    this.halalLogoName,
    this.product,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      id: json['id'] ?? 0,
      overallStatus: json['overall_status'] ?? '',
      madhab: json['madhab'] ?? '',
      productName: json['product_name'] ?? '',
      aiUsed: json['ai_used'] ?? false,
      ingredients: (json['ingredients'] as List<dynamic>? ?? [])
          .map((e) => IngredientResult.fromJson(e))
          .toList(),
      unknownIngredients: List<String>.from(json['unknown_ingredients'] ?? []),
      hasHalalLogo: json['has_halal_logo'] ?? false,
      halalLogoName: json['halal_logo_name'],
      product: json['product'],
    );
  }
}