import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:math';

import 'package:congthanhng/core/exceptions/game_exception.dart';
import 'package:congthanhng/core/exceptions/git_config_exception.dart';
import 'package:congthanhng/core/git_controller.dart';
import 'package:congthanhng/core/local_database.dart';
import 'package:github/github.dart';

import 'core/action_gen.dart';
import 'core/action_state.dart';
import 'core/status_data.dart';
import 'data/data_path.dart';
import 'docs/message.dart';

void main(List<String> arguments) async {
  try {
    final gitController = GitController.init();
    final localDB = await LocalDataBase.init();

    StatusData statusData = StatusData.fromJson(localDB.statusData);
    //Checking the user in a team's side
    if (localDB.battleLog.isNotEmpty) {
      var list = localDB.battleLog.values
          .where(
            (element) => element['player_name'] == gitController.userName,
          )
          .toList();
      if (list.isNotEmpty &&
          list.last['character'] != gitController.character) {
        throw GameException('Can\'t play in both team');
      }
    }

    //create new item in battleLog
    var currentTime = DateTime.now().toString();
    localDB.battleLog[currentTime] = {};
    localDB.battleLog[currentTime]["player_name"] = gitController.userName;
    localDB.battleLog[currentTime]["point"] = statusData.totalDice;

    if (gitController.value == statusData.totalDice) {
      localDB.userData[gitController.userName] =
          (localDB.userData[gitController.userName] ?? 0) + 1;
      await localDB.writeUserData(localDB.userData);

      int _attackValue = 0;
      int _healValue = 0;
      bool _canPowerful = false;
      switch (gitController.actionType) {
        case ActionType.attack:
          _attackValue = gitController.value;
          //set Status of battle log
          localDB.battleLog[currentTime]["state"] = "attack";
          break;
        case ActionType.attackx2:
          //set Status of battle log
          localDB.battleLog[currentTime]["state"] = "attackx2";
          if (statusData.isDioTurn) {
            if (statusData.dio.mana >= 15) {
              _attackValue = gitController.value * 2;
              statusData.dio.mana = 0;
            } else {
              _attackValue = gitController.value;
            }
          } else {
            if (statusData.joJo.mana >= 15) {
              _attackValue = gitController.value * 2;
              statusData.joJo.mana = 0;
            } else {
              _attackValue = gitController.value;
            }
          }
          break;
        case ActionType.heal:
          //set Status of battle log
          localDB.battleLog[currentTime]["state"] = "heal";
          _healValue = gitController.value;
          break;
        case ActionType.healx2:
          //set Status of battle log
          localDB.battleLog[currentTime]["state"] = "healx2";
          _healValue = gitController.value * 2;
          if (statusData.isDioTurn) {
            statusData.dio.mana = 0;
          } else {
            statusData.joJo.mana = 0;
          }
          break;
        case ActionType.none:
          break;
      }

      //begin action and save data
      if (statusData.isDioTurn) {
        localDB.battleLog[currentTime]["character"] = "Dio";
        if (statusData.joJo.hp <= 0 || statusData.joJo.hp <= _attackValue) {
          //Dio will WIN
          //reset game
          var reset = statusData.resetGame(false);
          var dice1 = Random().nextInt(6) + 1;
          var dice2 = Random().nextInt(6) + 1;
          reset.dice1 = dice1;
          reset.dice2 = dice2;
          await localDB.writeStatusData(reset.toJson());

          localDB.activityData['dio']['win']++;
          localDB.activityData['completeGame']++;
          await localDB.writeActivityData(reset.toJson());

          await File(activityPath)
              .writeAsString(jsonEncode(localDB.activityData));

          var historyData = await localDB.gameHistoryRecord(true);

          await File('README.md').writeAsString(generateREADME(
              reset,
              _canPowerful,
              localDB.activityData,
              localDB.userData,
              localDB.battleLog));

          //comment and add label to current issue
          await gitController
              .gitCreateComment(moveSuccess(gitController.userName));
          await gitController.gitAddSuccessLabelsToIssue(
              gitController.actionType.toString().contains('attack'));

          //reset battleLog
          await localDB.writeBattleLogData({});

          var won = historyData['${localDB.activityData['completeGame']}']
              ['dioPlayer'];
          var lose = historyData['${localDB.activityData['completeGame']}']
              ['jojoPlayer'];
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
          statusData.joJo.hp -= _attackValue;
          localDB.activityData['dio']['attackDmg'] += _attackValue;
          //increase JoJO MP
          statusData.joJo.mana += _attackValue;
          if (statusData.joJo.mana >= 15) {
            statusData.joJo.mana = 15;
            _canPowerful = true;
          }
        }

        if (statusData.dio.hp + _healValue > 50) {
          int remainHealValue = _healValue - (50 - statusData.dio.hp);
          localDB.activityData['dio']['healRecover'] += 50 - statusData.dio.hp;

          statusData.dio.mana += remainHealValue;
          statusData.dio.hp = 50;
        } else {
          statusData.dio.hp += _healValue;
          localDB.activityData['dio']['healRecover'] += _healValue;
        }
      } else {
        localDB.battleLog[currentTime]["character"] = "JoJo";
        if (statusData.dio.hp <= 0 || statusData.dio.hp <= _attackValue) {
          //JoJo will WIN
          //reset game
          var reset = statusData.resetGame(true);
          var dice1 = Random().nextInt(6) + 1;
          var dice2 = Random().nextInt(6) + 1;
          reset.dice1 = dice1;
          reset.dice2 = dice2;
          await localDB.writeStatusData(reset.toJson());
          localDB.activityData['joJo']['win']++;
          localDB.activityData['completeGame']++;
          await localDB.writeActivityData(localDB.activityData);

          var historyData = await localDB.gameHistoryRecord(false);

          await File('README.md').writeAsString(generateREADME(
              reset,
              _canPowerful,
              localDB.activityData,
              localDB.userData,
              localDB.battleLog));

          //comment and add label to current issue
          await gitController
              .gitCreateComment(moveSuccess(gitController.userName));
          await gitController.gitAddSuccessLabelsToIssue(
              gitController.actionType.toString().contains('attack'));

          //reset battleLog
          await localDB.writeBattleLogData({});

          var won = historyData['${localDB.activityData['completeGame']}']
              ['jojoPlayer'];
          var lose = historyData['${localDB.activityData['completeGame']}']
              ['dioPlayer'];
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
          statusData.dio.hp -= _attackValue;
          localDB.activityData['joJo']['attackDmg'] += _attackValue;
          //increase dio MP
          statusData.dio.mana += _attackValue;
          if (statusData.dio.mana >= 15) {
            statusData.dio.mana = 15;
            _canPowerful = true;
          }
        }
        if (statusData.joJo.hp + _healValue > 50) {
          int remainHealValue = _healValue - (50 - statusData.joJo.hp);
          localDB.activityData['joJo']['healRecover'] += _healValue;
          statusData.joJo.mana += remainHealValue;
          statusData.joJo.hp = 50;
        } else {
          statusData.joJo.hp += _healValue;
          localDB.activityData['joJo']['healRecover'] += _healValue;
        }
      }

      statusData.isDioTurn = !statusData.isDioTurn;

      var dice1 = Random().nextInt(6) + 1;
      var dice2 = Random().nextInt(6) + 1;
      statusData.dice1 = dice1;
      statusData.dice2 = dice2;

      localDB.writeStatusData(statusData.toJson());

      await File('README.md').writeAsString(generateREADME(
          statusData,
          _canPowerful,
          localDB.activityData,
          localDB.userData,
          localDB.battleLog));

      localDB.activityData['moves']++;
      await localDB.writeActivityData(localDB.activityData);

      await localDB.writeBattleLogData(localDB.battleLog);

      await gitController.gitCreateComment(moveSuccess(gitController.userName));
      await gitController.gitAddSuccessLabelsToIssue(
          gitController.actionType.toString().contains('attack'));
    } else {
      throw GitConfigException(
          'The Rolled Dices Value is not match with current data. Maybe someone has played before you.');
    }
  } catch (e) {
    if (e is GameException) {
      var gitAuth = GitAuthentication();
      await gitAuth.gitCreateComment(dontMoveBothTeam(gitAuth.userName));
      await gitAuth.gitAddFailureLabelsToIssue();
      await gitAuth.closeIssue();
    } else if (e is GitConfigException) {
      var gitAuth = GitAuthentication();
      await gitAuth.gitCreateComment(
          moveFailureWithGitConfigError(gitAuth.userName, e.message));
      await gitAuth.gitAddFailureLabelsToIssue();
      await gitAuth.closeIssue();
    } else {
      throw Exception(e);
    }
  }
}
