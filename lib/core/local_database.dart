import 'package:congthanhng/core/utils.dart';
import 'package:congthanhng/data/data_path.dart';

class LocalDataBase {
  final Map<String, dynamic> stateData;
  final Map<String, dynamic> activityData;
  final Map<String, dynamic> userData;
  final Map<String, dynamic> battleLog;

  LocalDataBase(
      {required this.stateData,
      required this.activityData,
      required this.userData,
      required this.battleLog});

  static Future<LocalDataBase> init() async {
    Map<String, dynamic> stateData = await readJsonFile(statePath);
    Map<String, dynamic> activityData = await readJsonFile(activityPath);
    Map<String, dynamic> userData = await readJsonFile(userRecordPath);
    Map<String, dynamic> battleLog = await readJsonFile(battleLogPath);
    return LocalDataBase(
      activityData: activityData,
      battleLog: battleLog,
      stateData: stateData,
      userData: userData
    );
  }
}
