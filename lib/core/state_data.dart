import 'player.dart';

class StateData {
  final Player dio;
  final Player joJo;
  bool isDioTurn;
  int dice1;
  int dice2;

  StateData(
      {required this.dio,
      required this.joJo,
      required this.isDioTurn,
      required this.dice1,
      required this.dice2});

  factory StateData.fromJson(Map<String, dynamic> json) => StateData(
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
}
