import 'package:multi_timer/core/constants/db_constants.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const String _tablePresets =
      '''
  CREATE TABLE ${DbConstants.tablePresets} (
    ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${DbConstants.colName} TEXT NOT NULL,
    ${DbConstants.colDurationSeconds} INTEGER NOT NULL, 
    ${DbConstants.colColor} INTEGER NOT NULL,
    ${DbConstants.colSoundId} TEXT NOT NULL,
    ${DbConstants.colCreatedAt} INTEGER NOT NULL,
    ${DbConstants.colPosition} INTEGER NOT NULL
  )
      ''';

  static const String _tableTimers =
      '''
  CREATE TABLE ${DbConstants.tableTimers} (
    ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT, 
    ${DbConstants.colName} TEXT NOT NULL, 
    ${DbConstants.colColor} INTEGER NOT NULL, 
    ${DbConstants.colSoundId} TEXT NOT NULL, 
    ${DbConstants.colDurationSeconds} INTEGER NOT NULL, 
    ${DbConstants.colRemainingSeconds} INTEGER NOT NULL, 
    ${DbConstants.colEndsAt} INTEGER, 
    ${DbConstants.colStatus} TEXT NOT NULL, 
    ${DbConstants.colNotificationId} INTEGER NOT NULL, 
    ${DbConstants.colPresetId} INTEGER REFERENCES ${DbConstants.tablePresets}(${DbConstants.colId}) ON DELETE SET NULL, 
    ${DbConstants.colCreatedAt} INTEGER NOT NULL, 
    ${DbConstants.colFinishedAt} INTEGER
  )
      ''';

  static const String _tableSettings =
      '''
  CREATE TABLE ${DbConstants.tableSettings} (
    ${DbConstants.colSettingKey} TEXT PRIMARY KEY, 
    ${DbConstants.colSettingValue} TEXT NOT NULL
  )
      ''';

  final String? _path;
  Future<Database>? _databaseFuture;
  final Map<int, Future<void> Function(Database db)> _migrations = {};

  AppDatabase({this._path});

  Future<Database> get database => _databaseFuture ??= _open();

  Future<Database> _open() async {
    return await openDatabase(
      _path ?? join(await getDatabasesPath(), DbConstants.dbName),
      version: DbConstants.dbVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute("PRAGMA foreign_keys = ON");
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(_tablePresets);
    await db.execute(_tableTimers);

    await db.execute(
      "CREATE INDEX idx_timers_status ON ${DbConstants.tableTimers}(${DbConstants.colStatus})",
    );
    await db.execute(
      "CREATE INDEX idx_timers_finished_at ON ${DbConstants.tableTimers}(${DbConstants.colFinishedAt})",
    );

    await db.execute(_tableSettings);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    for (var version = oldVersion + 1; version <= newVersion; version++) {
      final migration = _migrations[version];
      if (migration != null) await migration(db);
    }
  }
}
