# Como Integrar as Missões no main.dart / Home Page

Este guia mostra EXATAMENTE onde adicionar os componentes de missões no seu app.

---

## 📍 Passo 1: Adicionar Imports

No topo do seu `main.dart` ou arquivo da home page, adicione:

```dart
// Novos imports para missões
import 'package:procel/components/resumo_missoes_widget.dart';
import 'package:procel/components/proximas_missoes_widget.dart';
import 'package:procel/pages/missoes/missoes_improved_page.dart';
import 'package:procel/providers/missao_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';  // Se ainda não tiver
```

---

## 🏠 Passo 2: Se estiver usando ConsumerWidget na Home

Certifique-se de que sua home page está como `ConsumerWidget` e não `StatelessWidget`:

```dart
// ❌ ANTES
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ...
  }
}

// ✅ DEPOIS
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Agora você tem acesso ao ref para Riverpod
    // ...
  }
}
```

---

## 📊 Passo 3: Adicionar Widgets na Home

Dentro do `build()` da home, adicione os widgets de missões. Exemplo de estrutura:

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  return SingleChildScrollView(
    child: Column(
      children: [
        // Conteúdo existente da home...
        
        // ===== NOVO: Seção de Missões =====
        SizedBox(height: 24),
        
        // Widget 1: Resumo com contadores
        ResumoMissoesWidget(),
        
        SizedBox(height: 16),
        
        // Widget 2: Próximas 3 missões em destaque
        ProximasMissoesWidget(maxMissoes: 3),
        
        SizedBox(height: 16),
        
        // Widget 3: Botão para abrir página completa
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
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
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 48),
            ),
          ),
        ),
        
        SizedBox(height: 24),
        
        // Resto do conteúdo da home...
      ],
    ),
  );
}
```

---

## 📱 Passo 4: Integração com TabBar/Navigation (Se usarem)

Se estão usando um `ShellPage` ou `CupertinoTabScaffold` com múltiplas telas:

```dart
// Adicionar nova aba para missões

CupertinoTabScaffold(
  tabBar: CupertinoTabBar(
    items: [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      // ✅ NOVO: Aba de Missões
      BottomNavigationBarItem(
        icon: Icon(Icons.videogame_asset),
        label: 'Missões',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.leaderboard),
        label: 'Ranking',
      ),
      // ... outras abas
    ],
  ),
  tabBuilder: (context, index) {
    switch (index) {
      case 0:
        return CupertinoTabView(
          builder: (_) => HomeScreen(),
          defaultTitle: 'Home',
        );
      
      // ✅ NOVO: Case para missões
      case 1:
        return CupertinoTabView(
          builder: (_) => MissoesImprovedPage(
            gamificationState: context.read<GamificationState>(),
          ),
          defaultTitle: 'Missões',
        );
      
      case 2:
        return CupertinoTabView(
          builder: (_) => RankingScreen(),
          defaultTitle: 'Ranking',
        );
      
      default:
        return Container();
    }
  },
);
```

---

## 🔄 Passo 5: Sincronizar Pontos ao Concluir

Se tiver uma ação customizada para concluir missão, certifique-se de sincronizar:

```dart
// Ao concluir uma missão
final notifier = ref.read(missaoNotifierProvider.notifier);
await notifier.concluirMissao(pessoaId, atividadeId);

// ✅ IMPORTANTE: Sincronizar pontos
context.read<GamificationState>().loadFromBackend();

// Invalidar dados em cache
ref.invalidate(atividadesDaPessoaProvider(pessoaId));
```

---

## 🎮 Passo 6: Verificar Autenticação

Certifique-se de que ao fazer login, o `userId` é salvo:

```dart
// Em backend_session.dart ou login_page.dart

final result = await BackendSession.login(email, password);

// ✅ Salvar userId para provider de auth
final prefs = await SharedPreferences.getInstance();
await prefs.setString('backend_user_id', result.userId);

