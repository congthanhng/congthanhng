class Player {
  final String name;
  int hp;
  int mana;

  Player({required this.name, required this.hp, required this.mana});

  factory Player.fromJson(Map<String, dynamic> json) => Player(
      name: json["name"] as String,
      hp: json["HP"] as int,
      mana: json["Mana"] as int);

  Map<String, dynamic> toJson() => <String, dynamic>{"name": name, "HP": hp, "Mana": mana};
}
