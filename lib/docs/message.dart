String moveSuccess(String userName) =>
'''Hi @$userName, Your move is successful! View back at https://github.com/congthanhng

Ask a friend to take the next move: [Share on Twitter...](https://twitter.com/share?text=I%27m+playing+battle+game+on+a+GitHub+Profile+Readme!+I+just+fighted.+You+have+the+next+move+at+https://github.com/congthanhng)

The Issue will be automatically closed.''';

String moveFailure(String userName) =>
'''
Hi @$userName, Your move is failure! Please try again at https://github.com/congthanhng

The Issue will be automatically closed.
''';