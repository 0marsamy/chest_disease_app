import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/login_screen_widget.dart';
import '../../view_model/login_cubit.dart';

// ✅ الحل: استخدام مسار package الكامل عشان يوصل للملف صح أياً كان مكانه
import 'package:chest_disease_app/core/services/service_locator/service_locator.dart'; 

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // ⚠️ تأكد أن المتغير في ملف dependency_injection اسمه getIt
      // لو كان اسمه sl أو locator غير الكلمة دي للي عندك
      create: (context) => getIt<LoginCubit>(),
      child: const Scaffold(
        body: SafeArea(child: LoginScreenWidget()),
      ),
    );
  }
}