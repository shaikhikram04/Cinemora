import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemora/features/franchise/repositories/franchise_repository.dart';
import 'franchise_list_state.dart';

class FranchiseListCubit extends Cubit<FranchiseListState> {
  final FranchiseRepository _repo;
  Timer? _debounce;
  int _searchGen = 0;

  FranchiseListCubit(this._repo) : super(const FranchiseListState()) {
    _loadFeatured();
  }

  Future<void> _loadFeatured() async {
    emit(state.copyWith(featuredStatus: FranchiseStatus.loading));
    try {
      final results = await _repo.getFeatured();
      emit(state.copyWith(
        featuredStatus:
            results.isEmpty ? FranchiseStatus.empty : FranchiseStatus.success,
        featured: results,
      ));
    } catch (e) {
      emit(state.copyWith(featuredStatus: FranchiseStatus.failure));
    }
  }

  void retryFeatured() => _loadFeatured();

  void onSearchChanged(String query) {
    _debounce?.cancel();
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      emit(state.copyWith(
        viewMode: FranchiseViewMode.featured,
        searchQuery: '',
        searchStatus: FranchiseStatus.idle,
        searchResults: [],
        clearError: true,
      ));
      return;
    }

    emit(state.copyWith(
      viewMode: FranchiseViewMode.searchActive,
      searchQuery: trimmed,
    ));

    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (isClosed) return;
      emit(state.copyWith(searchStatus: FranchiseStatus.loading));
      _doSearch(trimmed);
    });
  }

  void clearSearch() {
    _debounce?.cancel();
    emit(state.copyWith(
      viewMode: FranchiseViewMode.featured,
      searchQuery: '',
      searchStatus: FranchiseStatus.idle,
      searchResults: [],
      clearError: true,
    ));
  }

  void retrySearch() {
    if (state.searchQuery.isNotEmpty) _doSearch(state.searchQuery);
  }

  Future<void> _doSearch(String query) async {
    final gen = ++_searchGen;
    try {
      final results = await _repo.search(query);
      if (isClosed || gen != _searchGen) return;
      emit(state.copyWith(
        searchStatus:
            results.isEmpty ? FranchiseStatus.empty : FranchiseStatus.success,
        searchResults: results,
        clearError: true,
      ));
    } catch (e) {
      if (isClosed || gen != _searchGen) return;
      emit(state.copyWith(
        searchStatus: FranchiseStatus.failure,
        errorMessage: 'Something went wrong. Tap to retry.',
      ));
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
