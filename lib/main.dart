import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:math';

import 'package:congthanhng/core/git_controller.dart';
import 'package:congthanhng/core/local_database.dart';
import 'package:github/github.dart';

import 'core/action_state.dart';
import 'core/action_gen.dart';
import 'core/state_data.dart';
import 'data/data_path.dart';
import 'docs/message.dart';

void main(List<String> arguments) async {
  final gitController = GitController.init();
  final localDB = await LocalDataBase.init();

  StateData resource = StateData.fromJson(localDB.stateData);
  try {
    //check user in team's side
    if (localDB.battleLog.isNotEmpty) {
      if (localDB.battleLog.values
              .where(
                (element) => element['player_name'] == gitController.userName,
              )
              .toList()
              .last['character'] !=
          gitController.character) {
        await gitController.gitCreateComment(dontMoveBothTeam(gitController.userName));
        await gitController.closeIssue();
        return;
      }
    }

    //init battleLog
    var currentTime = DateTime.now().toString();
    localDB.battleLog[currentTime] = {};
    localDB.battleLog[currentTime]["player_name"] = gitController.userName;
    localDB.battleLog[currentTime]["point"] = resource.totalDice;

    if (ActionType.values.toString().contains(gitController.actionType.toString()) &&
        gitController.value == resource.totalDice) {
      localDB.userData[gitController.userName] = (localDB.userData[gitController.userName] ?? 0) + 1;
      await localDB.writeUserData();

      int attackValue = 0;
      int healValue = 0;
      bool canPowerful = false;
      switch (gitController.actionType) {
        case ActionType.attack:
          attackValue = gitController.value;

          //set State of battle log
          localDB.battleLog[currentTime]["state"] = "attack";
          break;
        case ActionType.attackx2:
          //set State of battle log
          localDB.battleLog[currentTime]["state"] = "attackx2";
          if (resource.isDioTurn) {
            if (resource.dio.mana >= 15) {
              attackValue = gitController.value * 2;
              resource.dio.mana = 0;
            } else {
              attackValue = gitController.value;
            }
          } else {
            if (resource.joJo.mana >= 15) {
              attackValue = gitController.value * 2;
              resource.joJo.mana = 0;
            } else {
              attackValue = gitController.value;
            }
          }
          break;
        case ActionType.heal:
          //set State of battle log

          localDB.battleLog[currentTime]["state"] = "heal";
          healValue = gitController.value;
          break;
        case ActionType.healx2:
          //set State of battle log

          localDB.battleLog[currentTime]["state"] = "healx2";
          healValue = gitController.value * 2;
          if (resource.isDioTurn) {
            resource.dio.mana = 0;
          } else {
            resource.joJo.mana = 0;
          }
          break;
      }

      if (resource.isDioTurn) {
        localDB.battleLog[currentTime]["character"] = "Dio";
        if (resource.joJo.hp <= 0 || resource.joJo.hp <= attackValue) {
          //Dio WIN
          //reset game
          var reset = resource.resetGame(false);
          var dice1 = Random().nextInt(6) + 1;
          var dice2 = Random().nextInt(6) + 1;
          reset.dice1 = dice1;
          reset.dice2 = dice2;
          await File(statePath).writeAsString(jsonEncode(reset.toJson()));
          localDB.activityData['dio']['win']++;
          localDB.activityData['completeGame']++;
          await File(activityPath).writeAsString(jsonEncode(localDB.activityData));

          var historyData = await _gameHistoryRecord(
              localDB.battleLog, true, localDB.activityData['completeGame']);

          await File('README.md').writeAsString(generateREADME(
              reset, canPowerful, localDB.activityData, localDB.userData, localDB.battleLog));

          //comment and add label to current issue
          await gitController.gitCreateComment(
              moveSuccess(gitController.userName));
          await gitController.github.issues.addLabelsToIssue(
              RepositorySlug.full('${gitController.repositoryFullName}'),
              gitController.issueNumber,
              [successLabelType(gitController.actionType.toString().contains('attack'))]);

          //reset battleLog
          await File(battleLogPath).writeAsString(jsonEncode({}));

          var won = historyData['${localDB.activityData['completeGame']}']['dioPlayer'];
          var lose =
              historyData['${localDB.activityData['completeGame']}']['jojoPlayer'];
          //create new issue
          await gitController.github.issues.create(
              RepositorySlug.full('${gitController.repositoryFullName}'),
              IssueRequest(
                  title:
                      '🎉🎉 Congratulations! Game ${localDB.activityData['completeGame']} is Completed! 🎉🎉',
                  state: 'closed',
                  labels: [gameEnd],
                  body: bodyGameEnd(true, won, lose)));
          return;
        } else {
          //decrease jojo HP
          resource.joJo.hp -= attackValue;
          localDB.activityData['dio']['attackDmg'] += attackValue;
          //increase JoJO MP
          resource.joJo.mana += attackValue;
          if (resource.joJo.mana >= 15) {
            resource.joJo.mana = 15;
            canPowerful = true;
          }
        }

        if (resource.dio.hp + healValue > 50) {
          int remainHealValue = healValue - (50 - resource.dio.hp);
          localDB.activityData['dio']['healRecover'] += 50 - resource.dio.hp;

          resource.dio.mana += remainHealValue;
          resource.dio.hp = 50;
        } else {
          resource.dio.hp += healValue;
          localDB.activityData['dio']['healRecover'] += healValue;
        }
      } else {
        localDB.battleLog[currentTime]["character"] = "JoJo";
        if (resource.dio.hp <= 0 || resource.dio.hp <= attackValue) {
          //JoJo WIN
          //reset game
          var reset = resource.resetGame(true);
          var dice1 = Random().nextInt(6) + 1;
          var dice2 = Random().nextInt(6) + 1;
          reset.dice1 = dice1;
          reset.dice2 = dice2;
          await File(statePath).writeAsString(jsonEncode(reset.toJson()));
          localDB.activityData['joJo']['win']++;
          localDB.activityData['completeGame']++;
          await File(activityPath).writeAsString(jsonEncode(localDB.activityData));

          var historyData = await _gameHistoryRecord(
              localDB.battleLog, false, localDB.activityData['completeGame']);

          await File('README.md').writeAsString(generateREADME(
              reset, canPowerful, localDB.activityData, localDB.userData, localDB.battleLog));

          //comment and add label to current issue
          await gitController.gitCreateComment(
              moveSuccess(gitController.userName));
          await gitController.github.issues.addLabelsToIssue(
              RepositorySlug.full('${gitController.repositoryFullName}'),
              gitController.issueNumber,
              [successLabelType(gitController.actionType.toString().contains('attack'))]);

          //reset battleLog
          await File(battleLogPath).writeAsString(jsonEncode({}));

          var won =
              historyData['${localDB.activityData['completeGame']}']['jojoPlayer'];
          var lose =
              historyData['${localDB.activityData['completeGame']}']['dioPlayer'];
          //create new issue
          await gitController.github.issues.create(
              RepositorySlug.full('${gitController.repositoryFullName}'),
              IssueRequest(
                  title:
                      '🎉🎉 Congratulations! Game ${localDB.activityData['completeGame']} is Completed! 🎉🎉',
                  state: 'closed',
                  labels: [gameEnd],
                  body: bodyGameEnd(false, won, lose)));
          return;
        } else {
          //decrease dio HP
          resource.dio.hp -= attackValue;
          localDB.activityData['joJo']['attackDmg'] += attackValue;
          //increase dio MP
          resource.dio.mana += attackValue;
          if (resource.dio.mana >= 15) {
            resource.dio.mana = 15;
            canPowerful = true;
          }
        }
        if (resource.joJo.hp + healValue > 50) {
          int remainHealValue = healValue - (50 - resource.joJo.hp);
          localDB.activityData['joJo']['healRecover'] += healValue;
          resource.joJo.mana += remainHealValue;
          resource.joJo.hp = 50;
        } else {
          resource.joJo.hp += healValue;
          localDB.activityData['joJo']['healRecover'] += healValue;
        }
      }

      resource.isDioTurn = !resource.isDioTurn;

      var dice1 = Random().nextInt(6) + 1;
      var dice2 = Random().nextInt(6) + 1;
      resource.dice1 = dice1;
      resource.dice2 = dice2;

      // print('toJsonString: ${resource.toJsonString()}');
      await File(statePath).writeAsString(jsonEncode(resource.toJson()));

      await File('README.md').writeAsString(generateREADME(
          resource, canPowerful, localDB.activityData, localDB.userData, localDB.battleLog));

      localDB.activityData['moves']++;
      await File(activityPath).writeAsString(jsonEncode(localDB.activityData));

      await File(battleLogPath).writeAsString(jsonEncode(localDB.battleLog));

      await gitController.gitCreateComment(
          moveSuccess(gitController.userName));
      await gitController.github.issues.addLabelsToIssue(
          RepositorySlug.full('${gitController.repositoryFullName}'),
          gitController.issueNumber,
          [successLabelType(gitController.actionType.toString().contains('attack'))]);
    } else {
      throw Exception('The Issue is not correct with title format');
    }
  } catch (e) {
    await gitController.gitCreateComment(
        moveFailure(gitController.userName));
    await gitController.github.issues.addLabelsToIssue(
        RepositorySlug.full('${gitController.repositoryFullName}'),
        gitController.issueNumber,
        [failureLabel]);
    throw Exception(e);
  }
}

