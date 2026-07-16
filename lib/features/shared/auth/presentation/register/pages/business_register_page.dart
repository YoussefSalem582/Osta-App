import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/di/injection.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/features/shared/auth/presentation/register/bloc/register_bloc.dart';
import 'package:osta/features/shared/auth/presentation/register/widgets/register_form.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// Business sign-up. Sends `account_type = business`; success hands the
/// authoritative role to the session and the router sends the new merchant into
/// the setup wizard (`features/business/onboarding/`).
///
/// This collects the **person**, not the business. Trade name, address, logo and
/// map pin are gathered after auth, because `POST /auth/register` accepts only
/// personal fields and `PUT /business/profile` sits behind `auth:sanctum` — the
/// business half physically needs a token first.
///
/// Twin of [CustomerRegisterPage]; both render [RegisterForm]. They exist apart
/// so the two signups can diverge without a role flag inside the form.
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
