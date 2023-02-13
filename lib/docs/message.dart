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

String bodyGameEnd(bool isDioWon, List<dynamic> wonTeam, List<dynamic> loseTeam) =>
'''
🎊🎊 Congratulations, ${isDioWon ? "<b>Dio Brando</b>" : "<b>Jotaro Kujo</b>"} Team WON!

Players of this team: ${generatePlayer(wonTeam)}

Please try again in the next game: ${generatePlayer(loseTeam)}

The new game will be started immediately! 🤘🤘
''';

String generatePlayer(List<dynamic> players) => players.map((e) => '@$e',).join(', ');

String dontMoveBothTeam(String userName)=> "Sorry @$userName, you can't play both teams in a game! You can ask someone to play the next turn.";