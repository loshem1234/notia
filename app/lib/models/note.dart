class Note {
  final int? id;
  final String text;
  final DateTime createdAt;
  final bool isDeveloped;
  final String? category;
  final double? categoryConfidence;
  
  Note({
    this.id,
    required this.text,
    required this.createdAt,
    this.isDeveloped = false,
    this.category,
    this.categoryConfidence,
  });
  
  // Convert Note to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'isDeveloped': isDeveloped ? 1 : 0,
      'category': category,
      'categoryConfidence': categoryConfidence,
    };
  }
  
  // Create Note from SQLite Map
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      text: map['text'],
      createdAt: DateTime.parse(map['createdAt']),
      isDeveloped: map['isDeveloped'] == 1,
      category: map['category'],
      categoryConfidence: map['categoryConfidence'],
    );
  }
  
  // Create copy with updated fields
  Note copyWith({
    int? id,
    String? text,
    DateTime? createdAt,
    bool? isDeveloped,
    String? category,
    double? categoryConfidence,
  }) {
    return Note(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      isDeveloped: isDeveloped ?? this.isDeveloped,
      category: category ?? this.category,
      categoryConfidence: categoryConfidence ?? this.categoryConfidence,
    );
  }
}
