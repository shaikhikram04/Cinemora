import 'package:cinemora/core/exceptions/app_exception.dart';
import 'package:cinemora/core/network/api_client.dart';
import 'package:cinemora/features/rankings/models/ranking_item.dart';

class RankingsRepository {
  final ApiClient _apiClient;

  RankingsRepository(this._apiClient);

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
