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

String moveFailureWithGitConfigError(String userName, String message) =>
    '''
Hi @$userName, Your move is failure with error: "$message" 

Please try again at https://github.com/congthanhng

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

String notifyPreviousPlayer(String userName) =>
    '''Hi @$userName, The opponent team has moved. Now it your turn. The victory are waiting for you. Play now at: https://github.com/congthanhng

You can invite your friend to enjoy it: [Share on Twitter...](https://twitter.com/share?text=I%27m+playing+a+battle+game+on+a+GitHub+Profile+Readme!+I+just+fighted.+You+have+the+next+move+at+https://github.com/congthanhng)

Thanks for contribution!''';


String generatePlayer(List<dynamic> players) => players.map((e) => '@$e',).join(', ');

String dontMoveBothTeam(String userName)=>
'''
Sorry @$userName, you can't play both teams in a game! You can ask someone to play the next turn.

Ask a friend to take the next move: [Share on Twitter...](https://twitter.com/share?text=I%27m+playing+a+battle+game+on+a+GitHub+Profile+Readme!+I+just+fighted.+You+have+the+next+move+at+https://github.com/congthanhng)

''';