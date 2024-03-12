sealed class PasscodeState {}

final class PasscodeInitial extends PasscodeState {}

final class PasscodeLoading extends PasscodeState {}

final class PasscodeLoaded extends PasscodeState {
  final List<String> passcode;

  PasscodeLoaded({required this.passcode});
}

final class PasscodeError extends PasscodeState {
  final String errorMsg;

  PasscodeError({
    required this.errorMsg,
  });
}
