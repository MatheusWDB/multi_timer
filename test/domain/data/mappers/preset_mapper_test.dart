import 'package:flutter_test/flutter_test.dart';
import 'package:multi_timer/core/constants/db_constants.dart';
import 'package:multi_timer/data/mappers/preset_mapper.dart';
import 'package:multi_timer/domain/entities/preset.dart';

void main() {
  final createdAt = DateTime(2026, 1, 1, 12, 0, 0);

  PresetEntity buildPreset({int? id}) {
    return PresetEntity(
      id: id,
      name: 'Ovo cozido',
      durationSeconds: 480,
      color: 0xFFFFC107,
      soundId: 'default',
      createdAt: createdAt,
      position: 4,
    );
  }

  void expectSamePreset(PresetEntity actual, PresetEntity expected) {
    expect(actual.id, expected.id);
    expect(actual.name, expected.name);
    expect(actual.durationSeconds, expected.durationSeconds);
    expect(actual.color, expected.color);
    expect(actual.soundId, expected.soundId);
    expect(actual.createdAt, expected.createdAt);
    expect(actual.position, expected.position);
  }

  group('PresetMapper.toMap', () {
    test('sem id não inclui a coluna id e converte os tipos', () {
      final map = PresetMapper.toMap(buildPreset());

      expect(map.containsKey(DbConstants.colId), isFalse);
      expect(map[DbConstants.colName], 'Ovo cozido');
      expect(map[DbConstants.colDurationSeconds], 480);
      expect(map[DbConstants.colColor], 0xFFFFC107);
      expect(map[DbConstants.colSoundId], 'default');
      expect(map[DbConstants.colCreatedAt], createdAt.millisecondsSinceEpoch);
      expect(map[DbConstants.colPosition], 4);
    });

    test('com id inclui a coluna id', () {
      final map = PresetMapper.toMap(buildPreset(id: 7));

      expect(map[DbConstants.colId], 7);
    });
  });

  group('PresetMapper.fromMap', () {
    test('converte um registro completo em PresetEntity', () {
      final map = <String, Object?>{
        DbConstants.colId: 3,
        DbConstants.colName: 'Treino HIIT',
        DbConstants.colDurationSeconds: 30,
        DbConstants.colColor: 0xFFE91E63,
        DbConstants.colSoundId: 'bell',
        DbConstants.colCreatedAt: createdAt.millisecondsSinceEpoch,
        DbConstants.colPosition: 2,
      };

      final preset = PresetMapper.fromMap(map);

      expect(preset.id, 3);
      expect(preset.name, 'Treino HIIT');
      expect(preset.durationSeconds, 30);
      expect(preset.color, 0xFFE91E63);
      expect(preset.soundId, 'bell');
      expect(preset.createdAt, createdAt);
      expect(preset.position, 2);
    });

    test('registro sem id resulta em id nulo', () {
      final map = PresetMapper.toMap(buildPreset());

      final preset = PresetMapper.fromMap(map);

      expect(preset.id, isNull);
    });
  });

  group('PresetMapper - ida e volta', () {
    test('toMap seguido de fromMap preserva o preset com id', () {
      final original = buildPreset(id: 5);

      final restored = PresetMapper.fromMap(PresetMapper.toMap(original));

      expectSamePreset(restored, original);
    });

    test('toMap seguido de fromMap preserva o preset sem id', () {
      final original = buildPreset();

      final restored = PresetMapper.fromMap(PresetMapper.toMap(original));

      expectSamePreset(restored, original);
    });
  });
}
