class SupportResource {
  const SupportResource({
    required this.id,
    required this.category,
    required this.description,
    required this.tips,
  });

  final String id;
  final String category;
  final String description;
  final List<String> tips;

  factory SupportResource.fromJson(Map<String, dynamic> json) {
    final rawTips = json['tips'] as List<dynamic>? ?? <dynamic>[];

    return SupportResource(
      id: json['id'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      tips: rawTips.map((tip) => tip.toString()).toList(),
    );
  }
}
