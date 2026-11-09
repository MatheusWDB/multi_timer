class PresetEntity {
  final int? id;
  final String name;
  final int durationSeconds;
  final int color;
  final String soundId;
  final DateTime createdAt;
  final int position;

  const PresetEntity({
    this.id,
    required this.name,
    required this.durationSeconds,
    required this.color,
    required this.soundId,
    required this.createdAt,
    required this.position,
  });

  PresetEntity copyWith({
    int? id,
    String? name,
    int? durationSeconds,
    int? color,
    String? soundId,
    int? position,
  }) {
    return PresetEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      color: color ?? this.color,
      soundId: soundId ?? this.soundId,
      createdAt: createdAt,
      position: position ?? this.position,
    );
  }
}
