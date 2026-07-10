import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/timetable_entry.dart';

class PdfParserService {
  static Future<String> extractTextFromBytes(Uint8List bytes) async {
    try {
      final document = PdfDocument(inputBytes: bytes);
      if (document.pages.count == 0) {
        document.dispose();
        return '';
      }
      final extractor = PdfTextExtractor(document);
      final text = extractor.extractText();
      document.dispose();
      return text;
    } catch (e) {
      print('Erro ao extrair texto: $e');
      return '';
    }
  }

  /// Extrai o número de matrícula do aluno do cabeçalho do PDF.
  static String? extractMatricula(String text) {
    final matRe = RegExp(r'Aluno\s+(\d+)\s*-');
    final match = matRe.firstMatch(text);
    return match?.group(1);
  }

  /// Extrai o período letivo do cabeçalho (ex: "2026/1").
  static String? extractPeriodoLetivo(String text) {
    final periodRe = RegExp(r'Grade de Horários de\s+(\d{4}/\d)');
    final match = periodRe.firstMatch(text);
    return match?.group(1);
  }

  /// Extrai o nome do aluno do cabeçalho.
  static String? extractAlunoNome(String text) {
    final nomeRe = RegExp(r'Aluno\s+\d+\s*-\s*(.+)');
    final match = nomeRe.firstMatch(text);
    return match?.group(1)?.trim();
  }

  /// Parser principal que extrai disciplinas do PDF da grade UFPel.
  ///
  /// Estratégia:
  /// 1. Identifica seções (MANHÃ / TARDE / NOITE) e linhas de horário
  /// 2. Para cada linha de horário, coleta o texto do bloco até o próximo horário
  /// 3. Extrai disciplinas do bloco (formato: 11100059 - T2 - CÁLCULO 2)
  /// 4. Detecta quais dias da semana estão presentes no cabeçalho da seção
  /// 5. Distribui as disciplinas nos dias baseado na ordem em que aparecem no texto
  static List<TimetableEntry> parseTimetableFromText(String text) {
    final entries = <TimetableEntry>[];
    final lines = text.split(RegExp(r'\r?\n'));

    final timeRangeRe = RegExp(r'^(\d{1,2}:\d{2})\s*[-–—]\s*(\d{1,2}:\d{2})');
    final subjectRe = RegExp(r'(\d{8})\s*-\s*([A-Z]\d?)\s*-\s*(.+)');

    const weekDays = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta'];

    // --- Fase 1: Extrair estrutura ---
    final sections = <_Section>[];
    _Section? currentSection;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      if (line == 'MANHÃ' || line == 'TARDE' || line == 'NOITE') {
        currentSection = _Section(name: line);
        sections.add(currentSection);
        continue;
      }

      if (currentSection == null) continue;

      // Detecta cabeçalho de dias da seção (linha após o nome da seção)
      // Ex: "QuintaSegundaHorarios SextaQuartaTerca"
      if (currentSection.headerLine == null) {
        currentSection.headerLine = line;
        // Detecta quais dias estão presentes
        final headerLower = line.toLowerCase();
        for (final day in weekDays) {
          // Verifica por nome completo ou abreviação de 3 letras
          final day3 = day.substring(0, 3).toLowerCase();
          final dayFull = day.toLowerCase();
          if (headerLower.contains(dayFull) || headerLower.contains(day3)) {
            if (!currentSection.days.contains(day)) {
              currentSection.days.add(day);
            }
          }
        }
        continue;
      }

      // Detecta linha de horário
      final timeMatch = timeRangeRe.firstMatch(line);
      if (timeMatch != null) {
        // Verifica se há disciplina na mesma linha (após o horário)
        final afterTime = line.substring(timeMatch.end).trim();
        String? inlineSubject;
        if (subjectRe.hasMatch(afterTime)) {
          inlineSubject = afterTime;
        }

        currentSection.rows.add(
          _TimeRow(
            start: timeMatch.group(1)!,
            end: timeMatch.group(2)!,
            lineIdx: i,
            inlineText: inlineSubject,
          ),
        );
        continue;
      }
    }

