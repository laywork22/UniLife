import 'package:uuid/uuid.dart';

import 'models/course.dart';
import 'models/enums.dart';
import 'models/exam.dart';
import 'models/study_session.dart';
import 'models/task.dart';
import 'repositories/course_repository.dart';
import 'repositories/exam_repository.dart';
import 'repositories/session_repository.dart';
import 'repositories/task_repository.dart';

class SeedData {
  SeedData._();

  static const _uuid = Uuid();

  static Future<void> seedIfEmpty() async {
    final courseRepo = CourseRepository();
    final existing = await courseRepo.getAll();
    if (existing.isNotEmpty) return;

    await _seedCourses(courseRepo);
    final courses = await courseRepo.getAll();
    final byName = {for (final c in courses) c.nome: c};

    await _seedExams(byName);

    await _seedTasks(byName);

    await _seedSessions(byName);
  }

  static Future<void> _seedCourses(CourseRepository repo) async {
    final corsi = <Course>[
      Course(
        id: _uuid.v4(),
        nome: 'Fondamenti di Programmazione',
        docente: 'F. Cauteruccio',
        cfu: 12,
        semestre: 1,
        stato: CourseStatus.inCorso,
        descrizione:
            'Algoritmi, strutture dati e introduzione al linguaggio C.',
        materiali: [
          'https://elearning.unisa.it/fdp',
        ],
      ),
      Course(
        id: _uuid.v4(),
        nome: 'Analisi Matematica I',
        docente: 'M. Rossi',
        cfu: 9,
        semestre: 1,
        stato: CourseStatus.superato,
        descrizione: 'Limiti, derivate, integrali a una variabile.',
      ),
      Course(
        id: _uuid.v4(),
        nome: 'Basi di Dati',
        docente: 'L. Bianchi',
        cfu: 9,
        semestre: 1,
        stato: CourseStatus.superato,
        descrizione:
            'Modello relazionale, SQL, progettazione concettuale e logica.',
      ),
      Course(
        id: _uuid.v4(),
        nome: 'Mobile Programming',
        docente: 'F. Cauteruccio',
        cfu: 6,
        semestre: 2,
        stato: CourseStatus.inCorso,
        descrizione: 'Sviluppo app mobili cross-platform con Flutter.',
        materiali: [
          'https://docs.flutter.dev',
          'https://dart.dev/guides',
          'https://m3.material.io',
        ],
      ),
      Course(
        id: _uuid.v4(),
        nome: 'Sistemi Operativi',
        docente: 'P. Verdi',
        cfu: 9,
        semestre: 2,
        stato: CourseStatus.inCorso,
        descrizione: 'Processi, thread, sincronizzazione, file system.',
      ),
      Course(
        id: _uuid.v4(),
        nome: 'Reti di Calcolatori',
        docente: 'A. Neri',
        cfu: 6,
        semestre: 2,
        stato: CourseStatus.inCorso,
        descrizione: 'Modello OSI, TCP/IP, routing.',
      ),
    ];
    for (final c in corsi) {
      await repo.insert(c);
    }
  }

