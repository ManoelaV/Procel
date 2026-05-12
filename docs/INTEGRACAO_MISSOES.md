# Integração de Missões do Backend

Este guia explica como usar o novo sistema de missões integrado com o backend Java/Spring Boot.

## Estrutura

### Modelos (`lib/models/missao_model.dart`)

#### `Missao`
Representa um catálogo de missão (template reutilizável).

```dart
Missao {
  id: String,              // UUID
  titulo: String,          // Título da missão
  descricao: String,       // Descrição detalhada
  ativo: bool,             // Se pode ser atribuída
  createdAt: DateTime      // Data de criação
}
```

#### `PessoaMissao`
Representa uma atividade (instância de uma missão atribuída a uma pessoa).

```dart
PessoaMissao {
  id: String,              // UUID único da atividade
  pessoaId: String,        // ID da pessoa
  missaoId: String,        // ID da missão
  status: AtividadeStatus, // PENDENTE, EM_ANDAMENTO, CONCLUIDA, CANCELADA
  assignedAt: DateTime,    // Quando foi atribuída
  startedAt: DateTime?,    // Quando iniciou (null se não iniciou)
  completedAt: DateTime?,  // Quando concluiu (null se não concluiu)
  
  // Dados preenchidos para exibição
  missaoTitulo: String?,
  missaoDescricao: String?,
  pessoaNome: String?
}
```

#### `AtividadeStatus`
Estado de uma atividade com métodos auxiliares:

- `PENDENTE` → `isPending`
- `EM_ANDAMENTO` → `isInProgress`
- `CONCLUIDA` → `isCompleted`
- `CANCELADA` → `isCanceled`

### Service (`lib/services/missao_service.dart`)

Responsável por todas as chamadas HTTP aos endpoints de missões.

```dart
final service = MissaoService();

// Listar missões ativas
final missoes = await service.listarMissoes(ativo: true);

// Listar atividades de uma pessoa
final atividades = await service.listarAtividadesDaPessoa(pessoaId);

// Obter atividades por status
final pendentes = await service.listarAtividadesDaPessoa(
  pessoaId,
  status: AtividadeStatus.pendente,
);

// Atribuir missão
final atividade = await service.atribuirMissaoAPessoa(
  pessoaId,
  AtribuirMissaoRequest(missaoId: 'uuid-da-missao'),
);

// Iniciar missão
await service.iniciarMissao(pessoaId, atividadeId);

// Concluir missão
await service.concluirMissao(pessoaId, atividadeId);

// Cancelar atividade
await service.cancelarAtividade(pessoaId, atividadeId);

// Remover atividade
await service.removerAtividade(pessoaId, atividadeId);
```

### Providers (`lib/providers/missao_provider.dart`)

Usa Riverpod para gerenciar o estado reativo das missões.

#### Providers de Leitura (FutureProvider)
```dart
// Lista de missões ativas (catálogo)
ref.watch(missoesCatalogoProvider);

// Todas as atividades da pessoa
ref.watch(atividadesDaPessoaProvider(pessoaId));

// Atividades por status específico
ref.watch(atividadesPendentesProvider(pessoaId));
ref.watch(atividadesEmAndamentoProvider(pessoaId));
ref.watch(atividadesConcluidasProvider(pessoaId));
```

#### StateNotifier (MissaoNotifier)
```dart
final notifier = ref.read(missaoNotifierProvider.notifier);

// Iniciar uma missão
await notifier.iniciarMissao(pessoaId, atividadeId);

// Concluir missão (com pontuação)
await notifier.concluirMissao(
  pessoaId,
  atividadeId,
  rewardXp: 10,      // Pontos XP ganhos
  rewardCoins: 5,    // Moedas ganhas
);

// Cancelar atividade
await notifier.cancelarAtividade(pessoaId, atividadeId);

// Remover atividade
await notifier.removerAtividade(pessoaId, atividadeId);

// Atribuir missão
await notifier.atribuirMissao(pessoaId, missaoId);
```

### Component UI (`lib/components/missoes_lista_widget.dart`)

Widget pronto para usar que exibe a lista de missões com botões de ação.

