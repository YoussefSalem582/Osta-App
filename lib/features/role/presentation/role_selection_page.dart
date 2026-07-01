import 'package:flutter/material.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// First-run screen: pick the customer or business flow.
///
/// Buttons are stubs — role routing is wired in a later navigation epic.
class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  static const path = '/role';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.chooseRole,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {},
                child: Text(l10n.roleCustomer),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {},
                child: Text(l10n.roleBusiness),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
