class WakeWord {
  // এই সব শব্দ বললে LISA জেগে উঠবে
  static const List<String> _triggers = [
    'lisa',
    'লিসা',
    'লিছা',
    'লিশা',
    'লিজা',
    'lisa ',
    ' lisa',
  ];
 
  static bool detected(String input) {
    final cleaned = input.trim().toLowerCase();
    for (final trigger in _triggers) {
      if (cleaned.contains(trigger.trim())) {
        return true;
      }
    }
    return false;
  }
}
 