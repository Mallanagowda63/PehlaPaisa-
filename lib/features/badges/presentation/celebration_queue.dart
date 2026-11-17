import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/celebration.dart';

class CelebrationQueueState {
  const CelebrationQueueState({this.items = const [], this.paused = false});

  final List<Celebration> items;

  /// While true (e.g. during the salary-day pour) nothing is shown.
  final bool paused;

  Celebration? get next => paused || items.isEmpty ? null : items.first;
}

/// FIFO of pending celebrations shown one at a time by `CelebrationHost`.
class CelebrationQueue extends Notifier<CelebrationQueueState> {
  @override
  CelebrationQueueState build() => const CelebrationQueueState();

  void push(Celebration c) {
    if (!ref.mounted) return;
    state = CelebrationQueueState(
      items: [...state.items, c],
      paused: state.paused,
    );
  }

  void pop() {
    if (!ref.mounted || state.items.isEmpty) return;
    state = CelebrationQueueState(
      items: state.items.sublist(1),
      paused: state.paused,
    );
  }

  // Pause/resume may run from a microtask after a screen is disposed, so
  // every mutation checks that the provider is still alive.
  void pause() {
    if (ref.mounted) {
      state = CelebrationQueueState(items: state.items, paused: true);
    }
  }

  void resume() {
    if (ref.mounted) {
      state = CelebrationQueueState(items: state.items, paused: false);
    }
  }

  void clear() {
    if (ref.mounted) state = const CelebrationQueueState();
  }
}

final celebrationQueueProvider =
    NotifierProvider<CelebrationQueue, CelebrationQueueState>(
      CelebrationQueue.new,
    );
