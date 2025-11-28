import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medication_reminder/features/auth/manager/signup/signup_states.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());

  static RegisterCubit get(context) => BlocProvider.of(context);

  bool isPassword = true;
  bool isConfirmPassword = true;
  bool isChecked = false;

  var formKey = GlobalKey<FormState>();
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var phoneController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();

  void changePasswordVisibility() {
    isPassword = !isPassword;
    emit(RegisterChangePasswordVisibility());
  }

  void changeConfirmPasswordVisibility() {
    isConfirmPassword = !isConfirmPassword;
    emit(RegisterChangeConfirmPasswordVisibility());
  }

  void toggleCheckbox(bool value) {
    isChecked = value;
    emit(RegisterToggleCheckbox());
  }

  void onRegister() {
    if (!formKey.currentState!.validate()) return;
    emit(RegisterLoading());
    Future.delayed(const Duration(seconds: 1), () {
      emit(RegisterSuccess(message: 'Account created successfully'));
    });
  }
}
