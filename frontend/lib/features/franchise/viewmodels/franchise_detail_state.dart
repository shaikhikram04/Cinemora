import 'package:equatable/equatable.dart';
import 'package:cinemora/features/franchise/models/franchise_detail.dart';

enum FranchiseDetailStatus { loading, success, failure }

class FranchiseDetailState extends Equatable {
  final FranchiseDetailStatus status;
  final FranchiseDetail? detail;
  final bool isBulkAdding;

  const FranchiseDetailState({
    this.status = FranchiseDetailStatus.loading,
    this.detail,
    this.isBulkAdding = false,
  });

  FranchiseDetailState copyWith({
    FranchiseDetailStatus? status,
    FranchiseDetail? detail,
    bool? isBulkAdding,
  }) {
    return FranchiseDetailState(
      status: status ?? this.status,
      detail: detail ?? this.detail,
      isBulkAdding: isBulkAdding ?? this.isBulkAdding,
    );
  }

  @override
  List<Object?> get props => [status, detail, isBulkAdding];
}
