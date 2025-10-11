class PokemonNameUtils {
  static String pokemonNameToImagePath(String pokemonName) {
    final lowerName = pokemonName.toLowerCase();

    if (lowerName.contains('nidoran')) {
      if (lowerName.contains('female')) {
        return 'images/Nidoran_female.png';
      } else if (lowerName.contains('male')) {
        return 'images/Nidoran_male.png';
      }
    }

    if (pokemonName == 'Mr. Mime') {
      return 'images/Mr.Mime.png';
    }

    return 'images/$pokemonName.png';
  }
}