    // --- Fase 2: Extrair disciplinas ---
    for (final section in sections) {
      // Se não detectou dias, usa todos os dias úteis
      if (section.days.isEmpty) {
        section.days.addAll(weekDays);
      }

      for (int ti = 0; ti < section.rows.length; ti++) {
        final row = section.rows[ti];

        // Coleta o bloco de texto: linha do horário + próximas até o próximo horário
        final endIdx = ti + 1 < section.rows.length
            ? section.rows[ti + 1].lineIdx
            : lines.length;

        final String block;
        if (row.inlineText != null) {
          block = row.inlineText!;
        } else {
          final buffer = StringBuffer();
          for (int i = row.lineIdx; i < endIdx && i < lines.length; i++) {
            final l = lines[i].trim();
            if (l.isEmpty) continue;
            // Ignora linhas que são apenas cabeçalho de seção
            if (l == 'MANHÃ' || l == 'TARDE' || l == 'NOITE') continue;
            // Ignora linhas que são apenas horário (sem disciplina)
            if (timeRangeRe.hasMatch(l) && !subjectRe.hasMatch(l)) continue;
            buffer.writeln(l);
          }
          block = buffer.toString().trim();
        }

        if (block.isEmpty) continue;

        // Extrai disciplinas do bloco
        final subjectsInBlock = <_SubjectMatch>[];
        final subjectMatches = subjectRe.allMatches(block);
        for (final m in subjectMatches) {
          subjectsInBlock.add(
            _SubjectMatch(
              code: m.group(1)!,
              turma: m.group(2)!,
              name: m.group(3)!.trim(),
              matchStart: m.start,
            ),
          );
        }

        if (subjectsInBlock.isEmpty) continue;

        final days = section.days;

        // Mapeia: código da disciplina -> dia mais provável
        // Usa a posição do match no texto para determinar o dia
        final Map<String, String?> codeToDay = {};
        for (int si = 0; si < subjectsInBlock.length; si++) {
          final subj = subjectsInBlock[si];

          // Tenta determinar o dia pela posição no texto do bloco
          String? matchedDay;
          if (subjectsInBlock.length > 1 && days.length > 1) {
            final textBefore = block
                .substring(0, subj.matchStart)
                .toLowerCase();
            int bestPos = -1;
            int bestIdx = -1;
            for (int di = 0; di < days.length; di++) {
              final dayLower = days[di].toLowerCase();
              // Procura pelo nome do dia (3 primeiras letras) no texto antes da disciplina
              final pos = textBefore.lastIndexOf(dayLower.substring(0, 3));
              if (pos > bestPos) {
                bestPos = pos;
                bestIdx = di;
              }
            }
            if (bestIdx >= 0) {
              matchedDay = days[bestIdx];
            } else {
              // Fallback: distribui uniformemente
              matchedDay = days[si % days.length];
            }
          } else if (days.length == 1) {
            matchedDay = days[0];
          }
          // Se matchedDay é null (1 disciplina em múltiplos dias), não associamos dia

          codeToDay[subj.code] = matchedDay;
        }

        // Se múltiplas disciplinas com mesmo código (ex: mesma disciplina em dias diferentes),
        // precisa criar entradas separadas para cada dia
        final Map<String, Set<String>> codeDays = {};
        for (int si = 0; si < subjectsInBlock.length; si++) {
          final subj = subjectsInBlock[si];
          final day = codeToDay[subj.code];
          codeDays.putIfAbsent(subj.code, () => {});
          if (day != null) {
            codeDays[subj.code]!.add(day);
          }
        }

        // Cria entradas: se uma disciplina aparece em um horário sem dia definido,
        // mas sabemos que no PDF ela ocupa células em múltiplos dias,
        // criamos uma entrada por dia detectado
        for (final subj in subjectsInBlock) {
          final associatedDays = codeDays[subj.code];
          if (associatedDays != null && associatedDays.isNotEmpty) {
            // Cria uma entrada para cada dia
            for (final day in associatedDays) {
              entries.add(
                TimetableEntry(
                  turma: subj.turma,
                  disciplina: subj.name,
                  codigo: subj.code,
                  dia: day,
                  startTime: row.start,
                  endTime: row.end,
                ),
              );
            }
          } else {
            // Sem dia definido, cria sem dia (o service tentará match)
            entries.add(
              TimetableEntry(
                turma: subj.turma,
                disciplina: subj.name,
                codigo: subj.code,
                startTime: row.start,
                endTime: row.end,
              ),
            );
          }
        }
      }
    }

    return entries;
  }
}

class _Section {
  final String name;
  String? headerLine;
  final List<String> days = [];
  final List<_TimeRow> rows = [];

  _Section({required this.name});
}

class _TimeRow {
  final String start;
  final String end;
  final int lineIdx;
  final String? inlineText;

  _TimeRow({
    required this.start,
    required this.end,
    required this.lineIdx,
    this.inlineText,
  });
}

class _SubjectMatch {
  final String code;
  final String turma;
  final String name;
  final int matchStart;

  _SubjectMatch({
    required this.code,
    required this.turma,
    required this.name,
    required this.matchStart,
  });
}
