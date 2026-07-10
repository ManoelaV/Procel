import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/room_model.dart';
import '../../models/timetable_entry.dart';
import '../../pages/backend_auth_screen.dart';
import '../../services/backend_session.dart';
import '../../services/pdf_parser_service.dart';
import '../../services/schedule_room_service.dart';

class UploadPdfRoomsWidget extends StatefulWidget {
  const UploadPdfRoomsWidget({super.key});

  @override
  State<UploadPdfRoomsWidget> createState() => _UploadPdfRoomsWidgetState();
}

class _UploadPdfRoomsWidgetState extends State<UploadPdfRoomsWidget> {
  String? _status;
  List<Room> _rooms = [];
  bool _needsBackendLogin = false;
  bool _isProcessing = false;

  Future<void> _pickAndProcessPdf() async {
    if (_isProcessing || _needsBackendLogin) {
      return;
    }

    try {
      setState(() {
        _isProcessing = true;
        _status = 'Selecionando arquivo...';
        _rooms = [];
        _needsBackendLogin = false;
      });

      PlatformFile? file;
      try {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
          withData: true,
        );
        if (result == null) {
          setState(() => _status = 'Seleção cancelada pelo usuário.');
          return;
        }
        file = result.files.single;
      } catch (e) {
        setState(() {
          _status = 'Erro ao selecionar arquivo: $e';
        });
        return;
      }

      if (file.bytes == null) {
        setState(() => _status = 'Não foi possível ler o arquivo selecionado.');
        return;
      }

      setState(() => _status = 'Extraindo texto do PDF...');
      final text = await PdfParserService.extractTextFromBytes(file.bytes!);

      if (text.isEmpty) {
        setState(() => _status = 'Não foi possível extrair texto do PDF.');
        return;
      }

      // Extrai matrícula e período letivo do cabeçalho do PDF
      final matricula = PdfParserService.extractMatricula(text);
      final periodoLetivo = PdfParserService.extractPeriodoLetivo(text);

      if (matricula == null || periodoLetivo == null) {
        setState(() {
          _status = matricula == null
              ? 'Não foi possível identificar a matrícula no PDF.'
              : 'Não foi possível identificar o período letivo no PDF.';
        });
        return;
      }

      setState(() => _status = 'Parseando horários do PDF...');
      final entries = PdfParserService.parseTimetableFromText(text);

      setState(() {
        _status =
            '${entries.length} disciplina(s) encontrada(s). Buscando salas...';
      });

      // USA A MATRÍCULA DO PDF (ex: 22202589) como pessoaId
      // A API /api/pessoas/{pessoaId}/disciplinas aceita userId ou matricula
      final mapping = await ScheduleRoomService.fetchRoomsForSchedule(
        entries: entries,
        matricula: matricula,
        periodoLetivo: periodoLetivo,
      );

      final encontradas = mapping.values.whereType<Room>().length;
      setState(() {
        _status = 'Mapeamento concluído! $encontradas sala(s) encontrada(s).';
        _rooms = mapping.values.whereType<Room>().toList();
      });
      _showMappingResults(mapping);
    } catch (e) {
      final errorMsg = _friendlyError(e);
      final isLoginError = errorMsg.contains('Login');
      setState(() {
        _needsBackendLogin = isLoginError;
        _status = errorMsg;
      });
      print('Erro no upload de PDF: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  String _friendlyError(Object error) =>
      error.toString().replaceFirst('Exception: ', '');

  void _showMappingResults(Map<TimetableEntry, Room?> mapping) {
    final encontradas = mapping.values.whereType<Room>().length;
    final naoEncontradas = mapping.length - encontradas;

    showModalBottomSheet(
      context: context,
      builder: (_) => SizedBox(
        height: 400,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '$encontradas sala(s) encontrada(s), $naoEncontradas não encontrada(s)',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                children: mapping.entries.map((e) {
                  final entry = e.key;
                  final room = e.value;
                  return ListTile(
                    title: Text(entry.disciplina ?? entry.codigo ?? '?'),
                    subtitle: Text(
                      '${entry.dia ?? ''} ${entry.startTime ?? ''}-${entry.endTime ?? ''}'
                      '${room != null ? ' → Sala: ${room.name}' : ' → Sala não encontrada'}',
                    ),
                    trailing: room != null
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.cancel, color: Colors.red),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _goToBackendLogin() async {
    await BackendSession.clear();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const BackendAuthScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: _isProcessing || _needsBackendLogin
              ? null
              : _pickAndProcessPdf,
          icon: _isProcessing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.upload_file),
          label: const Text('Enviar PDF de horários'),
        ),
        const SizedBox(height: 12),
        if (_status != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _status!.contains('sucesso')
                  ? Colors.green.shade50
                  : _status!.contains('Erro')
                  ? Colors.red.shade50
                  : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _status!.contains('sucesso')
                    ? Colors.green.shade200
                    : _status!.contains('Erro')
                    ? Colors.red.shade200
                    : Colors.blue.shade200,
              ),
            ),
            child: Text(
              _status!,
              style: TextStyle(
                color: _status!.contains('sucesso')
                    ? Colors.green.shade800
                    : _status!.contains('Erro')
                    ? Colors.red.shade800
                    : Colors.blue.shade800,
                fontSize: 13,
              ),
            ),
          ),
        if (_needsBackendLogin) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _goToBackendLogin,
            icon: const Icon(Icons.login),
            label: const Text('Entrar novamente'),
          ),
        ],
        const SizedBox(height: 12),
        if (_rooms.isNotEmpty)
          ..._rooms.map(
            (r) => ListTile(
              title: Text(r.name),
              subtitle: Text('${r.building ?? ''} ${r.floor ?? ''}'),
            ),
          ),
      ],
    );
  }
}
