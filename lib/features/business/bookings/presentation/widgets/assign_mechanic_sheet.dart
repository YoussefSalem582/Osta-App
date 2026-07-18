import 'package:flutter/material.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/team/data/model/mechanic.dart';
import 'package:osta/features/business/team/data/repo/mechanic_repo.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// A chosen assignment: [mechanicId] null means "unassign". A dismissed sheet
/// returns null (distinct from an explicit unassign).
class AssignMechanicResult {
  const AssignMechanicResult(this.mechanicId);

  final String? mechanicId;
}

/// Loads the center's roster (`GET /business/mechanics`) and lets the owner pick
/// one for a booking, or unassign. Returns null if dismissed.
Future<AssignMechanicResult?> showAssignMechanicSheet(BuildContext context) =>
    showModalBottomSheet<AssignMechanicResult>(
      context: context,
      showDragHandle: true,
      builder: (_) => const _AssignMechanicSheet(),
    );

class _AssignMechanicSheet extends StatefulWidget {
  const _AssignMechanicSheet();

  @override
  State<_AssignMechanicSheet> createState() => _AssignMechanicSheetState();
}

class _AssignMechanicSheetState extends State<_AssignMechanicSheet> {
  late Future<List<Mechanic>> _future;

  @override
  void initState() {
    super.initState();
    _future = MechanicRepo.index(active: true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.assignMechanicTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            FutureBuilder<List<Mechanic>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  final message = snapshot.error is ApiException
                      ? (snapshot.error! as ApiException).message
                      : l10n.assignMechanicError;
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  );
                }
                final mechanics = snapshot.data ?? const <Mechanic>[];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (mechanics.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          l10n.assignMechanicEmpty,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    else
                      ...mechanics.map(
                        (m) => ListTile(
                          leading: const Icon(Icons.build_circle_outlined),
                          title: Text(m.name),
                          subtitle: m.specialty.isEmpty
                              ? null
                              : Text(m.specialty),
                          onTap: () => Navigator.of(context).pop(
                            AssignMechanicResult(m.id.toString()),
                          ),
                        ),
                      ),
                    ListTile(
                      leading: Icon(
                        Icons.person_off_outlined,
                        color: theme.colorScheme.error,
                      ),
                      title: Text(l10n.assignMechanicUnassign),
                      onTap: () => Navigator.of(
                        context,
                      ).pop(const AssignMechanicResult(null)),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
