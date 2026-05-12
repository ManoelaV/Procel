# Integração de Missões do Backend

Este guia explica como usar o novo sistema de missões integrado com o backend Java/Spring Boot.

## ⚡ Quick Start

### 1. Obter userId do usuário logado
```dart
final authData = await ref.watch(authDataProvider.future);
final userId = authData?.userId; // ou pessoaId
```

### 2. Exibir próximas missões na home
```dart
ProximasMissoesWidget()
```

### 3. Exibir resumo de missões
```dart
ResumoMissoesWidget()
```

### 4. Exibir página completa de missões com todas as funcionalidades
```dart
MissoesImprovedPage(gamificationState: context.read<GamificationState>())
```

---

## 📁 Arquivos Criados / Modificados

### Providers (`lib/providers/`)
- `auth_provider.dart` - obter userId/token do usuário logado
- `missao_provider.dart` - providers Riverpod para missões

### Services (`lib/services/`)
- `missao_service.dart` - chamadas HTTP aos endpoints
- `missoes_gamificacao_service.dart` - integração com gamificação

### Pages (`lib/pages/`)
- `missoes/missoes_improved_page.dart` - página completa com tabs

### Components (`lib/components/`)
- `missoes_lista_widget.dart` - lista básica de missões
- `proximas_missoes_widget.dart` - widget compacto para home
- `resumo_missoes_widget.dart` - resumo visual/contadores

### Models (`lib/models/`)
- `missao_model.dart` - modelos Dart + DTOs

---

## 📋 Estrutura

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

---

## 🔌 Providers (Riverpod)

### Autenticação
```dart
// Obter userId do usuário logado
final userId = await ref.watch(userIdProvider.future);

// Obter token de acesso
final token = await ref.watch(accessTokenProvider.future);

// Obter dados completos de auth
final authData = await ref.watch(authDataProvider.future);
// authData.userId, authData.accessToken, authData.displayName, authData.email
```

### Missões
```dart
// Lista de missões ativas do catálogo
ref.watch(missoesCatalogoProvider);

// Todas as atividades de uma pessoa
ref.watch(atividadesDaPessoaProvider(pessoaId));

// Atividades por status
ref.watch(atividadesPendentesProvider(pessoaId));
ref.watch(atividadesEmAndamentoProvider(pessoaId));
ref.watch(atividadesConcluidasProvider(pessoaId));

// StateNotifier para gerenciar ações
final notifier = ref.read(missaoNotifierProvider.notifier);
```

---

## 🎮 Serviços (Services)

### MissaoService
Responsável por chamadas HTTP diretas aos endpoints.

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

// Atribuir missão a pessoa
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

### MissoesGamificacaoService
Integração entre missões e gamificação, com sincronização de pontos.

```dart
final service = MissoesGamificacaoService(
  missaoService: MissaoService(),
  gamificationState: context.read<GamificationState>(),
);

// Iniciar e sincronizar gamificação
await service.iniciarMissao(pessoaId, atividadeId);

// Concluir com recompensa
await service.concluirMissao(
  pessoaId,
  atividadeId,
  rewardXp: 25,
  rewardCoins: 10,
);

// Obter resumo de atividades
final resumo = await service.obterResumoAtividades(pessoaId);
// resumo: {total, pendentes, em_andamento, concluidas, canceladas}
```

---

## 📱 Componentes UI

### ProximasMissoesWidget
Exibe as próximas 3 missões em andamento (ideal para home page).

```dart
ProximasMissoesWidget(
  maxMissoes: 3, // quantidade máxima
)
```

### ResumoMissoesWidget
Exibe contadores visuais de missões por status.

```dart
ResumoMissoesWidget()
```

### MissoesImprovedPage
Página completa com 4 tabs:
- **Pendentes** - missões ainda não iniciadas
- **Em Andamento** - missões em execução
- **Concluídas** - missões finalizadas
- **Disponíveis** - catálogo de novas missões para atribuir

```dart
MissoesImprovedPage(
  gamificationState: context.read<GamificationState>(),
)
```

### MissoesListaWidget (básico)
Component simples apenas listando missões.

```dart
MissoesListaWidget(
  pessoaId: userId,
  gamificationState: gamState, // opcional
)
```

---

## 🎯 Fluxos de Uso

### Fluxo 1: Exibir Missões na Home

```dart
// Na home page
@override
Widget build(BuildContext context, WidgetRef ref) {
  return Scaffold(
    appBar: AppBar(title: Text('Home')),
    body: SingleChildScrollView(
      child: Column(
        children: [
          // Outros widgets da home...
          ResumoMissoesWidget(),
          ProximasMissoesWidget(maxMissoes: 3),
        ],
      ),
    ),
  );
}
```

### Fluxo 2: Iniciar Missão

```dart
final notifier = ref.read(missaoNotifierProvider.notifier);

try {
  final resultado = await notifier.iniciarMissao(
    pessoaId,
    atividadeId,
  );
  
  // Recarregar dados
  ref.invalidate(atividadesEmAndamentoProvider(pessoaId));
  
  // Mostrar feedback
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Missão iniciada!'))
  );
} catch (e) {
  // Tratar erro
}
```

