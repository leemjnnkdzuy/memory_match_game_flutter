class PokemonNameUtils {
  static String pokemonNameToImagePath(String pokemonName) {
    final lowerName = pokemonName.toLowerCase();

    if (lowerName.contains('nidoran')) {
      if (lowerName.contains('female')) {
        return 'assets/images/Nidoran_female.png';
      } else if (lowerName.contains('male')) {
        return 'assets/images/Nidoran_male.png';
      }
    }

    if (pokemonName == 'Mr. Mime') {
      return 'assets/images/Mr.Mime.png';
    }

    return 'assets/images/$pokemonName.png';
  }
}
