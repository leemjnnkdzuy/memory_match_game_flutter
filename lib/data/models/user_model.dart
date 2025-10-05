import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? avatar;
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

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatar,
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

  String get fullName => '$firstName $lastName';

  bool get hasCompleteProfile {
    return avatar != null && bio != null && bio!.isNotEmpty;
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? avatar,
    String? language,
    String? bio,
    bool? isActive,
    bool? isVerified,
    String? githubUrl,
    String? linkedinUrl,
    String? websiteUrl,
    String? youtubeUrl,
    String? facebookUrl,
    String? instagramUrl,
    List<dynamic>? historyMatch,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatar: avatar ?? this.avatar,
      language: language ?? this.language,
      bio: bio ?? this.bio,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      githubUrl: githubUrl ?? this.githubUrl,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      historyMatch: historyMatch ?? this.historyMatch,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    firstName,
    lastName,
    avatar,
    language,
    bio,
    isActive,
    isVerified,
    githubUrl,
    linkedinUrl,
    websiteUrl,
    youtubeUrl,
    facebookUrl,
    instagramUrl,
    historyMatch,
    createdAt,
    updatedAt,
  ];

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
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
}
