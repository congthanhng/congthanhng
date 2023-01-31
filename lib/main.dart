import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:math';

import 'core/state_data.dart';
import 'how_to_play.dart';
import 'introduce.dart';

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
        await File('README.md')
            .writeAsString(generateREADME(reset, canPowerful));
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

        await File('README.md')
            .writeAsString(generateREADME(reset, canPowerful));
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

    // print('toJsonString: ${resource.toJsonString()}');
    await File('lib/core/state.json')
        .writeAsString(jsonEncode(resource.toJson()));

    await File('README.md')
        .writeAsString(generateREADME(resource, canPowerful));
  } else
    throw Exception('The Issue is not correct with title format');
}

Future<Map<String, dynamic>> readJsonFile(String filePath) async {
  var input = await File(filePath).readAsString();
  var map = jsonDecode(input);
  return map;
}

String generateREADME(StateData data, bool canPowerful) {
  var isDioTurn = data.isDioTurn;
  String afterAction = '''<h2 align="center">Welcome to Community Battle game</h2>
<p align="center">Welcome to my Github profile! We're playing Battle game, you can join with us!</p>

<p align="center">It's the <b>${isDioTurn ? "<img src='assets/dio_brando.png' width=30>" : "<img src='assets/jotaro_kujo.png' width=30>"}<b> team's turn.</p>
<table align="center">
  <thead align="center">
    <tr>
      <td><b>Jotaro Kujo</b></td>
      <td><b>Dio Brando</b></td>
    </tr>
  </thead>
  <tbody>
    <tr align="center">
      <td><code><a href="https://github.com/congthanhng"><img src="assets/jotaro_kujo.png" width=55%></a></code></td>
      <td><code><a href="https://github.com/congthanhng"><img src="assets/dio_brando.png" width=55%></a></code></td>
    </tr>
    <tr>
      <td>HP: ${generateHP(data.joJo.hp)} ${data.joJo.hp.toString()}/100 <br> MP: ${generateMP(data.joJo.mana)} ${data.joJo.mana.toString()}/25</td>
      <td>HP: ${generateHP(data.dio.hp)} ${data.dio.hp.toString()}/100 <br> MP: ${generateMP(data.dio.mana)} ${data.dio.mana.toString()}/25</td>
    </tr>
  </tbody>
</table>


<p align="center">
    ---<img src="${generateDice(data.dice1, true)}" width=10%>
    ----
    <img src="${generateDice(data.dice2, false)}" width=10%>---
</p>

<p align="center"><b>${isDioTurn ? "<img src='assets/dio_brando.png' width=30>" : "<img src='assets/jotaro_kujo.png' width=30>"}<b> turn. You rolled a ${data.totalDice.toString()}!</p>

<p align="center">What would you like to do?</p>

<div align="center">

| Choices *(pick one of them!)*                                                                                                                                                                          |
|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|
| [Attack ${isDioTurn ? "Jotaro Kujo" : "Dio Brando"} with ${data.totalDice.toString()} points](https://github.com/congthanhng/congthanhng/issues/new?title=battle%7Cplay%7Cattack%7C${data.totalDice.toString()}&body=Just+push+%27Submit+new+issue%27.+You+don%27t+need+to+do+anything+else.) |
| [Heal yourself with ${data.totalDice.toString()} points](https://github.com/congthanhng/congthanhng/issues/new?title=battle%7Cplay%7Cheal%7C${data.totalDice.toString()}&body=Just+push+%27Submit+new+issue%27.+You+don%27t+need+to+do+anything+else.)           |
${canPowerful ? "| [Using MP, Attack with x2 dame: ${data.totalDice * 2} points](https://github.com/congthanhng/congthanhng/issues/new?title=battle%7Cplay%7Cattackx2%7C${data.totalDice.toString()}&body=Just+push+%27Submit+new+issue%27.+You+don%27t+need+to+do+anything+else.)           |" : ""}
${canPowerful ? "| [Using MP, Heal with x2 value: ${data.totalDice * 2} points](https://github.com/congthanhng/congthanhng/issues/new?title=battle%7Cplay%7Chealx2%7C${data.totalDice.toString()}&body=Just+push+%27Submit+new+issue%27.+You+don%27t+need+to+do+anything+else.)           |" : ""}

</div>
      ''';

  var result = '''
  $afterAction
  $howToPlay
  $introduce
  ''';
  return result;
}

String generateHP(int current) {
  int div = (current / 10).floor();
  List<String> result = [];
  for (int i = 1; i <= 10; i++) {
    if (div == 0 || div >= i) {
      result.add('█');
    } else {
      result.add('░');
    }
  }
  return result.join('');
}

String generateMP(int current) {
  int div = ((current / 25) * 6).floor();
  List<String> result = [];
  for (int i = 1; i <= 6; i++) {
    if (current == 25) {
      result.add('█');
    } else if (div == 0 && current == 0) {
      result.add('░');
    } else if (div == 0 && current > 0 && i == 1) {
      result.add('█');
    } else {
      if (div >= i) {
        result.add('█');
      } else {
        result.add('░');
      }
    }
  }
  return result.join('');
}

String generateDice(int point, bool isWhiteDice){
  switch(point){
    case 1: return "assets/${isWhiteDice?'dice_white':'dice_black'}/dice_1.png";
    case 2: return "assets/${isWhiteDice?'dice_white':'dice_black'}/dice_2.png";
    case 3: return "assets/${isWhiteDice?'dice_white':'dice_black'}/dice_3.png";
    case 4: return "assets/${isWhiteDice?'dice_white':'dice_black'}/dice_4.png";
    case 5: return "assets/${isWhiteDice?'dice_white':'dice_black'}/dice_5.png";
    case 6: return "assets/${isWhiteDice?'dice_white':'dice_black'}/dice_6.png";
    default: return "assets/${isWhiteDice?'dice_white':'dice_black'}/dice_1.png";
  }
}
