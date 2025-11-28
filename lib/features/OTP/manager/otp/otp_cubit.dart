import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'otp_state.dart';

class OtpCubit extends Cubit<OtpState> {
  Timer? _timer;

  OtpCubit() : super(const OtpState()) {
    startTimer();
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.secondsRemaining > 0) {
        emit(state.copyWith(secondsRemaining: state.secondsRemaining - 1));
      } else {
        emit(state.copyWith(enableResend: true));
        timer.cancel();
      }
    });
  }

  void resendCode() {
    emit(state.copyWith(secondsRemaining: 60, enableResend: false));
    startTimer();
  }

  void verifyOtp(String otp, Function onSuccess) {
    if (otp.isEmpty || otp.length < 4) {
      emit(state.copyWith(hasError: true, errorMessage: "This field is required"));
    } else if (otp != "1234") {
      emit(state.copyWith(hasError: true, errorMessage: "The code is incorrect"));
    } else {
      emit(state.copyWith(hasError: false, errorMessage: ""));
      onSuccess();
    }
  }

  void clearError() {
    emit(state.copyWith(hasError: false, errorMessage: ""));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
