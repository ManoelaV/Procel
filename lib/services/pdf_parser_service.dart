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
      // Extrai texto de todas as páginas de uma vez
      final text = extractor.extractText();
      document.dispose();
      return text ?? '';
    } catch (e) {
      // Se falhar, retorna vazio ou lança exceção
      print('Erro ao extrair texto: $e');
      return '';
    }
  }

  // Parser
  static List<TimetableEntry> parseTimetableFromText(String text) {
    final entries = <TimetableEntry>[];
    final lines = text.split(RegExp(r'\r?\n'));

    final timeRangeRe = RegExp(r'(\d{1,2}:\d{2})\s*[-–—]\s*(\d{1,2}:\d{2})');
    final dayRe = RegExp(
      r'(Segunda|Terça|Terca|Quarta|Quinta|Sexta|Sábado|Sabado)',
      caseSensitive: false,
    );
    final subjectRe = RegExp(r'(\d{8})\s*-\s*([A-Z]\d?)\s*-\s*(.+)');

    String? currentDay;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final dayMatch = dayRe.firstMatch(line);
      if (dayMatch != null) {
        currentDay = dayMatch.group(0);
        continue;
      }

      final timeMatch = timeRangeRe.firstMatch(line);
      if (timeMatch != null && currentDay != null) {
        final start = timeMatch.group(1)!;
        final end = timeMatch.group(2)!;

        String? subjectLine;
        final afterTime = line.substring(timeMatch.end).trim();
        if (afterTime.isNotEmpty) {
          subjectLine = afterTime;
        } else {
          for (var j = 1; j <= 2 && i + j < lines.length; j++) {
            final nextLine = lines[i + j].trim();
            if (nextLine.isNotEmpty) {
              subjectLine = nextLine;
              break;
            }
          }
        }

        if (subjectLine != null) {
          final subjectMatch = subjectRe.firstMatch(subjectLine);
          if (subjectMatch != null) {
            final code = subjectMatch.group(1)!;
            final turma = subjectMatch.group(2)!;
            final name = subjectMatch.group(3)!.trim();

            entries.add(
              TimetableEntry(
                turma: turma,
                disciplina: name,
                dia: currentDay,
                startTime: start,
                endTime: end,
                // codigo: code, // descomente se necessário
              ),
            );
          }
        }
      }
    }

    return entries;
  }
}
