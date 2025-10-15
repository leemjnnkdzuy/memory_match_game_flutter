import 'battle_royale_player_model.dart';

enum RoomStatus { waiting, starting, inProgress, finished }

class BattleRoyaleRoom {
  final String id;
  final String name;
  final String code;
  final String? password;
  final int maxPlayers;
  final int currentPlayers;
  final String hostId;
  final int pairCount;
  final int softCapTime;
  final int? hardCapTime;
  final int flipLimit;
  final String? seed;
  final String region;
  final RoomStatus status;
  final List<BattleRoyalePlayer> players;
  final DateTime createdAt;
  final DateTime? startedAt;

  BattleRoyaleRoom({
    required this.id,
    required this.name,
    required this.code,
    this.password,
    this.maxPlayers = 8,
    this.currentPlayers = 0,
    required this.hostId,
    this.pairCount = 8,
    this.softCapTime = 120,
    this.hardCapTime,
    this.flipLimit = 2,
    this.seed,
    this.region = 'auto',
    this.status = RoomStatus.waiting,
    this.players = const [],
    required this.createdAt,
    this.startedAt,
  });

  factory BattleRoyaleRoom.fromJson(Map<String, dynamic> json) {
    return BattleRoyaleRoom(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? 'Room',
      code: json['code'] ?? '',
      password: json['password'],
      maxPlayers: json['maxPlayers'] ?? 8,
      currentPlayers: json['currentPlayers'] ?? 0,
      hostId: json['hostId'] ?? '',
      pairCount: json['pairCount'] ?? 8,
      softCapTime: json['softCapTime'] ?? 120,
      hardCapTime: json['hardCapTime'],
      flipLimit: json['flipLimit'] ?? 2,
      seed: json['seed'],
      region: json['region'] ?? 'auto',
      status: _parseStatus(json['status']),
      players:
          (json['players'] as List<dynamic>?)
              ?.map((p) => BattleRoyalePlayer.fromJson(p))
              .toList() ??
          [],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'])
          : null,
    );
  }

  static RoomStatus _parseStatus(dynamic status) {
    if (status == null) return RoomStatus.waiting;
    if (status is String) {
      switch (status.toLowerCase()) {
        case 'waiting':
          return RoomStatus.waiting;
        case 'starting':
          return RoomStatus.starting;
        case 'inprogress':
        case 'in_progress':
          return RoomStatus.inProgress;
        case 'finished':
          return RoomStatus.finished;
        default:
          return RoomStatus.waiting;
      }
    }
    return RoomStatus.waiting;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'password': password,
      'maxPlayers': maxPlayers,
      'currentPlayers': currentPlayers,
      'hostId': hostId,
      'pairCount': pairCount,
      'softCapTime': softCapTime,
      'hardCapTime': hardCapTime,
      'flipLimit': flipLimit,
      'seed': seed,
      'region': region,
      'status': status.name,
      'players': players.map((p) => p.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
    };
  }

  bool get isFull => currentPlayers >= maxPlayers;
  bool get hasPassword => password != null && password!.isNotEmpty;
  bool get canStart =>
      currentPlayers >= 2 &&
      players.where((p) => p.isReady || p.isHost).length >= 2;

  BattleRoyaleRoom copyWith({
    String? id,
    String? name,
    String? code,
    String? password,
    int? maxPlayers,
    int? currentPlayers,
    String? hostId,
    int? pairCount,
    int? softCapTime,
    int? hardCapTime,
    int? flipLimit,
    String? seed,
    String? region,
    RoomStatus? status,
    List<BattleRoyalePlayer>? players,
    DateTime? createdAt,
    DateTime? startedAt,
  }) {
    return BattleRoyaleRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      password: password ?? this.password,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      currentPlayers: currentPlayers ?? this.currentPlayers,
      hostId: hostId ?? this.hostId,
      pairCount: pairCount ?? this.pairCount,
      softCapTime: softCapTime ?? this.softCapTime,
      hardCapTime: hardCapTime ?? this.hardCapTime,
      flipLimit: flipLimit ?? this.flipLimit,
      seed: seed ?? this.seed,
      region: region ?? this.region,
      status: status ?? this.status,
      players: players ?? this.players,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
    );
  }
}
