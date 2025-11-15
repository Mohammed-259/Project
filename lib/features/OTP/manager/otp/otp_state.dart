

import 'package:equatable/equatable.dart';

class OtpState extends Equatable {
  final int secondsRemaining;
  final bool enableResend;
  final bool hasError;
  final String errorMessage;

  const OtpState({
    this.secondsRemaining = 60,
    this.enableResend = false,
    this.hasError = false,
    this.errorMessage = '',
  });

  OtpState copyWith({
    int? secondsRemaining,
    bool? enableResend,
    bool? hasError,
    String? errorMessage,
  }) {
    return OtpState(
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      enableResend: enableResend ?? this.enableResend,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [secondsRemaining, enableResend, hasError, errorMessage];
}
