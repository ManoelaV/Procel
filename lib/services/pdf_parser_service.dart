import 'dart:io';

import 'package:pdf_text/pdf_text.dart';

import '../models/timetable_entry.dart';
import '../models/room_model.dart';

class PdfParserService {
  /// Extrai texto bruto do PDF usando `pdf_text`.
  static Future<String> extractTextFromPdf(File file) async {
    final doc = await PDFDoc.fromFile(file);
    final text = await doc.text;
    return text;
  }

  /// Parse simples do texto para extrair entradas de horário.
  /// Heurística: encontra ranges de horário e tenta capturar disciplina/turma na mesma linha.
  static List<TimetableEntry> parseTimetableFromText(String text) {
    final lines = text.split(RegExp(r'\r?\n'));
    final timeRangeRe = RegExp(r"(\d{1,2}:\d{2})\s*[-–—]\s*(\d{1,2}:\d{2})");
    final dayRe = RegExp(r"(Segunda|Terca|Terça|Quarta|Quinta|Sexta|Sabado|Sábado|Segunda-feira|Terça-feira|Quarta-feira|Quinta-feira|Sexta-feira|Sábado)", caseSensitive: false);
    final turmaRe = RegExp(r"[Tt]urma[:\s]*([A-Za-z0-9\-_/]+)");

    final entries = <TimetableEntry>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final timeMatch = timeRangeRe.firstMatch(line);
      if (timeMatch != null) {
        final start = timeMatch.group(1);
        final end = timeMatch.group(2);

        // tenta extrair dia na linha atual ou anterior
        String? dia;
        final dayMatch = dayRe.firstMatch(line) ?? (i > 0 ? dayRe.firstMatch(lines[i - 1]) : null);
        if (dayMatch != null) dia = dayMatch.group(0);

        // tenta extrair turma da linha inteira do documento
        final turmaMatch = turmaRe.firstMatch(text);
        final turma = turmaMatch != null ? turmaMatch.group(1) : null;

        // disciplina: parte do texto antes do horário na mesma linha (últimas 4 palavras)
        final before = line.substring(0, timeMatch.start).trim();
        String? disciplina;
        if (before.isNotEmpty) {
          final words = before.split(RegExp(r'\s+'));
          final lastWords = words.length <= 4 ? words : words.sublist(words.length - 4);
          disciplina = lastWords.join(' ');
        }

        entries.add(TimetableEntry(
          turma: turma,
          disciplina: disciplina,
          dia: dia,
          startTime: start,
          endTime: end,
        ));
      }
    }

    return entries;
  }

  /// Heurística de mapeamento: tenta casar `turma` ou `disciplina` com o nome da sala.
  static Map<TimetableEntry, Room?> mapEntriesToRooms(
      List<TimetableEntry> entries, List<Room> rooms) {
    final map = <TimetableEntry, Room?>{};
    for (final e in entries) {
      Room? matched;
      final queryParts = <String>[];
      if (e.turma != null) queryParts.add(e.turma!.toLowerCase());
      if (e.disciplina != null) queryParts.addAll(e.disciplina!.toLowerCase().split(RegExp(r'\s+')));

      final score = <Room, int>{};
      for (final r in rooms) {
        var s = 0;
        final name = (r.name + ' ' + (r.building ?? '')).toLowerCase();
        for (final qp in queryParts) {
          if (qp.isEmpty) continue;
          if (name.contains(qp)) s += 1;
        }
        if (s > 0) score[r] = s;
      }

      if (score.isNotEmpty) {
        final best = score.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
        matched = best;
      }

      map[e] = matched;
    }
    return map;
  }
}
