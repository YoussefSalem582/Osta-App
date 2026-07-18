import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/shared/profile/data/model/address.dart';
import 'package:osta/features/shared/profile/presentation/bloc/address_bloc.dart';
import 'package:osta/features/shared/profile/presentation/pages/address_form_screen.dart';
import 'package:osta/features/shared/profile/presentation/widgets/address_card.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_confirm_dialog.dart';
import 'package:osta/shared/ui/app_toaster.dart';
import 'package:osta/shared/ui/app_top_bar.dart';
import 'package:osta/shared/ui/status_states.dart';

/// Address book (`/me/addresses`) — list + add / edit / delete. Reached from the
/// "Addresses" row on the profile/More tab.
class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => AddressBloc()..add(const AddressLoadRequested()),
    child: const _AddressesView(),
  );
}

class _AddressesView extends StatefulWidget {
  const _AddressesView();

  @override
  State<_AddressesView> createState() => _AddressesViewState();
}

class _AddressesViewState extends State<_AddressesView> {
  List<Address> _items = [];

  Future<void> _openForm(BuildContext context, {Address? address}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddressFormScreen(address: address)),
    );
    if (saved == true && context.mounted) {
      context.read<AddressBloc>().add(const AddressLoadRequested());
    }
  }

  Future<void> _confirmDelete(BuildContext context, Address address) async {
    final l10n = context.l10n;
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: l10n.deleteAddressDialogTitle,
      message: l10n.deleteAddressDialogMessage,
      cancelLabel: l10n.cancel,
      confirmLabel: l10n.delete,
      isDestructive: true,
    );
    if (confirmed != true || !context.mounted) return;
    context.read<AddressBloc>().add(AddressDeleteRequested(address.id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppTopBar(centerTitle: false, title: l10n.addresses),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.addAddress),
      ),
      body: BlocConsumer<AddressBloc, AddressState>(
        listener: (context, state) {
          if (state is AddressLoaded) {
            setState(() => _items = state.items);
          } else if (state is AddressDeleteSuccess) {
            AppToaster.showMessage(l10n.addressDeleted);
            context.read<AddressBloc>().add(const AddressLoadRequested());
          } else if (state is AddressDeleteError) {
            AppToaster.showError(state.message);
          }
        },
        builder: (context, state) {
          final busy = state is AddressDeleteLoading;
          return Stack(
            children: [
              _body(context, state),
              if (busy)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black12,
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _body(BuildContext context, AddressState state) {
    final l10n = context.l10n;
    if (state is AddressLoading || state is AddressInitial) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (state is AddressError) {
      return ErrorState(
        title: l10n.addressesErrorTitle,
        message: state.message,
        onRetry: () =>
            context.read<AddressBloc>().add(const AddressLoadRequested()),
      );
    }
    if (_items.isEmpty) {
      return EmptyState(
        icon: Icons.location_on_outlined,
        title: l10n.addressesEmptyTitle,
        message: l10n.addressesEmptyMessage,
      );
    }
    return RefreshIndicator.adaptive(
      onRefresh: () async {
        final bloc = context.read<AddressBloc>()
          ..add(const AddressLoadRequested());
        // Keep the pull-to-refresh spinner up until the reload settles.
        await bloc.stream.firstWhere(
          (s) => s is AddressLoaded || s is AddressError,
        );
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final address = _items[index];
          return AddressCard(
            address: address,
            onTap: () => _openForm(context, address: address),
            onDelete: () => _confirmDelete(context, address),
          );
        },
      ),
    );
  }
}
