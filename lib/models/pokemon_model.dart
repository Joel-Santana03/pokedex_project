class Pokemon {
  final int id;
  final String name;
  final List<String> type;
  final Map<String, int> base;

  Pokemon({
    required this.id,
    required this.name,
    required this.type,
    required this.base,
  });

    // Adicione este getter
  String get imageUrl {
    // Formata o ID com zeros à esquerda (001, 002, etc)
    String formattedId = id.toString().padLeft(3, '0');
    return 'https://raw.githubusercontent.com/fanzeyi/pokemon.json/master/images/$formattedId.png';
  }

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'],
      name: json['name']['english'],
      type: List<String>.from(json['type']),
      base: Map<String, int>.from(json['base']),
    );
  }
}