```dart
MissoesListaWidget(
  pessoaId: userId,
  gamificationState: gamState, // opcional
)
```

## Fluxo de Uso

### 1. Exibir Catálogo de Missões Disponíveis

```dart
final catalogoAsync = ref.watch(missoesCatalogoProvider);

catalogoAsync.when(
  data: (missoes) {
    // Exibir lista de missões disponíveis
    // Cada uma pode ser atribuída ao usuário via "Atribuir" button
  },
  loading: () => CircularProgressIndicator(),
  error: (e, _) => Text('Erro: $e'),
);
```

### 2. Listar Atividades do Usuário

```dart
final atividadesAsync = ref.watch(
  atividadesDaPessoaProvider(pessoaId),
);

atividadesAsync.when(
  data: (atividades) {
    // atividades é uma List<PessoaMissao>
    // Exibir com status, botões de ação, etc
  },
);
```

### 3. Iniciar uma Missão

```dart
final notifier = ref.read(missaoNotifierProvider.notifier);

try {
  final atividadeAtualizada = await notifier.iniciarMissao(
    pessoaId,
    atividadeId,
  );
  
  // Recarregar lista
  ref.invalidate(atividadesDaPessoaProvider(pessoaId));
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Missão iniciada!'))
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Erro: $e'))
  );
}
```

### 4. Concluir uma Missão (Subir Pontos)

Quando o usuário conclui uma missão:

```dart
final notifier = ref.read(missaoNotifierProvider.notifier);

try {
  final atividadeAtualizada = await notifier.concluirMissao(
    pessoaId,
    atividadeId,
    rewardXp: 25,    // Define quantos XP ganha
    rewardCoins: 10, // Define quantas moedas ganha
  );
  
  // Recarregar dados de gamificação e atividades
  ref.invalidate(atividadesDaPessoaProvider(pessoaId));
  gamificationState?.loadFromBackend(); // Opcional
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Parabéns! +25 XP +10 Moedas'),
      backgroundColor: Colors.green,
    ),
  );
} catch (e) {
  // Tratar erro
}
```

## Integração com Gamificação

O sistema de pontos é gerenciado pelo endpoint `/api/gamification/me/missions/{missionKey}/complete` do backend.

Ao chamar `concluirMissao()`, a pontuação é automaticamente atualizada. Para sincronizar a UI:

```dart
// Após concluir uma missão
await notifier.concluirMissao(pessoaId, atividadeId);

// Recarregar estado de gamificação
if (gamificationState != null) {
  await gamificationState.loadFromBackend();
}

// Notificar listeners
ref.invalidate(atividadesDaPessoaProvider(pessoaId));
```

## Endpoints do Backend

```
GET  /api/missoes
     Lista todas as missões ativas

GET  /api/missoes/{missaoId}
     Detalhe de uma missão

POST /api/pessoas/{pessoaId}/atividades
     Atribui uma missão a uma pessoa
     
GET  /api/pessoas/{pessoaId}/atividades
     Lista atividades da pessoa
     (suporta query param: ?status=PENDENTE)

GET  /api/pessoas/{pessoaId}/atividades/{atividadeId}
     Detalhe de uma atividade

PUT  /api/pessoas/{pessoaId}/atividades/{atividadeId}
     Atualiza status e timestamps
     
DELETE /api/pessoas/{pessoaId}/atividades/{atividadeId}
       Remove uma atividade
```

## Exemplo Completo em Widget

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/components/missoes_lista_widget.dart';

class MinhasPaginaDeMissoes extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = 'usuario-id-aqui'; // Obter do auth
    
    return Scaffold(
      appBar: AppBar(title: Text('Minhas Missões')),
      body: MissoesListaWidget(
        pessoaId: userId,
      ),
    );
  }
}
```

## Próximos Passos

1. **Integrar com autenticação** - obter `pessoaId` do usuário logado
2. **Criar tela de catálogo** - mostrar missões disponíveis para atribuir
3. **Adicionar recompensas** - mostrar XP/moedas ganhas ao concluir
4. **Histórico** - listar missões concluídas com datas
5. **Filters e sorting** - ordenar por status, data, etc
