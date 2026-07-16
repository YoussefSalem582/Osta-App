import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/di/injection.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/features/shared/auth/presentation/register/bloc/register_bloc.dart';
import 'package:osta/features/shared/auth/presentation/register/widgets/register_form.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// Customer sign-up. Sends `account_type = customer`; success hands the
/// authoritative role to the session and the router leaves this screen.
///
/// Twin of [BusinessRegisterPage] — both render [RegisterForm], because the
/// backend accepts the same personal fields for either role.
class CustomerRegisterPage extends StatelessWidget {
  const CustomerRegisterPage({super.key});

  static const String path = AppRoutes.register;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RegisterBloc>(
      create: (_) => getIt<RegisterBloc>(),
      child: RegisterForm(title: context.l10n.authRegisterTitleCustomer),
    );
  }
}
