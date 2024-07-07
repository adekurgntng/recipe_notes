class Recipe {
  final String id;
  final String title;
  final String ingredients;
  final String instructions;
  final String? image;
  bool isFavorite; // Add isFavorite field

  Recipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.instructions,
    this.image,
    this.isFavorite = false, // Initialize isFavorite with false by default
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      ingredients: json['ingredients'] ?? '',
      instructions: json['instructions'] ?? '',
      image: json['image'],
      isFavorite: json['isFavorite'] ?? false, // Initialize isFavorite from JSON if available
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'ingredients': ingredients,
      'instructions': instructions,
      'image': image,
      'isFavorite': isFavorite, // Include isFavorite in JSON serialization
    };
  }
}
