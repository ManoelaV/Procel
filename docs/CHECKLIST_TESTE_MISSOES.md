# 🧪 Checklist de Testes - Sistema de Missões

Agora você pode testar as funcionalidades novas! Siga este checklist:

---

## ✅ Teste 1: Login e Autenticação

```
1. Abra o app
2. Faça login com suas credenciais
3. Verifique se chegou na home
```

**Esperado:** ✅ Login funciona e você está autenticado

---

## ✅ Teste 2: Ir para Aba de Missões

```
1. Clique na aba "Missões" (segundo tab)
2. Você deve ver dois widgets novos:
   - 📊 Resumo de Missões (com contadores)
   - ⏰ Próximas Missões (lista compacta)
3. Também deve ver um botão: "Ver Todas as Missões"
```

**Esperado:** 
- ✅ Os widgets aparecem corretamente
- ✅ Contadores mostram: Pendentes, Em Andamento, Concluídas
- ✅ Próximas 3-5 missões aparecem em lista

---

## ✅ Teste 3: Clicar no Botão "Ver Todas as Missões"

```
1. Na aba de Missões, clique em "Ver Todas as Missões"
2. Você deve ser redirecionado para página com 4 tabs:
   - 📅 Pendentes
   - ▶️ Em Andamento
   - ✅ Concluídas
   - ➕ Disponíveis
```

**Esperado:**
- ✅ Página abre sem erros
- ✅ 4 tabs visíveis no topo
- ✅ Cada tab mostra missões diferentes

---

## ✅ Teste 4: Atribuir Nova Missão

```
1. Na página de missões, vá para aba "Disponíveis" (última tab)
2. Clique em "Atribuir" em qualquer missão
3. Deve retornar para home ou mostrar sucesso
```

**Esperado:**
- ✅ Missão é adicionada
- ✅ Mensagem de sucesso aparece
- ✅ Missão aparece em "Pendentes" depois

---

## ✅ Teste 5: Iniciar Missão

```
1. Vá para tab "Pendentes"
2. Clique no botão "Iniciar" de uma missão
3. Observe a mudança de status
```

**Esperado:**
- ✅ Status muda para "Em Andamento"
- ✅ Missão sai de "Pendentes" e aparece em "Em Andamento"
- ✅ Botão muda de "Iniciar" para "Concluir"

---

## ✅ Teste 6: Concluir Missão

```
1. Na tab "Em Andamento", clique em "Concluir" 
2. Observe se pontos XP são atualizados
3. Verifique se missão move para "Concluídas"
```

**Esperado:**
- ✅ Missão é marcada como concluída
- ✅ Você ganha XP (deve aparecer notificação)
- ✅ Level pode aumentar se XP suficiente
- ✅ Missão aparece em "Concluídas" com checkmark verde

---

## ✅ Teste 7: Home Page Atualizada

```
1. Volte para home (Home tab)
2. Scrolle para baixo
3. Procure por widgets de missões
```

**Esperado:**
- ✅ Você vê resumo das missões (pode estar na lista junto com outras coisas)
- ✅ Próximas missões aparecem em destaque

---

## ✅ Teste 8: Sincronização de Pontos

```
1. Anote seu XP atual (antes de concluir)
2. Concluir uma missão
3. Verifique se XP aumentou
4. Você pode checar no Perfil tab
```

**Esperado:**
- ✅ XP aumenta quando completa missão
- ✅ Coins podem aumentar também
- ✅ Level pode mudar

---

## 🐛 Possíveis Problemas e Soluções

### Problema: "Erro ao carregar missões"
**Solução:** Verifique se:
- ✅ Está conectado à internet
- ✅ Backend está rodando (verifique na home o status)
- ✅ Token é válido

### Problema: userId é null
**Solução:** Faça logout completo e login novamente para resalvar userId

### Problema: "No provider found for X"
**Solução:** Reconstrua o app (hot restart):
```
Pressione r na console do Flutter
```

### Problema: Widgets não aparecem
**Solução:** Verifique se está na aba correta (segunda aba: "Missões")

---

## 📱 Fluxo Completo de Teste

Siga este ordem para testar tudo:

```
1. Login ✅ (Teste 1)
   ↓
2. Ir para Missões ✅ (Teste 2)
   ↓
3. Ver todos os widgets ✅ (Teste 3)
   ↓
4. Atribuir nova missão ✅ (Teste 4)
   ↓
5. Iniciar missão ✅ (Teste 5)
   ↓
6. Concluir e ganhar pontos ✅ (Teste 6)
   ↓
7. Verificar home com resumo ✅ (Teste 7)
   ↓
8. Confirmar sincronização XP ✅ (Teste 8)
```

---

## ✨ Novo! Integrado no Main

### Mudanças Feitas no main.dart:
- ✅ Adicionado `flutter_riverpod` para gerenciamento de estado
- ✅ Envolvido app com `ProviderScope`
- ✅ Convertido `MissionsScreen` para `ConsumerWidget`
- ✅ Substituído conteúdo de `_MissionsBody` pelos novos componentes
- ✅ Adicionado botão "Ver Todas as Missões"

### Mudanças Feitas em backend_session.dart:
- ✅ Adicionado `saveUserId()` para persistir userId
- ✅ Adicionado `restoreUserId()` para recuperar userId
- ✅ Login agora salva userId automaticamente

---

## 📊 O Que Testa

Esta integração testa:
- ✅ Riverpod integration
- ✅ Provider pattern com Consumer widget
- ✅ HTTP requests ao backend
- ✅ Error handling
- ✅ State synchronization
- ✅ Navigation entre telas
- ✅ Gamification sync
- ✅ Auth flow

---

## 🎉 Sucesso!

Se todos os testes passarem, o sistema de missões está **100% funcional** e pronto para produção!

**Próximos passos (opcional):**
- [ ] Adicionar animações ao concluir
- [ ] Notificações push
- [ ] Histórico detalhado
- [ ] Sharing de missões

---

**Bora testar! 🚀**
