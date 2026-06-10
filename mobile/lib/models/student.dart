class Student {
  const Student({
    required this.id,
    required this.name,
    required this.course,
    required this.academicYear,
    required this.bio,
    required this.sharedInterests,
    required this.interests,
    required this.commonInterestCount,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String course;
  final String academicYear;
  final String bio;
  final String? avatarUrl;
  final List<String> sharedInterests;
  final List<String> interests;
  final int commonInterestCount;

  factory Student.fromJson(Map<String, dynamic> json) {
    final shared = json['shared_interests'] as List<dynamic>? ?? <dynamic>[];
    final allInterests = json['interests'] as List<dynamic>? ?? shared;

    return Student(
      id: json['id'] as String,
      name: json['name'] as String,
      course: json['course'] as String,
      academicYear: json['academic_year'] as String,
      bio: json['bio'] as String,
      avatarUrl: json['avatar_url'] as String?,
      sharedInterests: shared.map((item) => item.toString()).toList(),
      interests: allInterests.map((item) => item.toString()).toList(),
      commonInterestCount:
          json['common_interest_count'] as int? ?? shared.length,
    );
  }
}
