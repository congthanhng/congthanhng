
enum ActionType { none, attack, attackx2, heal, healx2 }

extension ActionStateExtension on String {
  ActionType actionStateFromString() {
    switch (this) {
      case "attack":
        return ActionType.attack;
      case "attackx2":
        return ActionType.attackx2;
      case "heal":
        return ActionType.heal;
      case "healx2":
        return ActionType.healx2;
      default:
        return ActionType.none;
    }
  }
}