---
description: "BLoC/Cubit event/state conventions"
globs: "lib/features/**/presentation/**/*.dart"
alwaysApply: false
---

# BLoC / Cubit Conventions

State management for feature presentation layers. Stack: `bloc` / `flutter_bloc` 9.x + `equatable`. No codegen — states and events are hand-written `Equatable` classes.

## Bloc vs Cubit

| Use | When | Example |
|-----|------|---------|
| **Bloc** | Feature flows with discrete events (submit, load, refresh, paginate) | auth login/register, list fetch |
| **Cubit** | Simple state with direct method calls, no event stream | `ThemeModeController` (`lib/core/theme/theme_mode_controller.dart`) |

Default to **Bloc** for a feature; reach for a Cubit only when there are no meaningful "events", just setters.

## File layout

One class per file, colocated under the feature's `presentation/`:

```text
lib/features/<feature>/presentation/bloc/
  <feature>_bloc.dart
  <feature>_event.dart    // sealed base + event subclasses
  <feature>_state.dart    // sealed base + state subclasses
```

- Events and states live in **separate files** from the bloc.
- Every event and every state **extends `Equatable`** with a `props` list.
- Cubits skip events entirely (just methods + `emit`).

## State set

Model each flow's states as a small closed set:

| State | Holds |
|-------|-------|
| `Initial` | nothing (pre-load) |
| `Loading` | nothing (in flight) |
| `Loaded` | the `data` |
| `Error` | the `message` (from `Failure.message`) |

Prefer a `sealed` base state so `switch` in the UI is exhaustive. `props` must include every field (e.g. `Loaded.props => [data]`, `Error.props => [message]`).

## Handler pattern — try/catch, NOT fold

Repositories **throw** a `sealed Failure` (`lib/core/error/failure.dart`); the bloc catches it with plain `try`/`catch`. There is **no `Either`, no `Result<T>`, no `.fold()`**.

```dart
Future<void> _onSubmit(SubmitEvent event, Emitter<XState> emit) async {
  emit(const XLoading());
  try {
    final data = await useCase(event.params);
    emit(XLoaded(data));
  } on Failure catch (f) {
    emit(XError(f.message)); // Failure carries a user-facing .message
  }
}
```

- Catch `on Failure` — repositories convert typed `ApiException`s into a `Failure` before they reach the bloc.
- Push `f.message` straight into the `Error` state; the UI shows it (localize the surface via `context.l10n` where a fixed copy is expected).
- Register handlers in the constructor: `on<SubmitEvent>(_onSubmit);`.

## Widget wiring

| Widget | Use for |
|--------|---------|
| `BlocBuilder` | rebuild UI from state (map `Loading`/`Loaded`/`Error` to widgets) |
| `BlocListener` | one-off side effects (navigate on `Loaded`, `SnackBar` on `Error`) |
| `BlocConsumer` | both in one place |

- Provide blocs via `BlocProvider` at the page root; resolve dependencies from `getIt` (manual DI). Register the bloc with `registerFactory` in `configureDependencies()` (`lib/core/di/injection.dart`).
- Use `buildWhen` / `listenWhen` to avoid redundant rebuilds when a state set is large.

## Don't

- No `fpdart` / `Either` / `Result<T>` / `.fold()` — try/catch only.
- No `freezed` / `json_serializable` for states — hand-written `Equatable`.
- No business logic or Dio calls in the bloc — go through a repository/use case, which goes through `ApiClient`.

See [`docs/ROADMAP.md`](../../docs/ROADMAP.md) for the deferred-tooling plan (fpdart / freezed are phased, not rejected).
