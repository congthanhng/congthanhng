
enum ActionState { attack, attackx2, heal, healx2 }

extension ActionStateExtension on String {
  ActionState actionStateFromString() {
    switch (this) {
      case "attack":
        return ActionState.attack;
      case "attackx2":
        return ActionState.attackx2;
      case "heal":
        return ActionState.heal;
      case "healx2":
        return ActionState.healx2;
      default:
        return ActionState.attack;
    }
  }
}