class PokemonEntity {
  final int id;
  final String name;
  final String imagePath;
  final String? description;

  const PokemonEntity({
    required this.id,
    required this.name,
    required this.imagePath,
    this.description,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PokemonEntity &&
        other.id == id &&
        other.name == name &&
        other.imagePath == imagePath &&
        other.description == description;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        imagePath.hashCode ^
        description.hashCode;
  }

  @override
  String toString() {
    return 'PokemonEntity(id: $id, name: $name, imagePath: $imagePath, description: $description)';
  }
}
