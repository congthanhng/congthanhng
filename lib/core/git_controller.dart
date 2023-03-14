import 'dart:io';

import 'package:congthanhng/core/action_state.dart';
import 'package:congthanhng/core/exceptions/git_config_exception.dart';
import 'package:github/github.dart';

class GitController {
  final int issueNumber;
  final String repositoryFullName;
  final String userName;
  final ActionType actionType;
  final int value;
  final String character;
  final GitHub github;

  GitController._(
      {required this.issueNumber,
      required this.userName,
      required this.repositoryFullName,
      required this.actionType,
      required this.value,
      required this.character,
      required this.github});

  factory GitController.init() {
    var number = int.tryParse(Platform.environment['ISSUE_NUMBER'] ?? '');
    if (number == null) {
      throw GitConfigException('The IssueNumber is invalid');
    }

    var rawData = Platform.environment['ISSUE_TITLE'] ?? '';
    List<String> args = rawData.split('|');
    if (args.isEmpty) {
      throw GitConfigException('The IssueTitle is invalid');
    }

    var point = int.tryParse(args[3]);
    if (point == null) {
      throw GitConfigException('The DiceValue is invalid');
    }

    var authToken = Platform.environment['GITHUB_API_TOKEN'];
    if (authToken == null) {
      throw GitConfigException('The AuthToken is not valid');
    }

    return GitController._(
        userName: Platform.environment['USER_PLAYER'] ?? '',
        issueNumber: number,
        repositoryFullName: Platform.environment['REPOSITORY_NAME'] ?? '',
        value: point,
        actionType: args[2].actionStateFromString(),
        character: args[1],
        github: GitHub(auth: Authentication.withToken(authToken)));
  }

  Future<void> gitCreateComment(String comment) async {
    await github.issues.createComment(
        RepositorySlug.full('$repositoryFullName'), issueNumber, comment);
  }

  Future<void> closeIssue() async {
    await github.issues.edit(RepositorySlug.full('$repositoryFullName'),
        issueNumber, IssueRequest(state: 'closed'));
  }
}
