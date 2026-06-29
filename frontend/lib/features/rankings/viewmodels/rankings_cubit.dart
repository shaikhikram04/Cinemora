import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cinemora/features/rankings/models/ranking_item.dart';
import 'rankings_state.dart';

class RankingsCubit extends Cubit<RankingsState> {
  static const _prefsKey = 'ranking_lists_v1';

  RankingsCubit() : super(const RankingsState(lists: [])) {
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final lists = decoded
          .map((e) => RankingList.fromJson(e as Map<String, dynamic>))
          .toList();
      emit(state.copyWith(lists: lists));
    } catch (_) {
      // corrupted data — start fresh
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode(state.lists.map((l) => l.toJson()).toList()),
    );
  }

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

  void createList({
    required String emoji,
    required String title,
    String subtitle = '',
  }) {
    if (title.trim().isEmpty) return;
    final newList = RankingList(
      emoji: emoji,
      title: title.trim(),
      subtitle: subtitle.trim(),
      count: 0,
      accent: _nextAccent,
      images: [],
      entries: [],
    );
    emit(state.copyWith(lists: [...state.lists, newList]));
    _save();
  }

  // Called after placement battle completes — replaces the list's entries
  void updateListEntries(String listTitle, List<RankingEntry> entries) {
    final updated = state.lists.map((list) {
      if (list.title != listTitle) return list;
      return RankingList(
        emoji: list.emoji,
        title: list.title,
        subtitle: list.subtitle,
        count: entries.length,
        accent: list.accent,
        images: entries.take(3).map((e) => e.image).toList(),
        entries: entries,
      );
    }).toList();
    emit(state.copyWith(lists: updated));
    _save();
  }

  // Called by drag-to-reorder in the detail view
  void reorderEntries(String listTitle, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final updated = state.lists.map((list) {
      if (list.title != listTitle) return list;
      final entries = List<RankingEntry>.of(list.entries);
      final item = entries.removeAt(oldIndex);
      entries.insert(newIndex, item);
      return RankingList(
        emoji: list.emoji,
        title: list.title,
        subtitle: list.subtitle,
        count: entries.length,
        accent: list.accent,
        images: entries.take(3).map((e) => e.image).toList(),
        entries: entries,
      );
    }).toList();
    emit(state.copyWith(lists: updated));
    _save();
  }

  void deleteList(String listTitle) {
    emit(state.copyWith(
      lists: state.lists.where((l) => l.title != listTitle).toList(),
    ));
    _save();
  }
}
