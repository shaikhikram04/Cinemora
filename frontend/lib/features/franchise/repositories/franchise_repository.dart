import 'package:cinemora/core/network/api_client.dart';
import 'package:cinemora/features/franchise/models/franchise_detail.dart';
import 'package:cinemora/features/franchise/models/franchise_summary.dart';
import 'package:cinemora/core/constants/api_constants.dart';

class FranchiseRepository {
  final ApiClient _apiClient;

  FranchiseRepository(this._apiClient);

  Future<List<FranchiseSummary>> getFeatured() async {
    final res = await _apiClient.dio.get(ApiConstants.tmdbCollectionsFeatured);
    return (res.data as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map(FranchiseSummary.fromFeaturedJson)
        .toList();
  }

  Future<List<FranchiseSummary>> search(String query) async {
    final res = await _apiClient.dio.get(
      ApiConstants.tmdbCollectionSearch,
      queryParameters: {'q': query},
    );
    return (res.data['results'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map(FranchiseSummary.fromTmdbJson)
        .where((f) => f.posterPath != null && f.posterPath!.isNotEmpty)
        .toList();
  }

  Future<FranchiseDetail> getCollection(int id) async {
    final res = await _apiClient.dio.get(ApiConstants.tmdbCollection(id));
    return FranchiseDetail.fromJson(res.data as Map<String, dynamic>);
  }
}
