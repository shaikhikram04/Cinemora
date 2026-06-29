import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemora/features/rankings/models/ranking_item.dart';
import 'package:cinemora/features/rankings/repositories/rankings_repository.dart';
import 'rankings_state.dart';

class RankingsCubit extends Cubit<RankingsState> {
  final RankingsRepository _repo;

  RankingsCubit(this._repo) : super(const RankingsState(lists: []));

  static const _accentPalette = [
    Color(0xFFE84B57),
    Color(0xFF6077FA),
    Color(0xFFA78BFA),
    Color(0xFF00D9A3),
    Color(0xFFE0A838),
    Color(0xFFEB4B6B),
    Color(0xFFA94EF2),
    Color(0xFF60A5FA),
  ];

  Color get _nextAccent =>
      _accentPalette[state.lists.length % _accentPalette.length];

  Future<void> loadLists() async {
    try {
      final lists = await _repo.fetchLists();
      emit(state.copyWith(lists: lists));
    } catch (_) {
      // keep whatever is already in state
    }
  }

  void clear() => emit(const RankingsState(lists: []));

  /// Creates a list on the backend and returns it (with its id).
  Future<RankingList?> createList({
    required String emoji,
    required String title,
    String subtitle = '',
  }) async {
    if (title.trim().isEmpty) return null;
    final accent = _nextAccent;
    final accentHex =
        '#${(accent.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
    try {
      final created = await _repo.createList(
        emoji: emoji,
        title: title.trim(),
        subtitle: subtitle.trim(),
        accentHex: accentHex,
      );
      emit(state.copyWith(lists: [...state.lists, created]));
      return created;
    } catch (_) {
      return null;
    }
  }

  /// Called after placement battle — replaces the list's entries via API.
  Future<void> updateListEntries(
      String listId, List<RankingEntry> entries) async {
    // Optimistic update
    _replaceEntries(listId, entries);
    try {
      final updated = await _repo.reorderEntries(listId, entries);
      _replaceListInState(updated);
    } catch (_) {
      // keep optimistic state on failure
    }
  }

  /// Called by drag-to-reorder in the detail view.
  void reorderEntries(String listId, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final list = state.lists.firstWhere((l) => l.id == listId,
        orElse: () => state.lists.first);
    final entries = List<RankingEntry>.of(list.entries);
    final item = entries.removeAt(oldIndex);
    entries.insert(newIndex, item);
    _replaceEntries(listId, entries);
    // fire-and-forget sync
    _repo.reorderEntries(listId, entries).then(_replaceListInState).catchError((_) {});
  }

  Future<void> deleteList(String listId) async {
    emit(state.copyWith(
      lists: state.lists.where((l) => l.id != listId).toList(),
    ));
    try {
      await _repo.deleteList(listId);
    } catch (_) {
      // optimistic — ignore failure
    }
  }

  // ── helpers ─────────────────────────────────────────────────────────────────

  void _replaceEntries(String listId, List<RankingEntry> entries) {
    final updated = state.lists.map((list) {
      if (list.id != listId) return list;
      return RankingList(
        id: list.id,
        emoji: list.emoji,
        title: list.title,
        subtitle: list.subtitle,
        count: entries.length,
        accent: list.accent,
        images:
            entries.take(3).map((e) => e.image).where((i) => i.isNotEmpty).toList(),
        entries: entries,
      );
    }).toList();
    emit(state.copyWith(lists: updated));
  }

  void _replaceListInState(RankingList updated) {
    final lists = state.lists.map((l) => l.id == updated.id ? updated : l).toList();
    emit(state.copyWith(lists: lists));
  }
}