// Já deve existir:
await prefs.setString('procel_backend_access_token', result.accessToken);
```

---

## ✅ Passo 7: Testar

1. Execute o app
2. Faça login
3. Na home, deverá ver:
   - ✅ Resumo de missões (contadores)
   - ✅ Próximas 3 missões
   - ✅ Botão "Ver Todas as Missões"
4. Clique no botão para abrir página completa com 4 tabs
5. Teste atribuir/iniciar/concluir uma missão
6. Verifique se pontos estão sendo atualizados no XP

---

## 🎨 Opcional: Customização de Cores/Temas

Se quiser customizar as cores dos widgets:

```dart
// ResumoMissoesWidget() aceita um tema do Material
// MissoesImprovedPage() usa cores padrão

// Se precisar customizar, edite os arquivos:
// lib/components/resumo_missoes_widget.dart
// lib/components/proximas_missoes_widget.dart
// lib/pages/missoes/missoes_improved_page.dart
```

---

## 🔗 Estrutura de Pastas Esperada

```
lib/
├── models/
│   └── missao_model.dart              ✅ Criado
├── services/
│   ├── missao_service.dart            ✅ Criado
│   ├── missoes_gamificacao_service.dart ✅ Criado
│   └── gamification_state.dart        (existente)
├── providers/
│   ├── auth_provider.dart             ✅ Criado
│   └── missao_provider.dart           ✅ Criado
├── pages/
│   └── missoes/
│       └── missoes_improved_page.dart ✅ Criado
├── components/
│   ├── missoes_lista_widget.dart      ✅ Criado
│   ├── proximas_missoes_widget.dart   ✅ Criado
│   └── resumo_missoes_widget.dart     ✅ Criado
├── examples/
│   └── missoes_integration_examples.dart ✅ Referência
└── main.dart                          (você modifica)
```

---

## 📋 Checklist Final

- [ ] Todos os imports adicionados
- [ ] Home page convertida para ConsumerWidget (se necessário)
- [ ] ResumoMissoesWidget adicionado na home
- [ ] ProximasMissoesWidget adicionado na home
- [ ] Botão "Ver Todas as Missões" adicionado
- [ ] MissoesImprovedPage acessível
- [ ] userId está sendo salvo ao fazer login
- [ ] Testou atribuir nova missão
- [ ] Testou iniciar missão
- [ ] Testou concluir missão
- [ ] Verificou que pontos XP estão atualizando
- [ ] Testou as 4 tabs da página de missões

---

## 🐛 Erros Comuns

### Erro: "The getter 'userId' was called on null."
**Causa:** userId não está sendo obtido do SharedPreferences  
**Solução:** Verifique se o login está salvando `backend_user_id`

### Erro: "MissaoService não encontrado"
**Causa:** Import faltando  
**Solução:** Adicione `import 'package:procel/services/missao_service.dart';`

### Widget não aparece na tela
**Causa:** ResumoMissoesWidget ou ProximasMissoesWidget retorna `SizedBox.shrink()`  
**Solução:** Verifique se o authData não é null e se userId está disponível

### "No provider found for 'missaoNotifierProvider'"
**Causa:** Não está usando ConsumerWidget  
**Solução:** Converta a classe para `ConsumerWidget` ao invés de `StatelessWidget`

---

## 📞 Suporte

Se tiver dúvidas:

1. Verifique [docs/INTEGRACAO_MISSOES.md](../docs/INTEGRACAO_MISSOES.md) para guia completo
2. Veja exemplos em [lib/examples/missoes_integration_examples.dart](../examples/missoes_integration_examples.dart)
3. Consulte o resumo em [docs/MISSOES_RESUMO_IMPLEMENTACAO.md](MISSOES_RESUMO_IMPLEMENTACAO.md)

---

**Pronto! Agora você tem um sistema completo de missões no app! 🎮✨**
