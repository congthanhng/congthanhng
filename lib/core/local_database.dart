import 'dart:convert';
import 'dart:io';

import 'package:congthanhng/core/utils.dart';
import 'package:congthanhng/data/data_path.dart';

class LocalDataBase {
  final Map<String, dynamic> statusData;
  final Map<String, dynamic> activityData;
  final Map<String, dynamic> userData;
  final Map<String, dynamic> battleLog;

  LocalDataBase(
      {required this.statusData,
      required this.activityData,
      required this.userData,
      required this.battleLog});

  static Future<LocalDataBase> init() async {
    Map<String, dynamic> stateData = await readJsonFile(statusFilePath);
    Map<String, dynamic> activityData = await readJsonFile(activityPath);
    Map<String, dynamic> userData = await readJsonFile(userRecordPath);
    Map<String, dynamic> battleLog = await readJsonFile(battleLogPath);
    return LocalDataBase(
        activityData: activityData,
        battleLog: battleLog,
        statusData: stateData,
        userData: userData);
  }

  Future<void> writeUserData(Map<String, dynamic>? data) async {
    await File(userRecordPath).writeAsString(jsonEncode(data ?? userData));
  }

  Future<void> writeActivityData(Map<String, dynamic>? data) async {
    await File(activityPath).writeAsString(jsonEncode(data ?? activityData));
  }

  Future<void> writeStatusData(Map<String, dynamic>? data) async {
    await File(statusFilePath).writeAsString(jsonEncode(data ?? statusData));
  }

  Future<void> writeBattleLogData(Map<String, dynamic>? data) async {
    await File(battleLogPath).writeAsString(jsonEncode(data ?? battleLog));
  }

  Future<Map<String, dynamic>> gameHistoryRecord(bool isDioWon) async {
    var gameNumber = activityData['completeGame'];
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
}