  // ============================== ESAMI ==============================
  static Future<void> _seedExams(Map<String, Course> byName) async {
    final repo = ExamRepository();
    final now = DateTime.now();

    final esami = <Exam>[
      // ----------- Esami già sostenuti -----------
      Exam(
        id: _uuid.v4(),
        title: 'Analisi Matematica I',
        courseId: byName['Analisi Matematica I']!.id,
        date: DateTime(now.year, 2, 14, 9, 0),
        type: ExamType.scrittoOrale,
        priority: Priority.alta,
        status: ExamStatus.completato,
        grade: 27,
        notes: 'Scritto + orale, ottimo risultato sulle serie.',
      ),
      Exam(
        id: _uuid.v4(),
        title: 'Basi di Dati',
        courseId: byName['Basi di Dati']!.id,
        date: DateTime(now.year, 2, 22, 14, 0),
        type: ExamType.scritto,
        priority: Priority.alta,
        status: ExamStatus.completato,
        grade: 30,
        notes: 'Esercizio sulla normalizzazione svolto correttamente.',
      ),
      // Tentativo precedente di BD: voto rifiutato → annullato
      Exam(
        id: _uuid.v4(),
        title: 'Basi di Dati (primo tentativo)',
        courseId: byName['Basi di Dati']!.id,
        date: DateTime(now.year, 1, 18, 14, 0),
        type: ExamType.scritto,
        priority: Priority.media,
        status: ExamStatus.annullato,
        grade: 23,
        notes: 'Voto rifiutato per ripresentarsi a febbraio.',
      ),

      // ----------- Esami in arrivo -----------
      Exam(
        id: _uuid.v4(),
        title: 'Mobile Programming',
        courseId: byName['Mobile Programming']!.id,
        date: _futureDate(now, days: 12, hour: 9),
        type: ExamType.progetto,
        priority: Priority.alta,
        status: ExamStatus.prossimo,
        notes: 'Discussione del progetto UniLife.',
      ),
      Exam(
        id: _uuid.v4(),
        title: 'Sistemi Operativi',
        courseId: byName['Sistemi Operativi']!.id,
        date: _futureDate(now, days: 28, hour: 10),
        type: ExamType.scrittoOrale,
        priority: Priority.alta,
        status: ExamStatus.prossimo,
      ),
      Exam(
        id: _uuid.v4(),
        title: 'Reti di Calcolatori',
        courseId: byName['Reti di Calcolatori']!.id,
        date: _futureDate(now, days: 42, hour: 9),
        type: ExamType.scritto,
        priority: Priority.media,
        status: ExamStatus.prossimo,
      ),
      Exam(
        id: _uuid.v4(),
        title: 'Fondamenti di Programmazione',
        courseId: byName['Fondamenti di Programmazione']!.id,
        date: _futureDate(now, days: 55, hour: 11),
        type: ExamType.orale,
        priority: Priority.media,
        status: ExamStatus.prossimo,
      ),

      // ----------- Esame standalone (senza corso registrato) -----------
      Exam(
        id: _uuid.v4(),
        title: 'Chimica Generale',
        courseId: null,
        cfu: 6,
        date: DateTime(now.year - 1, 9, 12, 10, 0),
        type: ExamType.scrittoOrale,
        priority: Priority.bassa,
        status: ExamStatus.completato,
        grade: 24,
        notes:
            'Esame del primo anno registrato retroattivamente in standalone.',
      ),
    ];
    for (final e in esami) {
      await repo.insert(e);
    }
  }

  // ============================== TASK ==============================
  static Future<void> _seedTasks(Map<String, Course> byName) async {
    final repo = TaskRepository();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final tasks = <Task>[
      // ----------- Task di oggi (da completare) -----------
      Task(
        id: _uuid.v4(),
        title: 'Esercizio Flutter: widget compositi',
        description: 'Realizzare una card riusabile per la dashboard.',
        courseId: byName['Mobile Programming']?.id,
        priority: Priority.alta,
        status: TaskStatus.daCompletare,
        dueDate: today,
        estimatedMinutes: 90,
      ),
      Task(
        id: _uuid.v4(),
        title: 'Lettura cap. 5: Process Scheduling',
        courseId: byName['Sistemi Operativi']?.id,
        priority: Priority.media,
        status: TaskStatus.daCompletare,
        dueDate: today,
        estimatedMinutes: 60,
      ),
      Task(
        id: _uuid.v4(),
        title: 'Esercizi subnetting',
        courseId: byName['Reti di Calcolatori']?.id,
        priority: Priority.bassa,
        status: TaskStatus.daCompletare,
        dueDate: today.add(const Duration(days: 1)),
        estimatedMinutes: 45,
      ),

      // ----------- Task con scadenza ravvicinata -----------
      Task(
        id: _uuid.v4(),
        title: 'Progetto SO: implementare shell minimale',
        description: 'Fork dei processi + parsing comandi.',
        courseId: byName['Sistemi Operativi']?.id,
        priority: Priority.alta,
        status: TaskStatus.daCompletare,
        dueDate: today.add(const Duration(days: 4)),
        estimatedMinutes: 180,
      ),

      // ----------- Task completati di recente -----------
      Task(
        id: _uuid.v4(),
        title: 'Letture su semafori e mutex',
        courseId: byName['Sistemi Operativi']?.id,
        priority: Priority.media,
        status: TaskStatus.completato,
        dueDate: today.subtract(const Duration(days: 1)),
        estimatedMinutes: 45,
        actualMinutes: 50,
        completedAt: today.subtract(const Duration(hours: 18)),
      ),
      Task(
        id: _uuid.v4(),
        title: 'Esercizi su normalizzazione 3NF',
        courseId: byName['Basi di Dati']?.id,
        priority: Priority.bassa,
        status: TaskStatus.completato,
        estimatedMinutes: 60,
        actualMinutes: 75,
        completedAt: today.subtract(const Duration(days: 3)),
      ),

      // ----------- Obiettivo a lungo termine -----------
      Task(
        id: _uuid.v4(),
        title: 'Laurearmi entro luglio 2027',
        description: 'Triennale completa con media >= 27.',
        priority: Priority.alta,
        status: TaskStatus.daCompletare,
        isGoal: true,
        estimatedMinutes: 0,
      ),
    ];
    for (final t in tasks) {
      await repo.insert(t);
    }
  }

