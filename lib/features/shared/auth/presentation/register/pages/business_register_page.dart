import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/di/injection.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/features/shared/auth/presentation/register/bloc/register_bloc.dart';
import 'package:osta/features/shared/auth/presentation/register/widgets/register_form.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// Business sign-up (`account_type = business`); routes into the onboarding
/// wizard on success. Collects only personal fields — business details need
/// an authenticated `PUT /business/profile` call after this. Twin of
/// [CustomerRegisterPage], kept separate so the two can diverge.
class BusinessRegisterPage extends StatelessWidget {
  const BusinessRegisterPage({super.key});

  static const String path = AppRoutes.registerBusiness;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RegisterBloc>(
      create: (_) => getIt<RegisterBloc>(),
      child: RegisterForm(title: context.l10n.authRegisterTitleBusiness),
    );
  }
}
