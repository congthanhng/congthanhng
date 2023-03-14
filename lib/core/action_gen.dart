import '../docs/how_to_play.dart';
import '../docs/introduce.dart';
import 'state_data.dart';

String generateHP(int current) {
  int div = ((current / 50) * 10).floor();
  List<String> result = [];
  for (int i = 1; i <= 10; i++) {
    if (div == 0 && current > 0 && i == 1) {
      result.add('█');
    } else if (div >= i) {
      result.add('█');
    } else {
      result.add('░');
    }
  }
  return result.join('');
}

String generateMP(int current) {
  int div = ((current / 15) * 6).floor();
  List<String> result = [];
  for (int i = 1; i <= 6; i++) {
    if (current == 15) {
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

String generateDice(int point, bool isWhiteDice) {
  switch (point) {
    case 1:
      return "assets/${isWhiteDice ? 'dice_white' : 'dice_black'}/dice_1.png";
    case 2:
      return "assets/${isWhiteDice ? 'dice_white' : 'dice_black'}/dice_2.png";
    case 3:
      return "assets/${isWhiteDice ? 'dice_white' : 'dice_black'}/dice_3.png";
    case 4:
      return "assets/${isWhiteDice ? 'dice_white' : 'dice_black'}/dice_4.png";
    case 5:
      return "assets/${isWhiteDice ? 'dice_white' : 'dice_black'}/dice_5.png";
    case 6:
      return "assets/${isWhiteDice ? 'dice_white' : 'dice_black'}/dice_6.png";
    default:
      return "assets/${isWhiteDice ? 'dice_white' : 'dice_black'}/dice_1.png";
  }
}

String generateCharacter(String key) {
  switch (key) {
    case "Dio":
      return "<img src='assets/dio_brando.png' width=30>";
    default:
      return "<img src='assets/jotaro_kujo.png' width=30>";
  }
}

String generateTypeAction(String type) {
  switch (type) {
    case "attack":
      return "<img src='assets/actions/attack.png' width=30>";
    case 'attackx2':
      return "<img src='assets/actions/attack.png' width=30><img src='assets/actions/attack.png' width=30>";
    case 'heal':
      return "<img src='assets/actions/heal.png' width=30>";
    default:
      return "<img src='assets/actions/heal.png' width=30><img src='assets/actions/heal.png' width=30>";
  }
}

String generatePlayerCheckIn(Map<String, dynamic> userData) {
  return userData.entries
      .toList()
      .map((e) =>
  '<a href="https://github.com/${e.key}"><img src="https://img.shields.io/badge/@${e.key}-${e.value.toString()}-blue" ></a>')
      .join(' ');
}

String generateREADME(
    StateData data,
    bool canPowerful,
    Map<String, dynamic> activityData,
    Map<String, dynamic> userData,
    Map<String, dynamic> battleLog) {
  var isDioTurn = data.isDioTurn;

  String afterAction =
  '''<h2 align="center">Welcome to Community Battle game</h2>
<p align="center">Welcome to my Github profile! We're playing Battle game, you can join with us!</p>

<div align="center">

![](https://img.shields.io/badge/Moves%20played-${activityData['moves'].toString()}-blue)
![](https://img.shields.io/badge/Completed%20games-${activityData['completeGame'].toString()}-orange)
![](https://img.shields.io/badge/Total%20players-${userData.entries.length.toString()}-red)
<img src="https://komarev.com/ghpvc/?username=congthanhng&color=blue" />

</div>

<p align="center">It's the ${isDioTurn ? "<b>Dio Brando</b> <img src='assets/dio_brando.png' width=30>" : "<b>Jotaro Kujo</b> <img src='assets/jotaro_kujo.png' width=30>"} team's turn.</p>
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
      <td>HP: ${generateHP(data.joJo.hp)} ${data.joJo.hp.toString()}/50 <br> MP: ${generateMP(data.joJo.mana)} ${data.joJo.mana.toString()}/15 <br>Won: ${activityData['joJo']['win']}</td>
      <td>HP: ${generateHP(data.dio.hp)} ${data.dio.hp.toString()}/50 <br> MP: ${generateMP(data.dio.mana)} ${data.dio.mana.toString()}/15 <br>Won: ${activityData['dio']['win']}</td>
    </tr>
  </tbody>
</table>

<div align="center">
    <img src="${generateDice(data.dice1, true)}" width=10%>
    <img src="${generateDice(data.dice2, false)}" width=10%>
</div>
<br>
<p align="center">It's ${isDioTurn ? "<b>Dio Brando</b> <img src='assets/dio_brando.png' width=30>" : "<b>Jotaro Kujo</b> <img src='assets/jotaro_kujo.png' width=30>"} turn. You rolled a <b style="color:Tomato;font-size:25px;">${data.totalDice.toString()}</b></p>

<p align="center">What would you like to do?</p>

<div align="center">

| Type Action |Choices *(pick one of them!)*                                                                                                                                                                          |
|:-------------:|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| <img src="assets/actions/attack.png" width=30> | [Attack ${isDioTurn ? "**Jotaro Kujo**" : "**Dio Brando**"}: ${data.totalDice.toString()} points](https://github.com/congthanhng/congthanhng/issues/new?title=battle%7C${isDioTurn ? 'Dio' : 'JoJo'}%7Cattack%7C${data.totalDice.toString()}&body=Just+push+%27Submit+new+issue%27.+You+don%27t+need+to+do+anything+else.) |
| <img src="assets/actions/heal.png" width=30> | [Heal ${isDioTurn ? "**Dio Brando**" : "**Jotaro Kujo**"}: ${data.totalDice.toString()} points](https://github.com/congthanhng/congthanhng/issues/new?title=battle%7C${isDioTurn ? 'Dio' : 'JoJo'}%7Cheal%7C${data.totalDice.toString()}&body=Just+push+%27Submit+new+issue%27.+You+don%27t+need+to+do+anything+else.)           |
${canPowerful ? "| <img src='assets/actions/attack.png' width=30><img src='assets/actions/attack.png' width=30> | [Using MP, Attack with x2 damage: ${data.totalDice * 2} points](https://github.com/congthanhng/congthanhng/issues/new?title=battle%7C${isDioTurn ? 'Dio' : 'JoJo'}%7Cattackx2%7C${data.totalDice.toString()}&body=Just+push+%27Submit+new+issue%27.+You+don%27t+need+to+do+anything+else.)           |" : ""}
${canPowerful ? "| <img src='assets/actions/heal.png' width=30><img src='assets/actions/heal.png' width=30> | [Using MP, Heal with x2 value: ${data.totalDice * 2} points](https://github.com/congthanhng/congthanhng/issues/new?title=battle%7C${isDioTurn ? 'Dio' : 'JoJo'}%7Chealx2%7C${data.totalDice.toString()}&body=Just+push+%27Submit+new+issue%27.+You+don%27t+need+to+do+anything+else.)           |" : ""}

</div>

<br>

${generateMostRecentMove(battleLog)}
<br>
<div align="center">

**🎮 Players check-in**

${generatePlayerCheckIn(userData)}

</div>

''';

  var result = '''
  $afterAction
  $howToPlay
  $introduce
  ''';
  return result;
}

String generateMostRecentMove(Map<String, dynamic> battleLog) =>
    battleLog.values.isNotEmpty
        ? '''
<div align="center">

**:alarm_clock: Most recent moves**

| Team | Dices rolled | Type Action | Made by |
| ---- | :----: | :-------: | ------- |
| ${generateCharacter(battleLog.values.last["character"])} | ${battleLog.values.last["point"]} | ${generateTypeAction(battleLog.values.last["state"])} | [@${battleLog.values.last["player_name"]}](https://github.com/${battleLog.values.last["player_name"]}) |
${battleLog.values.length >= 2 ? "| ${generateCharacter(battleLog.values.toList()[battleLog.values.length - 2]["character"])} | ${battleLog.values.toList()[battleLog.values.length - 2]["point"]} | ${generateTypeAction(battleLog.values.toList()[battleLog.values.length - 2]["state"])} | [@${battleLog.values.toList()[battleLog.values.length - 2]["player_name"]}](https://github.com/${battleLog.values.toList()[battleLog.values.length - 2]["player_name"]}) |" : ''}

</div>
'''
        : '';

// String generateGameRecord(
//     StateData data,
//     bool canPowerful,
//     Map<String, dynamic> activityData,
//     Map<String, dynamic> userData,
//     Map<String, dynamic> battleLog){
//
// }
