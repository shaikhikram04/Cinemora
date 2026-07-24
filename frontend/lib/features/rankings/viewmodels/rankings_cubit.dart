import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemora/core/network/api_client.dart';
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
      // A failed read leaves whatever is already on screen — no message, since
      // the list the user is looking at is still the last good one.
    }
  }

  void clear() => emit(const RankingsState(lists: []));

  void clearMutationError() => emit(state.copyWith(clearMutationError: true));

  /// Undoes an optimistic change the server never accepted and says why.
  /// Without this the UI kept showing a reorder or deletion that only ever
  /// existed on the device.
  void _revert(List<RankingList> previous, Object error) {
    emit(state.copyWith(
      lists: previous,
      mutationError: ApiClient.parseError(error).userMessage,
    ));
  }

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
    } catch (e) {
      emit(state.copyWith(
        mutationError: ApiClient.parseError(e).userMessage,
      ));
      return null;
    }
  }

  /// Called after placement battle — replaces the list's entries via API.
  Future<void> updateListEntries(
      String listId, List<RankingEntry> entries) async {
    final previous = state.lists;
    // Optimistic update
    _replaceEntries(listId, entries);
    try {
      final updated = await _repo.reorderEntries(listId, entries);
      _replaceListInState(updated);
    } catch (e) {
      _revert(previous, e);
    }
  }

  /// Called by drag-to-reorder in the detail view.
  void reorderEntries(String listId, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final previous = state.lists;
    final list = state.lists
        .firstWhere((l) => l.id == listId, orElse: () => state.lists.first);
    final entries = List<RankingEntry>.of(list.entries);
    final item = entries.removeAt(oldIndex);
    entries.insert(newIndex, item);
    _replaceEntries(listId, entries);
    _repo
        .reorderEntries(listId, entries)
        .then(_replaceListInState)
        .catchError((Object e) => _revert(previous, e));
  }

  Future<void> deleteList(String listId) async {
    final previous = state.lists;
    emit(state.copyWith(
      lists: state.lists.where((l) => l.id != listId).toList(),
    ));
    try {
      await _repo.deleteList(listId);
    } catch (e) {
      _revert(previous, e);
    }
  }

  void removeEntry(String listId, int index) {
    final previous = state.lists;
    final list = state.lists
        .firstWhere((l) => l.id == listId, orElse: () => state.lists.first);
    final entries = List<RankingEntry>.of(list.entries)..removeAt(index);
    _replaceEntries(listId, entries);
    _repo
        .reorderEntries(listId, entries)
        .then(_replaceListInState)
        .catchError((Object e) => _revert(previous, e));
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
        images: entries
            .take(3)
            .map((e) => e.image)
            .where((i) => i.isNotEmpty)
            .toList(),
        entries: entries,
      );
    }).toList();
    emit(state.copyWith(lists: updated));
  }

  void _replaceListInState(RankingList updated) {
    final lists =
        state.lists.map((l) => l.id == updated.id ? updated : l).toList();
    emit(state.copyWith(lists: lists));
  }
}
