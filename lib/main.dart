import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:math';

import 'core/action_state.dart';
import 'core/actions.dart';
import 'core/state_data.dart';
import 'data/data_path.dart';

void main(List<String> arguments) async {
  String data = arguments[0];
  String userName = arguments[1];
  List<String> args = data.split('|');
  ActionState actionState = args[2].actionStateFromString();
  int point = int.parse(args[3]);

  Map<String, dynamic> stateData = await readJsonFile(statePath);
  Map<String, dynamic> activityData =
      await readJsonFile(activityPath);
  Map<String, dynamic> userData = await readJsonFile(userRecordPath);
  Map<String, dynamic> battleLog =
      await readJsonFile(battleLogPath);
  StateData resource = StateData.fromJson(stateData);

  //init battleLog
  var keyLog = DateTime.now().toString();
  battleLog[keyLog] = {};
  battleLog[keyLog]["player_name"] = userName;
  battleLog[keyLog]["point"] = resource.totalDice;

  if (ActionState.values.toString().contains(args[2]) &&
      point == resource.totalDice) {
    userData[userName] = (userData[userName] ?? 0) + 1;
    await File(userRecordPath).writeAsString(jsonEncode(userData));

    int attackValue = 0;
    int healValue = 0;
    bool canPowerful = false;
    switch (actionState) {
      case ActionState.attack:
        attackValue = point;

        //set State of battle log
        battleLog[keyLog]["state"] = "attack";
        break;
      case ActionState.attackx2:
        //set State of battle log
        battleLog[keyLog]["state"] = "attackx2";
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
        //set State of battle log

        battleLog[keyLog]["state"] = "heal";
        healValue = point;
        break;
      case ActionState.healx2:
        //set State of battle log

        battleLog[keyLog]["state"] = "healx2";
        healValue = point * 2;
        if (resource.isDioTurn) {
          resource.dio.mana = 0;
        } else {
          resource.joJo.mana = 0;
        }
        break;
    }

    if (resource.isDioTurn) {
      battleLog[keyLog]["character"] = "Dio";
      if (resource.joJo.hp <= 0 || resource.joJo.hp <= attackValue) {
        //Dio WIN
        //reset game
        var reset = resource.resetGame(false);
        var dice1 = Random().nextInt(6) + 1;
        var dice2 = Random().nextInt(6) + 1;
        reset.dice1 = dice1;
        reset.dice2 = dice2;
        await File(statePath)
            .writeAsString(jsonEncode(reset.toJson()));
        activityData['dio']['win']++;
        activityData['completeGame']++;
        await File(activityPath)
            .writeAsString(jsonEncode(activityData));

        await File('README.md').writeAsString(generateREADME(
            reset, canPowerful, activityData, userData, battleLog));
        return;
      } else {
        //decrease jojo HP
        resource.joJo.hp -= attackValue;
        activityData['dio']['attackDmg'] += attackValue;
        //increase JoJO MP
        resource.joJo.mana += attackValue;
        if (resource.joJo.mana >= 25) {
          resource.joJo.mana = 25;
          canPowerful = true;
        }
      }

      if (resource.dio.hp + healValue > 100) {
        int remainHealValue = healValue - (100 - resource.dio.hp);
        activityData['dio']['healRecover'] += 100 - resource.dio.hp;

        resource.dio.mana += remainHealValue;
        resource.dio.hp = 100;
      } else {
        resource.dio.hp += healValue;
        activityData['dio']['healRecover'] += healValue;
      }
    } else {
      battleLog[keyLog]["character"] = "JoJo";
      if (resource.dio.hp <= 0 || resource.dio.hp <= attackValue) {
        //JoJo WIN
        //reset game
        var reset = resource.resetGame(true);
        var dice1 = Random().nextInt(6) + 1;
        var dice2 = Random().nextInt(6) + 1;
        reset.dice1 = dice1;
        reset.dice2 = dice2;
        await File(statePath)
            .writeAsString(jsonEncode(reset.toJson()));
        activityData['joJo']['win']++;
        activityData['completeGame']++;
        await File(activityPath)
            .writeAsString(jsonEncode(activityData));
        await File('README.md').writeAsString(generateREADME(
            reset, canPowerful, activityData, userData, battleLog));
        return;
      } else {
        //decrease dio HP
        resource.dio.hp -= attackValue;
        activityData['joJo']['attackDmg'] += attackValue;
        //increase dio MP
        resource.dio.mana += attackValue;
        if (resource.dio.mana >= 25) {
          resource.dio.mana = 25;
          canPowerful = true;
        }
      }
      if (resource.joJo.hp + healValue > 100) {
        int remainHealValue = healValue - (100 - resource.joJo.hp);
        activityData['joJo']['healRecover'] += healValue;
        resource.joJo.mana += remainHealValue;
        resource.joJo.hp = 100;
      } else {
        resource.joJo.hp += healValue;
        activityData['joJo']['healRecover'] += healValue;
      }
    }

    resource.isDioTurn = !resource.isDioTurn;

    var dice1 = Random().nextInt(6) + 1;
    var dice2 = Random().nextInt(6) + 1;
    resource.dice1 = dice1;
    resource.dice2 = dice2;

    // print('toJsonString: ${resource.toJsonString()}');
    await File(statePath)
        .writeAsString(jsonEncode(resource.toJson()));

    await File('README.md').writeAsString(generateREADME(
        resource, canPowerful, activityData, userData, battleLog));

    activityData['moves']++;
    await File(activityPath)
        .writeAsString(jsonEncode(activityData));

    await File(battleLogPath).writeAsString(jsonEncode(battleLog));
  } else
    throw Exception('The Issue is not correct with title format');
}

Future<Map<String, dynamic>> readJsonFile(String filePath) async {
  var input = await File(filePath).readAsString();
  var map = jsonDecode(input);
  return map;
}