  // ============================ SESSIONI ============================
  static Future<void> _seedSessions(Map<String, Course> byName) async {
    final repo = SessionRepository();
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));

    DateTime dayAt(int dayOffset, int hour, int minute) {
      final base = monday.add(Duration(days: dayOffset));
      return DateTime(base.year, base.month, base.day, hour, minute);
    }

    DateTime midnightOf(int dayOffset) {
      final base = monday.add(Duration(days: dayOffset));
      return DateTime(base.year, base.month, base.day);
    }

    final sessions = <StudySession>[
      // Lunedì: sessione di studio completata
      StudySession(
        id: _uuid.v4(),
        title: 'Studio Mobile Programming',
        courseId: byName['Mobile Programming']?.id,
        date: midnightOf(0),
        startTime: dayAt(0, 15, 0),
        endTime: dayAt(0, 16, 0),
        type: SessionType.studio,
        isCompleted: true,
        actualMinutes: 50,
        notes: 'Capitolo su State Management.',
      ),
      // Martedì: esercizi completati
      StudySession(
        id: _uuid.v4(),
        title: 'Esercizi su query SQL avanzate',
        courseId: byName['Basi di Dati']?.id,
        date: midnightOf(1),
        startTime: dayAt(1, 9, 30),
        endTime: dayAt(1, 11, 0),
        type: SessionType.esercizi,
        isCompleted: true,
        actualMinutes: 85,
      ),
      // Mercoledì: lezione (pianificata, anche se passata)
      StudySession(
        id: _uuid.v4(),
        title: 'Lezione: Process Synchronization',
        courseId: byName['Sistemi Operativi']?.id,
        date: midnightOf(2),
        startTime: dayAt(2, 10, 0),
        endTime: dayAt(2, 12, 0),
        type: SessionType.lezione,
        isCompleted: false,
      ),
      // Giovedì: ripasso pianificato
      StudySession(
        id: _uuid.v4(),
        title: 'Ripasso TCP/IP livelli',
        courseId: byName['Reti di Calcolatori']?.id,
        date: midnightOf(3),
        startTime: dayAt(3, 14, 30),
        endTime: dayAt(3, 16, 30),
        type: SessionType.ripasso,
        isCompleted: false,
      ),
      // Sabato: laboratorio per il progetto SO
      StudySession(
        id: _uuid.v4(),
        title: 'Laboratorio: implementazione fork()',
        courseId: byName['Sistemi Operativi']?.id,
        date: midnightOf(5),
        startTime: dayAt(5, 9, 0),
        endTime: dayAt(5, 12, 0),
        type: SessionType.laboratorio,
        isCompleted: false,
      ),
    ];
    for (final s in sessions) {
      await repo.insert(s);
    }
  }

  /// Helper: una data nel futuro relativa a `now`, settata all'ora richiesta.
  static DateTime _futureDate(DateTime now,
      {required int days, required int hour}) {
    final d = now.add(Duration(days: days));
    return DateTime(d.year, d.month, d.day, hour, 0);
  }
}
