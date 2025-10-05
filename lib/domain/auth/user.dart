import 'package:equatable/equatable.dart';

/// User domain entity
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'avatar': avatar,
      'language': language,
      'bio': bio,
      'isActive': isActive,
      'isVerified': isVerified,
      'githubUrl': githubUrl,
      'linkedinUrl': linkedinUrl,
      'websiteUrl': websiteUrl,
      'youtubeUrl': youtubeUrl,
      'facebookUrl': facebookUrl,
      'instagramUrl': instagramUrl,
      'historyMatch': historyMatch,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      avatar: json['avatar'] as String?,
      language: json['language'] as String?,
      bio: json['bio'] as String?,
      isActive: json['isActive'] as bool,
      isVerified: json['isVerified'] as bool?,
      githubUrl: json['githubUrl'] as String?,
      linkedinUrl: json['linkedinUrl'] as String?,
      websiteUrl: json['websiteUrl'] as String?,
      youtubeUrl: json['youtubeUrl'] as String?,
      facebookUrl: json['facebookUrl'] as String?,
      instagramUrl: json['instagramUrl'] as String?,
      historyMatch: json['historyMatch'] as List<dynamic>?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}
