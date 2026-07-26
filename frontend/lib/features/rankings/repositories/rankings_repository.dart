import 'package:cinemora/core/exceptions/app_exception.dart';
import 'package:cinemora/core/network/api_client.dart';
import 'package:cinemora/features/rankings/models/ranking_item.dart';
import 'package:cinemora/features/tour/tour_mode.dart';
import 'package:flutter/painting.dart';

class RankingsRepository {
  final ApiClient _apiClient;

  /// While the first-run tour is running, list creation and entry writes are
  /// answered from memory instead of the network — see [TourMode]. The tour
  /// creates a list and drops one title into it purely to demonstrate the
  /// flow; persisting that would hand the user a ranking they never made.
  final TourMode _tourMode;

  RankingsRepository(this._apiClient, this._tourMode);

  /// Marked id, so nothing downstream can mistake this for a saved list — and
  /// so a stray API call built from it would fail loudly rather than mutate a
  /// real one.
  static String _localListId(String title) =>
      'tour-local-${title.toLowerCase().replaceAll(RegExp(r'\s+'), '-')}';

  Future<List<RankingList>> fetchLists() async {
    try {
      final res = await _apiClient.dio.get('/rankings');
      final list = res.data as List;
      return list
          .map((e) => RankingList.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ApiClient.parseError(e);
    }
  }

  Future<RankingList> createList({
    required String emoji,
    required String title,
    required String subtitle,
    required String accentHex,
  }) async {
    if (_tourMode.isActive) {
      return RankingList(
        id: _localListId(title),
        emoji: emoji,
        title: title,
        subtitle: subtitle,
        count: 0,
        accent: Color(int.parse(accentHex.substring(1), radix: 16) | 0xFF000000),
        images: const [],
        entries: const [],
      );
    }
    try {
      final res = await _apiClient.dio.post('/rankings', data: {
        'emoji': emoji,
        'title': title,
        'description': subtitle,
        'accentColor': accentHex,
      });
      return RankingList.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.parseError(e);
    }
  }

  Future<RankingList> reorderEntries(
    String listId,
    List<RankingEntry> entries,
  ) async {
    // No network, and no usable return either — this can't rebuild the list's
    // emoji, title or accent from a listId. RankingsCubit keeps its optimistic
    // copy in tour mode instead of replacing it with this.
    if (_tourMode.isActive) {
      return RankingList(
        id: listId,
        emoji: '',
        title: '',
        subtitle: '',
        count: entries.length,
        accent: const Color(0xFFE84B57),
        images: const [],
        entries: entries,
      );
    }
    try {
      final res = await _apiClient.dio.put(
        '/rankings/$listId/entries',
        data: {'entries': entries.map((e) => e.toJson()).toList()},
      );
      return RankingList.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.parseError(e);
    }
  }

  Future<void> deleteList(String listId) async {
    if (_tourMode.isActive) return;
    try {
      await _apiClient.dio.delete('/rankings/$listId');
    } catch (e) {
      final err = ApiClient.parseError(e);
      if (err is BackendException && err.code == 'RANKING_LIST_NOT_FOUND') {
        return;
      }
      throw err;
    }
  }
}
