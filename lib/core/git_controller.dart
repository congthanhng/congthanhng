import 'dart:io';

import 'package:congthanhng/core/action_state.dart';
import 'package:congthanhng/core/exceptions/git_config_exception.dart';
import 'package:congthanhng/docs/message.dart';
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
    var authToken = Platform.environment['GITHUB_API_TOKEN'];
    if (authToken == null) {
      throw Exception('Something wrong with verifying.');
    }

    var userPath = Platform.environment['REPOSITORY_NAME'];
    if (userPath == null) {
      throw Exception('Something wrong with userName path.');
    }

    var number = int.tryParse(Platform.environment['ISSUE_NUMBER'] ?? '');
    if (number == null) {
      throw Exception('The IssueNumber is invalid.');
    }

    var rawData = Platform.environment['ISSUE_TITLE'] ?? '';
    List<String> args = rawData.split('|');
    if (args.isEmpty || args.length < 4) {
      throw GitConfigException('The IssueTitle is invalid syntax.');
    }

    var point = int.tryParse(args[3]);
    if (point == null || point > 12) {
      throw GitConfigException(
          'The Rolled Dices Value is not match with current data. Maybe someone has played before you.');
    }

    var action = args[2].actionStateFromString();
    if (action == ActionType.none) {
      throw GitConfigException('The IssueTitle with action type is not valid.');
    }

    return GitController._(
        userName: Platform.environment['USER_PLAYER'] ?? '',
        issueNumber: number,
        repositoryFullName: userPath,
        value: point,
        actionType: action,
        character: args[1],
        github: GitHub(auth: Authentication.withToken(authToken)));
  }

  Future<void> gitCreateComment(String comment,
      {int? previousIssueNumber}) async {
    await github.issues.createComment(
        RepositorySlug.full('$repositoryFullName'),
        previousIssueNumber ?? issueNumber,
        comment);
  }

  Future<void> closeIssue() async {
    await github.issues.edit(RepositorySlug.full('$repositoryFullName'),
        issueNumber, IssueRequest(state: 'closed'));
  }

  Future<void> gitAddFailureLabelsToIssue() async {
    await github.issues.addLabelsToIssue(
        RepositorySlug.full('${repositoryFullName}'),
        issueNumber,
        [failureLabel]);
  }

  Future<void> gitAddSuccessLabelsToIssue(bool isAttack) async {
    await github.issues.addLabelsToIssue(
        RepositorySlug.full('${repositoryFullName}'),
        issueNumber,
        [successLabelType(isAttack)]);
  }
}

class GitAuthentication {
  final GitHub github;
  final int issueNumber;
  final String repositoryFullName;
  final String userName;

  GitAuthentication()
      : issueNumber = int.parse(Platform.environment['ISSUE_NUMBER'] ?? ''),
        github = GitHub(
            auth: Authentication.withToken(
                Platform.environment['GITHUB_API_TOKEN'])),
        repositoryFullName = Platform.environment['REPOSITORY_NAME'] ?? '',
        userName = Platform.environment['USER_PLAYER'] ?? '';

  Future<void> gitAddFailureLabelsToIssue() async {
    await github.issues.addLabelsToIssue(
        RepositorySlug.full('${repositoryFullName}'),
        issueNumber,
        [failureLabel]);
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
