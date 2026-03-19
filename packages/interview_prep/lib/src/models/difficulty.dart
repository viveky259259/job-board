enum Difficulty {
  beginner,
  intermediate,
  advanced,
  expert;

  String get label {
    switch (this) {
      case Difficulty.beginner:
        return 'Beginner';
      case Difficulty.intermediate:
        return 'Intermediate';
      case Difficulty.advanced:
        return 'Advanced';
      case Difficulty.expert:
        return 'Expert';
    }
  }

  int get sortOrder => index;

  double get weight {
    switch (this) {
      case Difficulty.beginner:
        return 1.0;
      case Difficulty.intermediate:
        return 1.5;
      case Difficulty.advanced:
        return 2.0;
      case Difficulty.expert:
        return 3.0;
    }
  }
}
