import 'package:equatable/equatable.dart';

// Favorite era used to live here as a hand-picked string. It's now derived from
// the user's library instead — see core/utils/era_insight.dart.
class UserPreferences extends Equatable {
  final List<String> contentTypes;
  final List<String> genres;
  final List<String> languages;

  const UserPreferences({
    this.contentTypes = const [],
    this.genres = const [],
    this.languages = const [],
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      contentTypes: List<String>.from(json['contentTypes'] as List? ?? []),
      genres: List<String>.from(json['genres'] as List? ?? []),
      languages: List<String>.from(json['languages'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'contentTypes': contentTypes,
        'genres': genres,
        'languages': languages,
      };

  UserPreferences copyWith({
    List<String>? contentTypes,
    List<String>? genres,
    List<String>? languages,
  }) {
    return UserPreferences(
      contentTypes: contentTypes ?? this.contentTypes,
      genres: genres ?? this.genres,
      languages: languages ?? this.languages,
    );
  }

  @override
  List<Object?> get props => [contentTypes, genres, languages];
}

class UserModel extends Equatable {
  final String id;
  final String name;
  final String? username;
  final String? bio;
  final String email;
  final String? avatar;
  final String? framePoster;
  final bool isOnboarded;
  final UserPreferences preferences;

  const UserModel({
    required this.id,
    required this.name,
    this.username,
    this.bio,
    required this.email,
    this.avatar,
    this.framePoster,
    required this.isOnboarded,
    this.preferences = const UserPreferences(),
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['_id']).toString(),
      name: json['name'] as String,
      username: json['username'] as String?,
      bio: json['bio'] as String?,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
      framePoster: json['framePoster'] as String?,
      isOnboarded: (json['isOnboarded'] as bool?) ?? false,
      preferences: json['preferences'] != null
          ? UserPreferences.fromJson(
              json['preferences'] as Map<String, dynamic>)
          : const UserPreferences(),
    );
  }

  /// Round-trips through [UserModel.fromJson] — used to cache the signed-in
  /// user so a launch with no network can still restore an identity.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'username': username,
        'bio': bio,
        'email': email,
        'avatar': avatar,
        'framePoster': framePoster,
        'isOnboarded': isOnboarded,
        'preferences': preferences.toJson(),
      };

  UserModel copyWith({
    String? id,
    String? name,
    String? username,
    String? bio,
    String? email,
    String? avatar,
    String? framePoster,
    bool? isOnboarded,
    UserPreferences? preferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      framePoster: framePoster ?? this.framePoster,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      preferences: preferences ?? this.preferences,
    );
  }

  String get displayUsername =>
      username ?? name.toLowerCase().replaceAll(' ', '_');

  @override
  List<Object?> get props => [
        id,
        name,
        username,
        bio,
        email,
        avatar,
        framePoster,
        isOnboarded,
        preferences
      ];
}
