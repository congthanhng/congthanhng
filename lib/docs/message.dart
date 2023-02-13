const String failureLabel = '🚫 Action-Fail';
const String gameEnd = '👑 Game-End';


String moveSuccess(String userName) =>
'''Hi @$userName, Your move is successful! View back at https://github.com/congthanhng

Ask a friend to take the next move: [Share on Twitter...](https://twitter.com/share?text=I%27m+playing+a+battle+game+on+a+GitHub+Profile+Readme!+I+just+fighted.+You+have+the+next+move+at+https://github.com/congthanhng)

The Issue will be automatically closed.''';

String moveFailure(String userName) =>
'''
Hi @$userName, Your move is failure! Please try again at https://github.com/congthanhng

The Issue will be automatically closed.
''';

String successLabelType(bool isAttack) => '${isAttack?"👊 Attack":"💚 Heal"}-Success';

String bodyGameEnd(bool isDioWon, List<String> wonTeam, List<String> loseTeam) =>
'''
🎊🎊 Congratulations, ${isDioWon ? "<b>Dio Brando</b> <img src='assets/dio_brando.png' width=30>" : "<b>Jotaro Kujo</b> <img src='assets/jotaro_kujo.png' width=30>"} Team WON!

Players of this team: ${generatePlayer(wonTeam)}

Please try again in the next game: ${generatePlayer(loseTeam)}

The new game will be started immediately! 🤘🤘
''';

String generatePlayer(List<String> players) => players.map((e) => '@$e',).join(', ');