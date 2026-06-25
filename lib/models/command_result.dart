enum CommandStatus {
  success,
  failed,
  alreadyEnabled,
  alreadyDisabled,
  invalidInput,
  notFound,
  permissionDenied,
}

class CommandResult {
  final bool success;
  final CommandStatus status;
  final String message;

  const CommandResult({
    required this.success,
    required this.status,
    required this.message,
  });
}