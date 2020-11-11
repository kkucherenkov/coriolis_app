class BiographyVariant {
  final String title;
  final String description;
  final int attributePoints;
  final int skillPoints;
  final int reputation;

  BiographyVariant(
      {this.title,
      this.description,
      this.attributePoints,
      this.skillPoints,
      this.reputation});

  BiographyVariant.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        description = json['description'],
        attributePoints = json['attributes'],
        skillPoints = json['skills'],
        reputation = json['reputation'];

  static List<BiographyVariant> parseList(Map<String, dynamic> data) {
    return (data['data'] as List)
        .map((biography) => BiographyVariant.fromJson(biography))
        .toList();
  }
}
