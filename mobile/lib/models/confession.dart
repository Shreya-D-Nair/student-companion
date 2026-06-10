class Confession {
  const Confession({
    required this.id,
    required this.anonymousDeviceId,
    required this.content,
    required this.reactionCount,
    required this.createdAt,
    required this.hasReacted,
  });

  final String id;
  final String anonymousDeviceId;
  final String content;
  final int reactionCount;
  final DateTime createdAt;
  final bool hasReacted;

  factory Confession.fromJson(Map<String, dynamic> json) {
    return Confession(
      id: json['id'] as String,
      anonymousDeviceId: json['anonymous_device_id'] as String? ?? '',
      content: json['content'] as String,
      reactionCount: json['reaction_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      hasReacted: json['has_reacted'] as bool? ?? false,
    );
  }
}