### Fluxo 3: Concluir Missão e Ganhar Pontos

```dart
final notifier = ref.read(missaoNotifierProvider.notifier);

try {
  await notifier.concluirMissao(
    pessoaId,
    atividadeId,
    rewardXp: 25,    // Pontos XP ganhos
    rewardCoins: 10, // Moedas ganhas
  );
  
  // Recarregar
  ref.invalidate(atividadesDaPessoaProvider(pessoaId));
  
  // Sincronizar gamificação
  context.read<GamificationState>().loadFromBackend();
  
  // Feedback
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('🎉 +25 XP +10 Moedas'),
      backgroundColor: Colors.green,
    ),
  );
} catch (e) {
  // Tratar erro
}
```

### Fluxo 4: Atribuir Nova Missão

```dart
// Ir para aba "Disponíveis" em MissoesImprovedPage
// Ou atribuir programaticamente:

final notifier = ref.read(missaoNotifierProvider.notifier);
await notifier.atribuirMissao(pessoaId, missaoId);

ref.invalidate(atividadesDaPessoaProvider(pessoaId));
ref.invalidate(missoesCatalogoProvider);
```

---

## 🔗 Endpoints do Backend

```
GET  /api/missoes
     Lista todas as missões ativas
     Query: ?ativo=true

GET  /api/missoes/{missaoId}
     Detalhe de uma missão

POST /api/pessoas/{pessoaId}/atividades
     Atribui uma missão a uma pessoa
     Body: { "missaoId": "uuid" }
     
GET  /api/pessoas/{pessoaId}/atividades
     Lista atividades da pessoa
     Query: ?status=PENDENTE|EM_ANDAMENTO|CONCLUIDA|CANCELADA

GET  /api/pessoas/{pessoaId}/atividades/{atividadeId}
     Detalhe de uma atividade

PUT  /api/pessoas/{pessoaId}/atividades/{atividadeId}
     Atualiza status e timestamps
     Body: {
       "status": "EM_ANDAMENTO",
       "startedAt": "2026-05-12T10:30:00Z",
       "completedAt": null
     }
     
DELETE /api/pessoas/{pessoaId}/atividades/{atividadeId}
       Remove uma atividade
```

---

## 💡 Boas Práticas

1. **Sempre invalidar providers após ação**
   ```dart
   ref.invalidate(atividadesDaPessoaProvider(pessoaId));
   ```

2. **Sincronizar gamificação após concluir**
   ```dart
   context.read<GamificationState>().loadFromBackend();
   ```

3. **Usar AuthData para obter userId**
   ```dart
   final authData = await ref.watch(authDataProvider.future);
   if (authData != null) { ... }
   ```

4. **Mostrar feedback visual ao usuário**
   - SnackBar com mensagem
   - Animação de conclusão
   - Atualizar contadores visualmente

5. **Tratar erros adequadamente**
   ```dart
   try {
     // ação
   } catch (e) {
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Erro: $e'))
     );
   }
   ```

---

## 🔄 Sincronização com Gamificação

Quando uma missão é concluída:

1. `notifier.concluirMissao()` → endpoint do backend atualiza pontos
2. `gamificationState.loadFromBackend()` → puxa dados atualizados
3. UI é notificada e exibe novo XP/coins
4. Badges são desbloqueadas automaticamente se threshold atingido

---

## 📚 Exemplo Completo em Widget

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/components/proximas_missoes_widget.dart';
import '/components/resumo_missoes_widget.dart';
import '/pages/missoes/missoes_improved_page.dart';
import '/services/gamification_state.dart';

class MinhaHomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Resumo de missões
            ResumoMissoesWidget(),
            
            // Próximas missões em destaque
            ProximasMissoesWidget(maxMissoes: 3),
            
            // Botão para abrir página completa
            Padding(
              padding: EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MissoesImprovedPage(
                        gamificationState: context.read<GamificationState>(),
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.list),
                label: Text('Ver Todas as Missões'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## ✅ Checklist de Integração

- [ ] Adicionar `auth_provider.dart` ao projeto
- [ ] Adicionar `missao_provider.dart` ao projeto
- [ ] Adicionar `MissaoService` ao projeto
- [ ] Adicionar `MissoesGamificacaoService` ao projeto
- [ ] Adicionar `ProximasMissoesWidget` na home page
- [ ] Adicionar `ResumoMissoesWidget` na home page
- [ ] Criar rota para `MissoesImprovedPage`
- [ ] Testar fluxo completo (atribuir → iniciar → concluir)
- [ ] Verificar sincronização de pontos/XP
- [ ] Validar que userId está sendo salvo ao fazer login

---

## 🐛 Troubleshooting

### "userId é null"
Certifique-se de que o login salvou o `backend_user_id` em SharedPreferences:
```dart
await prefs.setString('backend_user_id', result.userId);
```

### "Erro ao carregar atividades"
Verifique se o token de acesso está válido:
```dart
final token = await ref.watch(accessTokenProvider.future);
print('Token: $token'); // Deve não ser null
```

### "Pontos não estão atualizando"
Após concluir, chame `loadFromBackend()`:
```dart
context.read<GamificationState>().loadFromBackend();
```
