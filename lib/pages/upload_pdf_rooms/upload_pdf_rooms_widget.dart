import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../services/rooms_service.dart';
import '../../models/room_model.dart';
import '../../services/pdf_parser_service.dart';
import '../../models/timetable_entry.dart';

class UploadPdfRoomsWidget extends StatefulWidget {
  const UploadPdfRoomsWidget({super.key});

  @override
  State<UploadPdfRoomsWidget> createState() => _UploadPdfRoomsWidgetState();
}

class _UploadPdfRoomsWidgetState extends State<UploadPdfRoomsWidget> {
  String? _status;
  List<Room> _rooms = [];

  Future<void> _pickAndProcessPdf() async {
    setState(() => _status = 'Selecionando arquivo...');
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null) {
      setState(() => _status = 'Seleção cancelada.');
      return;
    }

    final file = File(result.files.single.path!);
    setState(() => _status = 'Extraindo texto do PDF...');
    final text = await PdfParserService.extractTextFromPdf(file);
    setState(() => _status = 'Parseando horários do PDF...');
    final entries = PdfParserService.parseTimetableFromText(text);

    setState(() => _status = 'Buscando salas no back-end...');
    final backendRooms = await RoomsService.fetchRoomsFromBackend();
    if (backendRooms.isNotEmpty) {
      setState(() {
        _rooms = backendRooms;
        _status = 'Salas carregadas do back-end: ${_rooms.length}';
      });

      final mapping = PdfParserService.mapEntriesToRooms(entries, _rooms);
      setState(() {
        _status = 'Mapeamento concluído. ${mapping.length} entradas';
      });
      _showMappingResults(mapping);
      return;
    }

    setState(
      () => _status = 'Back-end não retornou salas. Tentando Cobalto...',
    );
    final raw = await RoomsService.fetchRoomsFromCobaltoRaw();
    if (raw == null) {
      setState(() => _status = 'Falha ao obter salas.');
      return;
    }

    setState(
      () => _status = 'Cobalto retornou dados; processamento necessário.',
    );
    // Tentar decodificar JSON se for JSON
    List<Room> cobaltoRooms = [];
    try {
      final decoded = json.decode(raw);
      if (decoded is List) {
        cobaltoRooms = decoded.map((e) => Room.fromJson(e)).toList();
      } else if (decoded is Map) {
        if (decoded['rooms'] is List)
          cobaltoRooms = (decoded['rooms'] as List)
              .map((e) => Room.fromJson(e))
              .toList();
        else if (decoded['compartimentos'] is List)
          cobaltoRooms = (decoded['compartimentos'] as List)
              .map((e) => Room.fromJson(e))
              .toList();
      }
    } catch (_) {
      // HTML ou formato inesperado — parser específico necessário
    }

    if (cobaltoRooms.isNotEmpty) {
      setState(() {
        _rooms = cobaltoRooms;
        _status = 'Salas carregadas do Cobalto: ${_rooms.length}';
      });
      final mapping = PdfParserService.mapEntriesToRooms(entries, _rooms);
      _showMappingResults(mapping);
      return;
    }

    setState(() => _status = 'Não foi possível obter salas de nenhuma fonte.');
  }

  void _showMappingResults(Map<TimetableEntry, Room?> mapping) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SizedBox(
        height: 400,
        child: ListView(
          children: mapping.entries.map((e) {
            final entry = e.key;
            final room = e.value;
            return ListTile(
              title: Text(entry.toString()),
              subtitle: Text(
                room != null ? 'Sala: ${room.name}' : 'Sala não encontrada',
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: _pickAndProcessPdf,
          icon: const Icon(Icons.upload_file),
          label: const Text('Enviar PDF de horários'),
        ),
        const SizedBox(height: 12),
        if (_status != null) Text(_status!),
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
