import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String username;
  final String email;
  final String? bio;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'followers_count')
  final int followersCount;
  @JsonKey(name: 'following_count')
  final int followingCount;
  final bool isFollowing;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.bio,
    this.avatarUrl,
    required this.createdAt,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isFollowing = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle counts from Supabase count aggregation if available
    // Note: This logic might need adjustment based on exact query structure
    return _$UserModelFromJson(json);
  }

  UserModel copyWith({
    String? username,
    String? bio,
    String? avatarUrl,
    int? followersCount,
    int? followingCount,
    bool? isFollowing,
  }) {
    return UserModel(
      id: id,
      username: username ?? this.username,
      email: email,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
