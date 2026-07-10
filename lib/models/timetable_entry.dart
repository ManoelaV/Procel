class TimetableEntry {
  TimetableEntry({
    this.turma,
    this.disciplina,
    this.codigo,
    this.dia,
    this.startTime,
    this.endTime,
  });

  final String? turma;
  final String? disciplina;
  final String? codigo;
  final String? dia;
  final String? startTime;
  final String? endTime;

  Map<String, dynamic> toJson() => {
    'turma': turma,
    'disciplina': disciplina,
    'codigo': codigo,
    'dia': dia,
    'startTime': startTime,
    'endTime': endTime,
  };

  @override
  String toString() =>
      '${disciplina ?? ''} ${turma ?? ''} ${dia ?? ''} ${startTime ?? ''}-${endTime ?? ''}';
}
