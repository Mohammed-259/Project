import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medication_reminder/features/auth/manager/signin/signin_states.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  static LoginCubit get(context) => BlocProvider.of(context);

  bool isPassword = true;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void changePasswordVisibility() {
    isPassword = !isPassword;
    emit(ChangePasswordVisibilityState());
  }

  void login(BuildContext context) {
    if (!formKey.currentState!.validate()) return;

    emit(LoginLoading());

    // ✅ تحقق بسيط بدون API
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email == "user@gmail.com" && password == "123456789") {
      emit(LoginSuccess());
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (_) => const HomeView()),
      // );
    } else {
      emit(LoginError("Invalid email or password"));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid email or password")),
      );
    }
  }
}