Future<Map<String, dynamic>> readJsonFile(String filePath) async {
  var input = await File(filePath).readAsString();
  var map = jsonDecode(input);
  return map;
}

Future<Map<String, dynamic>> _gameHistoryRecord(
    Map<String, dynamic> battleLog, bool isDioWon, int gameNumber) async {
  Map<String, dynamic> historyData = await readJsonFile(gameHistoryPath);
  var currentRecordKey = gameNumber;
  historyData['$currentRecordKey'] = {};
  historyData['$currentRecordKey']['isDioWon'] = isDioWon;
  historyData['$currentRecordKey']['gameNumber'] = currentRecordKey;
  var listDio = battleLog.values
      .where(
        (element) => element["character"] == "Dio",
      )
      .map(
        (e) => e["player_name"],
      )
      .toSet();
  var listJoJo = battleLog.values
      .where(
        (element) => element["character"] != "Dio",
      )
      .map(
        (e) => e["player_name"],
      )
      .toSet();
  historyData['$currentRecordKey']['dioPlayer'] = [...listDio];
  historyData['$currentRecordKey']['jojoPlayer'] = [...listJoJo];
  historyData['$currentRecordKey']['totalMoves'] = battleLog.length;

  await File(gameHistoryPath).writeAsString(jsonEncode(historyData));

  return historyData;
}
