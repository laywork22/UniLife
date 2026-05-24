import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../core/constants/app_constants.dart';

/// Singleton sqflite: apre il DB, crea le 4 tabelle e gestisce versione/migrazioni.
/// Garantisce FC-2 (offline) e FC-5 (query indicizzate per liste fluide).
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    // Su desktop usiamo sqflite_ffi; su mobile resta sqflite di default.
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, AppConstants.dbName);

    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createSchema,
      onUpgrade: _onUpgrade,
    );
  }

  /// Migrazioni di schema.
  /// - v1 → v2: il voto è stato rimosso dalla tabella `courses` (il voto
  ///   appartiene a [Exam], non al corso).
  /// - v2 → v3: `exams.course_id` diventa nullable e viene aggiunta la
  ///   colonna `cfu` per gli esami "standalone" inseriti senza un corso.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('PRAGMA foreign_keys = OFF');
      await db.execute('''
        CREATE TABLE ${AppConstants.tableCourses}_new (
          id TEXT PRIMARY KEY,
          nome TEXT NOT NULL,
          docente TEXT NOT NULL,
          cfu INTEGER NOT NULL,
          semestre INTEGER NOT NULL,
          stato TEXT NOT NULL,
          descrizione TEXT,
          note TEXT,
          materiali TEXT
        )
      ''');
      await db.execute('''
        INSERT INTO ${AppConstants.tableCourses}_new
          (id, nome, docente, cfu, semestre, stato, descrizione, note, materiali)
        SELECT id, nome, docente, cfu, semestre, stato, descrizione, note, materiali
        FROM ${AppConstants.tableCourses}
      ''');
      await db.execute('DROP TABLE ${AppConstants.tableCourses}');
      await db.execute(
          'ALTER TABLE ${AppConstants.tableCourses}_new RENAME TO ${AppConstants.tableCourses}');
      await db.execute('PRAGMA foreign_keys = ON');
    }
    if (oldVersion < 3) {
      await db.execute('PRAGMA foreign_keys = OFF');
      await db.execute('''
        CREATE TABLE ${AppConstants.tableExams}_new (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          course_id TEXT,
          cfu INTEGER,
          date TEXT NOT NULL,
          type TEXT NOT NULL,
          priority TEXT NOT NULL,
          status TEXT NOT NULL,
          grade INTEGER,
          notes TEXT,
          FOREIGN KEY (course_id) REFERENCES ${AppConstants.tableCourses}(id) ON DELETE SET NULL
        )
      ''');
      await db.execute('''
        INSERT INTO ${AppConstants.tableExams}_new
          (id, title, course_id, date, type, priority, status, grade, notes)
        SELECT id, title, course_id, date, type, priority, status, grade, notes
        FROM ${AppConstants.tableExams}
      ''');
      await db.execute('DROP TABLE ${AppConstants.tableExams}');
      await db.execute(
          'ALTER TABLE ${AppConstants.tableExams}_new RENAME TO ${AppConstants.tableExams}');
      await db.execute(
          'CREATE INDEX idx_exams_course ON ${AppConstants.tableExams}(course_id)');
      await db.execute(
          'CREATE INDEX idx_exams_date ON ${AppConstants.tableExams}(date)');
      await db.execute('PRAGMA foreign_keys = ON');
    }
  }

  Future<void> _createSchema(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableCourses} (
        id TEXT PRIMARY KEY,
        nome TEXT NOT NULL,
        docente TEXT NOT NULL,
        cfu INTEGER NOT NULL,
        semestre INTEGER NOT NULL,
        stato TEXT NOT NULL,
        descrizione TEXT,
        note TEXT,
        materiali TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableExams} (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        course_id TEXT,
        cfu INTEGER,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        priority TEXT NOT NULL,
        status TEXT NOT NULL,
        grade INTEGER,
        notes TEXT,
        FOREIGN KEY (course_id) REFERENCES ${AppConstants.tableCourses}(id) ON DELETE SET NULL
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_exams_course ON ${AppConstants.tableExams}(course_id)');
    await db.execute(
        'CREATE INDEX idx_exams_date ON ${AppConstants.tableExams}(date)');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableSessions} (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        course_id TEXT,
        exam_id TEXT,
        date TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        type TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        actual_minutes INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        FOREIGN KEY (course_id) REFERENCES ${AppConstants.tableCourses}(id) ON DELETE SET NULL,
        FOREIGN KEY (exam_id) REFERENCES ${AppConstants.tableExams}(id) ON DELETE SET NULL
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_sessions_date ON ${AppConstants.tableSessions}(date)');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableTasks} (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        course_id TEXT,
        priority TEXT NOT NULL,
        status TEXT NOT NULL,
        due_date TEXT,
        estimated_minutes INTEGER NOT NULL DEFAULT 0,
        actual_minutes INTEGER NOT NULL DEFAULT 0,
        completed_at TEXT,
        is_goal INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (course_id) REFERENCES ${AppConstants.tableCourses}(id) ON DELETE SET NULL
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_tasks_due ON ${AppConstants.tableTasks}(due_date)');
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
