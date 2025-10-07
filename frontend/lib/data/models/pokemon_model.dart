import '../../domain/entities/pokemon_entity.dart';

class PokemonModel {
  final int id;
  final String name;
  final String imagePath;
  final String? description;

  const PokemonModel({
    required this.id,
    required this.name,
    required this.imagePath,
    this.description,
  });

  factory PokemonModel.fromEntity(PokemonEntity entity) {
    return PokemonModel(
      id: entity.id,
      name: entity.name,
      imagePath: entity.imagePath,
      description: entity.description,
    );
  }

  PokemonEntity toEntity() {
    return PokemonEntity(
      id: id,
      name: name,
      imagePath: imagePath,
      description: description,
    );
  }

  factory PokemonModel.fromJson(Map<String, dynamic> json) {
    return PokemonModel(
      id: json['id'] as int,
      name: json['name'] as String,
      imagePath: json['imagePath'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'description': description,
    };
  }
}
