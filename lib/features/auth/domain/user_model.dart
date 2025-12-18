import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String username;
  @JsonKey(name: 'full_name')
  final String? fullName;
  final String? email; // Made nullable
  final String? bio;
  final String? website;
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
    this.fullName,
    this.email, // Optional
    this.bio,
    this.website,
    this.avatarUrl,
    required this.createdAt,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isFollowing = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return _$UserModelFromJson(json);
  }

  UserModel copyWith({
    String? username,
    String? fullName,
    String? email,
    String? bio,
    String? website,
    String? avatarUrl,
    int? followersCount,
    int? followingCount,
    bool? isFollowing,
  }) {
    return UserModel(
      id: id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      website: website ?? this.website,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
