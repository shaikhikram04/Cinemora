import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String? framePoster;
  final bool isOnboarded;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.framePoster,
    required this.isOnboarded,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['_id']) as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
      framePoster: json['framePoster'] as String?,
      isOnboarded: (json['isOnboarded'] as bool?) ?? false,
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    String? framePoster,
    bool? isOnboarded,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      framePoster: framePoster ?? this.framePoster,
      isOnboarded: isOnboarded ?? this.isOnboarded,
    );
  }

  @override
  List<Object?> get props => [id, name, email, avatar, framePoster, isOnboarded];
}
