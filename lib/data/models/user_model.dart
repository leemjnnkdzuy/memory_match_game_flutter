import '../../domain/auth/user.dart';

class UserModel {
  final String id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String avatar;
  final String? language;
  final String? bio;
  final bool isActive;
  final bool? isVerified;
  final String? githubUrl;
  final String? linkedinUrl;
  final String? websiteUrl;
  final String? youtubeUrl;
  final String? facebookUrl;
  final String? instagramUrl;
  final List<dynamic>? historyMatch;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.avatar,
    this.language,
    this.bio,
    required this.isActive,
    this.isVerified,
    this.githubUrl,
    this.linkedinUrl,
    this.websiteUrl,
    this.youtubeUrl,
    this.facebookUrl,
    this.instagramUrl,
    this.historyMatch,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      avatar: json['avatar'],
      language: json['language'],
      bio: json['bio'],
      isActive: json['is_active'] ?? true,
      isVerified: json['isVerified'],
      githubUrl: json['github_url'],
      linkedinUrl: json['linkedin_url'],
      websiteUrl: json['website_url'],
      youtubeUrl: json['youtube_url'],
      facebookUrl: json['facebook_url'],
      instagramUrl: json['instagram_url'],
      historyMatch: json['history_match'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'avatar': avatar,
      'language': language,
      'bio': bio,
      'is_active': isActive,
      'isVerified': isVerified,
      'github_url': githubUrl,
      'linkedin_url': linkedinUrl,
      'website_url': websiteUrl,
      'youtube_url': youtubeUrl,
      'facebook_url': facebookUrl,
      'instagram_url': instagramUrl,
      'history_match': historyMatch,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  User toEntity() {
    return User(
      id: id,
      username: username,
      email: email,
      firstName: firstName,
      lastName: lastName,
      avatar: avatar,
      language: language,
      bio: bio,
      isActive: isActive,
      isVerified: isVerified,
      githubUrl: githubUrl,
      linkedinUrl: linkedinUrl,
      websiteUrl: websiteUrl,
      youtubeUrl: youtubeUrl,
      facebookUrl: facebookUrl,
      instagramUrl: instagramUrl,
      historyMatch: historyMatch,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
