/// Modelo para Missão (Catálogo)
class Missao {
  final String id;
  final String titulo;
  final String descricao;
  final String tipo;
  final int value;
  final bool ativo;
  final DateTime createdAt;

  Missao({
    required this.id,
    required this.titulo,
    required this.descricao,
    this.tipo = 'Individual',
    this.value = 0,
    required this.ativo,
    required this.createdAt,
  });

  factory Missao.fromJson(Map<String, dynamic> json) {
    return Missao(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String? ?? '',
      tipo: json['tipo'] as String? ?? 'Individual',
      value: json['value'] as int? ?? 0,
      ativo: json['ativo'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'tipo': tipo,
      'value': value,
      'ativo': ativo,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'Missao(id: $id, titulo: $titulo, tipo: $tipo, value: $value XP, ativo: $ativo)';
}

/// Enum para Status de Atividade
enum AtividadeStatus {
  pendente,
  emAndamento,
  concluida,
  cancelada;

  String get label {
    switch (this) {
      case AtividadeStatus.pendente:
        return 'Pendente';
      case AtividadeStatus.emAndamento:
        return 'Em Andamento';
      case AtividadeStatus.concluida:
        return 'Concluída';
      case AtividadeStatus.cancelada:
        return 'Cancelada';
    }
  }

  String get apiValue {
    switch (this) {
      case AtividadeStatus.pendente:
        return 'PENDENTE';
      case AtividadeStatus.emAndamento:
        return 'EM_ANDAMENTO';
      case AtividadeStatus.concluida:
        return 'CONCLUIDA';
      case AtividadeStatus.cancelada:
        return 'CANCELADA';
    }
  }

  static AtividadeStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PENDENTE':
        return AtividadeStatus.pendente;
      case 'EM_ANDAMENTO':
        return AtividadeStatus.emAndamento;
      case 'CONCLUIDA':
        return AtividadeStatus.concluida;
      case 'CANCELADA':
        return AtividadeStatus.cancelada;
      default:
        return AtividadeStatus.pendente;
    }
  }
}

/// Modelo para PessoaMissao (Atividade)
class PessoaMissao {
  final String id;
  final String pessoaId;
  final String missaoId;
  final AtividadeStatus status;
  final DateTime assignedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  // Dados da missão preenchidos (para exibição)
  String? missaoTitulo;
  String? missaoDescricao;
  String? missaoTipo;
  int missaoValue;
  String? pessoaNome;

  PessoaMissao({
    required this.id,
    required this.pessoaId,
    required this.missaoId,
    required this.status,
    required this.assignedAt,
    this.startedAt,
    this.completedAt,
    this.missaoTitulo,
    this.missaoDescricao,
    this.missaoTipo,
    this.missaoValue = 0,
    this.pessoaNome,
  });

  factory PessoaMissao.fromJson(Map<String, dynamic> json) {
    return PessoaMissao(
      id: json['id'] as String,
      pessoaId: json['pessoaId'] as String,
      missaoId: json['missaoId'] as String,
      status: AtividadeStatus.fromString(json['status'] as String),
      assignedAt: json['assignedAt'] != null
          ? DateTime.parse(json['assignedAt'] as String)
          : DateTime.now(),
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      missaoTitulo: json['missaoTitulo'] as String?,
      missaoDescricao: json['missaoDescricao'] as String?,
      missaoTipo: json['missaoTipo'] as String? ?? 'Individual',
      missaoValue: json['missaoValue'] as int? ?? 0,
      pessoaNome: json['pessoaNome'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pessoaId': pessoaId,
      'missaoId': missaoId,
      'status': status.apiValue,
      'assignedAt': assignedAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'missaoTitulo': missaoTitulo,
      'missaoDescricao': missaoDescricao,
      'missaoTipo': missaoTipo,
      'missaoValue': missaoValue,
      'pessoaNome': pessoaNome,
    };
  }

  bool get isPending => status == AtividadeStatus.pendente;
  bool get isInProgress => status == AtividadeStatus.emAndamento;
  bool get isCompleted => status == AtividadeStatus.concluida;
  bool get isCanceled => status == AtividadeStatus.cancelada;

  Duration? get duration {
    if (startedAt == null || completedAt == null) return null;
    return completedAt!.difference(startedAt!);
  }

  @override
  String toString() =>
      'PessoaMissao(id: $id, missao: $missaoTitulo, status: ${status.label}, xp: $missaoValue)';
}

/// DTO para criar/atribuir missão
class AtribuirMissaoRequest {
  final String missaoId;
  final AtividadeStatus? status;
  final DateTime? startedAt;

  AtribuirMissaoRequest({required this.missaoId, this.status, this.startedAt});

  Map<String, dynamic> toJson() {
    return {
      'missaoId': missaoId,
      if (status != null) 'status': status!.apiValue,
      if (startedAt != null) 'startedAt': startedAt!.toIso8601String(),
    };
  }
}

/// DTO para atualizar status de atividade
class UpdateAtividadeRequest {
  final AtividadeStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;

  UpdateAtividadeRequest({
    required this.status,
    this.startedAt,
    this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status.apiValue,
      if (startedAt != null) 'startedAt': startedAt!.toIso8601String(),
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
    };
  }
}
