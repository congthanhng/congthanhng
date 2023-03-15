import 'player.dart';

class StatusData {
  final Player dio;
  final Player joJo;
  bool isDioTurn;
  int dice1;
  int dice2;

  StatusData(
      {required this.dio,
      required this.joJo,
      required this.isDioTurn,
      required this.dice1,
      required this.dice2});

  factory StatusData.fromJson(Map<String, dynamic> json) => StatusData(
      dio: Player.fromJson(json["Dio"]),
      joJo: Player.fromJson(json["JoJo"]),
      isDioTurn: json["isDioTurn"] as bool,
      dice1: json["Dice1"] as int,
      dice2: json["Dice2"] as int);

  Map<String, dynamic> toJson() => <String, dynamic>{
        "Dio": dio.toJson(),
        "JoJo": joJo.toJson(),
        "isDioTurn": isDioTurn,
        "Dice1": dice1,
        "Dice2": dice2
      };

  int get totalDice => dice1 + dice2;

  String toJsonString() => '${this.toJson()}';

  StatusData resetGame(bool isNextGameDioTurn) {
    return StatusData(
        dio: Player(hp: 50, mana: 0, name: 'Dio Brando'),
        joJo: Player(name: 'Jotaro Kujo', mana: 0, hp: 50),
        dice1: 1,
        dice2: 1,
        isDioTurn: isNextGameDioTurn);
  }
}
