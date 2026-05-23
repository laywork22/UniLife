// Enumerazioni condivise dai modelli (persistite come stringhe nel DB).

enum CourseStatus { inCorso, superato }

extension CourseStatusX on CourseStatus {
  String get label =>
      this == CourseStatus.inCorso ? 'In corso' : 'Superato';
  static CourseStatus fromName(String? n) =>
      CourseStatus.values.firstWhere(
        (e) => e.name == n,
        orElse: () => CourseStatus.inCorso,
      );
}

enum ExamStatus { prossimo, completato, annullato }

extension ExamStatusX on ExamStatus {
  String get label => switch (this) {
        ExamStatus.prossimo => 'Prossimo',
        ExamStatus.completato => 'Completato',
        ExamStatus.annullato => 'Annullato',
      };
  static ExamStatus fromName(String? n) => ExamStatus.values.firstWhere(
        (e) => e.name == n,
        orElse: () => ExamStatus.prossimo,
      );
}

enum ExamType { scritto, orale, scrittoOrale, pratico, progetto }

extension ExamTypeX on ExamType {
  String get label => switch (this) {
        ExamType.scritto => 'Scritto',
        ExamType.orale => 'Orale',
        ExamType.scrittoOrale => 'Scritto + Orale',
        ExamType.pratico => 'Pratico',
        ExamType.progetto => 'Progetto',
      };
  static ExamType fromName(String? n) => ExamType.values.firstWhere(
        (e) => e.name == n,
        orElse: () => ExamType.scritto,
      );
}

enum Priority { bassa, media, alta }

extension PriorityX on Priority {
  String get label => switch (this) {
        Priority.bassa => 'Bassa',
        Priority.media => 'Media',
        Priority.alta => 'Alta',
      };
  static Priority fromName(String? n) => Priority.values.firstWhere(
        (e) => e.name == n,
        orElse: () => Priority.media,
      );
}

enum TaskStatus { daCompletare, completato }

extension TaskStatusX on TaskStatus {
  String get label =>
      this == TaskStatus.completato ? 'Completato' : 'Da completare';
  static TaskStatus fromName(String? n) => TaskStatus.values.firstWhere(
        (e) => e.name == n,
        orElse: () => TaskStatus.daCompletare,
      );
}

enum SessionType { lezione, studio, esercizi, ripasso, laboratorio }

extension SessionTypeX on SessionType {
  String get label => switch (this) {
        SessionType.lezione => 'Lezione',
        SessionType.studio => 'Studio',
        SessionType.esercizi => 'Esercizi',
        SessionType.ripasso => 'Ripasso',
        SessionType.laboratorio => 'Laboratorio',
      };
  static SessionType fromName(String? n) => SessionType.values.firstWhere(
        (e) => e.name == n,
        orElse: () => SessionType.studio,
      );
}
