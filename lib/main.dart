import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:math';

import 'core/state_data.dart';

String example = "battle|play|healx2|10";

enum ActionState { attack, attackx2, heal, healx2 }

extension ActionStateExtension on String {
  ActionState actionStateFromString() {
    switch (this) {
      case "attack":
        return ActionState.attack;
      case "attackx2":
        return ActionState.attackx2;
      case "heal":
        return ActionState.heal;
      case "healx2":
        return ActionState.healx2;
      default:
        return ActionState.attack;
    }
  }
}

void main(List<String> arguments) async {
  String data = arguments[0];
  List<String> args = data.split('|');
  ActionState actionState = args[2].actionStateFromString();
  int point = int.parse(args[3]);

  Map<String, dynamic> stateData = await readJsonFile('lib/core/state.json');
  StateData resource = StateData.fromJson(stateData);

  if (ActionState.values.toString().contains(args[2]) &&
      point == resource.totalDice) {
    int attackValue = 0;
    int healValue = 0;
    bool canPowerful = false;
    switch (actionState) {
      case ActionState.attack:
        attackValue = point;
        break;
      case ActionState.attackx2:
        if (resource.isDioTurn) {
          if (resource.dio.mana >= 25) {
            attackValue = point * 2;
            resource.dio.mana = 0;
          } else {
            attackValue = point;
          }
        } else {
          if (resource.joJo.mana >= 25) {
            attackValue = point * 2;
            resource.joJo.mana = 0;
          } else {
            attackValue = point;
          }
        }
        break;
      case ActionState.heal:
        healValue = point;
        break;
      case ActionState.healx2:
        healValue = point * 2;
        if (resource.isDioTurn) {
          resource.dio.mana = 0;
        } else {
          resource.joJo.mana = 0;
        }
        break;
    }

    if (resource.isDioTurn) {
      if (resource.joJo.hp <= 0 || resource.joJo.hp <= attackValue) {
        //Dio WIN
        //reset game
        var reset = resource.resetGame(false);
        var dice1 = Random().nextInt(6) + 1;
        var dice2 = Random().nextInt(6) + 1;
        reset.dice1 = dice1;
        reset.dice2 = dice2;
        await File('lib/core/state.json')
            .writeAsString(jsonEncode(reset.toJson()));
        return;
      } else {
        //decrease jojo HP
        resource.joJo.hp -= attackValue;
        //increase JoJO MP
        resource.joJo.mana += attackValue;
        if (resource.joJo.mana >= 25) {
          resource.joJo.mana = 25;
          canPowerful = true;
        }
      }

      if (resource.dio.hp + healValue > 100) {
        resource.dio.hp = 100;
        int remainHealValue = healValue - (100 - resource.dio.hp);
        resource.dio.mana += remainHealValue;
      } else {
        resource.dio.hp += healValue;
      }
    } else {
      if (resource.dio.hp <= 0 || resource.dio.hp <= attackValue) {
        //JoJo WIN
        //reset game
        var reset = resource.resetGame(true);
        var dice1 = Random().nextInt(6) + 1;
        var dice2 = Random().nextInt(6) + 1;
        reset.dice1 = dice1;
        reset.dice2 = dice2;
        await File('lib/core/state.json')
            .writeAsString(jsonEncode(reset.toJson()));
        return;
      } else {
        //decrease dio HP
        resource.dio.hp -= attackValue;
        //increase dio MP
        resource.dio.mana += attackValue;
        if (resource.dio.mana >= 25) {
          resource.dio.mana = 25;
          canPowerful = true;
        }
      }
      if (resource.joJo.hp + healValue > 100) {
        resource.joJo.hp = 100;
        int remainHealValue = healValue - (100 - resource.dio.hp);
        resource.joJo.mana += remainHealValue;
      } else {
        resource.joJo.hp += healValue;
      }
    }

    resource.isDioTurn = !resource.isDioTurn;

    var dice1 = Random().nextInt(6) + 1;
    var dice2 = Random().nextInt(6) + 1;
    resource.dice1 = dice1;
    resource.dice2 = dice2;

    print('toJsonString: ${resource.toJsonString()}');
    await File('lib/core/state.json')
        .writeAsString(jsonEncode(resource.toJson()));
  } else
    throw Exception('The Issue is not correct with title format');
}

Future<Map<String, dynamic>> readJsonFile(String filePath) async {
  var input = await File(filePath).readAsString();
  var map = jsonDecode(input);
  return map;
}
