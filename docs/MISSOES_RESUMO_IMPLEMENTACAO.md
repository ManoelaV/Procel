# Sistema Completo de Missões - Resumo de Implementação

## 📋 O que foi implementado

Integração completa do sistema de missões do backend Java/Spring Boot com o app Flutter, permitindo:

✅ **Listar** missões disponíveis no catálogo  
✅ **Atribuir** novas missões a usuários  
✅ **Iniciar** missões (marcar como EM_ANDAMENTO)  
✅ **Concluir** missões e ganhar pontos XP/Moedas automaticamente  
✅ **Cancelar** atividades que não serão realizadas  
✅ **Visualizar** histórico de missões por status  
✅ **Sincronizar** pontuação de gamificação com o backend  

---

## 📁 Arquivos Criados

### Modelos
- `lib/models/missao_model.dart` - Modelos Dart + DTOs (Missao, PessoaMissao, AtividadeStatus)

### Services
- `lib/services/missao_service.dart` - Chamadas HTTP aos endpoints
- `lib/services/missoes_gamificacao_service.dart` - Integração com gamificação

### Providers (Riverpod)
- `lib/providers/auth_provider.dart` - Obter userId do usuário logado
- `lib/providers/missao_provider.dart` - Estado reativo das missões

### UI Components
- `lib/components/missoes_lista_widget.dart` - Lista básica de missões
- `lib/components/proximas_missoes_widget.dart` - Próximas 3 missões (home)
- `lib/components/resumo_missoes_widget.dart` - Contadores visuais

### Pages
- `lib/pages/missoes/missoes_improved_page.dart` - Página completa com 4 tabs

### Documentação
- `docs/INTEGRACAO_MISSOES.md` - Guia completo com exemplos
- `lib/examples/missoes_integration_examples.dart` - Exemplos práticos de uso

---

## 🚀 Quick Start

### 1. Adicionar Provider ao Scaffold/App
Certifique-se de que está usando `ConsumerWidget` ao invés de `StatelessWidget`:

```dart
class MinhaApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ...
  }
}
```

### 2. Exibir Missões na Home
```dart
// Na home page
Column(
  children: [
    ResumoMissoesWidget(),           // Contadores
    ProximasMissoesWidget(),         // Próximas 3
  ],
)
```

### 3. Abrir Página de Missões
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => MissoesImprovedPage(
      gamificationState: context.read<GamificationState>(),
    ),
  ),
);
```

### 4. Concluir Missão Programaticamente
```dart
final notifier = ref.read(missaoNotifierProvider.notifier);
await notifier.concluirMissao(pessoaId, atividadeId);
context.read<GamificationState>().loadFromBackend();
```

---

## 🔌 Endpoints Utilizados

```
Backend: https://github.com/ravilon/PROCEL-Back-End

GET  /api/missoes                          - Listar missões ativas
GET  /api/missoes/{missaoId}               - Detalhe da missão

POST /api/pessoas/{pessoaId}/atividades    - Atribuir missão
GET  /api/pessoas/{pessoaId}/atividades    - Listar atividades
PUT  /api/pessoas/{pessoaId}/atividades/{id} - Atualizar status
DELETE /api/pessoas/{pessoaId}/atividades/{id} - Remover atividade
```

---

## 🎯 Arquitetura

```
┌─ Models (Missao, PessoaMissao, AtividadeStatus)
│
├─ Services (MissaoService, MissoesGamificacaoService)
│
├─ Providers (auth_provider, missao_provider)
│
├─ UI Components
│  ├─ ResumoMissoesWidget (home)
│  ├─ ProximasMissoesWidget (home)
│  ├─ MissoesListaWidget (basic)
│  └─ MissoesImprovedPage (full page)
│
└─ GamificationState (existing)
   └─ loadFromBackend() → sincroniza pontos
```

---

## 📊 Estados de uma Missão

```
PENDENTE      → Atribuída, mas não iniciada
           ↓
EM_ANDAMENTO  → Usuário começou a fazer
           ↓
CONCLUIDA     → Finalizada com sucesso (ganha pontos)

CANCELADA     → Abandonada antes de concluir
```

---

## 💾 Dados Sincronizados

Quando uma missão é concluída:

1. ✅ Status muda para CONCLUIDA
2. ✅ Backend atribui pontos (XP, Moedas)
3. ✅ `GamificationState.loadFromBackend()` sincroniza UI
4. ✅ Badges são desbloqueadas se threshold atingido
5. ✅ Nível aumenta se XP suficiente

---

## 🔑 Pontos-Chave de Implementação

### 1. Autenticação
```dart
// Obter userId do usuário logado
final authData = await ref.watch(authDataProvider.future);
final userId = authData?.userId;
```

### 2. Carregamento de Dados
```dart
// Obter todas as atividades
final atividades = await ref.watch(
  atividadesDaPessoaProvider(userId).future
);
```

### 3. Ações (Iniciar/Concluir)
```dart
final notifier = ref.read(missaoNotifierProvider.notifier);
await notifier.iniciarMissao(userId, atividadeId);
await notifier.concluirMissao(userId, atividadeId);
```

### 4. Sincronizar Gamificação
```dart
context.read<GamificationState>().loadFromBackend();
```

---

## ✨ Recursos Implementados

### Página de Missões (MissoesImprovedPage)
- **Tab Pendentes** - Missões atribuídas mas não iniciadas
- **Tab Em Andamento** - Missões em execução (botão Concluir)
- **Tab Concluídas** - Histórico de missões finalizadas
- **Tab Disponíveis** - Catálogo para atribuir novas missões

### Home Page
- **ResumoMissoesWidget** - Cards mostrando: Pendentes, Em Andamento, Concluídas
- **ProximasMissoesWidget** - Mostra as 3 próximas missões com botões rápidos
- **Barra de Progresso** - Visualização % de conclusão (Concluídas / Total)

---

## 🐛 Troubleshooting

### "Erro: userId é null"
**Solução:** Verifique se o login está salvando `backend_user_id` em SharedPreferences

### "Missões não carregam"
**Solução:** Verifique se o token está no header Authorization da requisição

### "Pontos não atualizam"
**Solução:** Chame `context.read<GamificationState>().loadFromBackend()` após concluir

---

## 📚 Recursos Adicionais

- **Guia Completo:** [docs/INTEGRACAO_MISSOES.md](../docs/INTEGRACAO_MISSOES.md)
- **Exemplos Práticos:** [lib/examples/missoes_integration_examples.dart](missoes_integration_examples.dart)
- **Backend Repo:** https://github.com/ravilon/PROCEL-Back-End

---

## 🎓 Próximos Passos (Opcionais)

1. Adicionar animações ao concluir missões
2. Notificações push ao receber nova missão
3. Compartilhamento de missões entre usuários
4. Ranking por missões concluídas
5. Sistema de desafios em grupo
6. Histórico detalhado com tempo de execução

---

## ✅ Checklist Final

- [x] Modelos Dart criados
- [x] Service HTTP implementado
- [x] Providers Riverpod configurados
- [x] Componentes UI prontos
- [x] Página de missões completa
- [x] Integração com gamificação
- [x] Documentação completa
- [x] Exemplos práticos fornecidos
- [x] Tudo commitado no main branch

**Pronto para usar! 🚀**
