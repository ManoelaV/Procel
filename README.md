# PROCEL - Aplicativo de Economia de Energia Gamificado

> **Documentação completa do frontend Flutter**

PROCEL é uma aplicação mobile desenvolvida em Flutter que ajuda usuários a monitorar e economizar energia de forma gamificada. O app se comunica com um back-end Java/Spring Boot separado (submodule em `backend-repo/`) e mantém integração com Firebase para recursos legados.

---

## Índice da Documentação

1. [Arquitetura do Frontend](#-arquitetura-do-frontend)
2. [Configuração e Execução](#-configuração-e-execução)
3. [State Management](#-state-management)
4. [Autenticação](#-autenticação)
5. [Gamificação](#-gamificação)
6. [Missões](#-missões)
7. [Chatbot de Notificações](#-chatbot-de-notificações)
8. [Upload de PDF e Localização de Salas](#-upload-de-pdf-e-localização-de-salas)
9. [Backend & Endpoints](#-backend--endpoints)
10. [Estrutura de Pastas](#-estrutura-de-pastas)
11. [Como Contribuir](#-como-contribuir)

---

## Arquitetura do Frontend

```
┌─────────────────────────────────────────────────────────────────┐
│                    Flutter UI Layer                            │
│  ┌─────────────┐  ┌──────────────────┐  ┌───────────────────┐   │
│  │ Pages       │  │ Components       │  │ ChatPage          │   │
│  │ (Telas)     │  │ (Widgets)        │  │ (Chatbot UI)      │   │
└─────────────────────────────────────────────────────────────────┘
           │                    │                     │
           ▼                    ▼                     ▼
┌─────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│ Providers       │  │ GamificationState│  │ ChatbotService   │
│ (Riverpod 2)    │  │ (Provider/CLN)   │  │ (HTTP → Bot)     │
└─────────────────┘  └────────┬─────────┘  └────────┬─────────┘
                              │                     │
                              ▼                     ▼
                      ┌──────────────────┐  ┌──────────────────┐
                      │ BackendSession   │  │ CHATBOT_BASE_URL │
                      │ (SharedPreferences│  │ (porta 8000)     │
                      │ + JWT)           │  └──────────────────┘
                      └────────┬──────────┘
                               │
                               ▼
                      ┌──────────────────┐
                      │  API_BASE_URL    │
                      │ (Spring Boot)    │
                      └──────────────────┘
```

### Padrões de projeto

- **State Management híbrido**:
  - **Riverpod 2** (`flutter_riverpod: ^2.4.10`) — providers de dados assíncronos
  - **Provider** (`provider: ^6.1.5+1`) — `GamificationState` reativo via `ChangeNotifier`
- **Service Layer**: serviços encapsulam lógica de negócio e chamadas de API
- **Model Layer**: DTOs (`Missao`, `PessoaMissao`, `Room`, `TimetableEntry`, `BackendLoginResult`)

---

## Configuração e Execução

### Dependências principais

| Pacote | Uso |
|---|---|
| `flutter_riverpod` ^2.4.10 | State management |
| `provider` ^6.1.5+1 | GamificationState reativo |
| `http` ^0.13.6 | Chamadas HTTP ao backend |
| `dio` ^5.4.0 | Cliente HTTP (MissaoService) |
| `shared_preferences` ^2.2.2 | Armazenamento local |
| `file_picker` ^8.0.0 | Seleção de arquivos PDF |
| `syncfusion_flutter_pdf` ^24.1.46 | Extração de texto PDF |

### Instalação

```bash
git clone https://github.com/ManoelaV/Procel.git
cd Procel
git submodule update --init --recursive
flutter pub get
```

### Executar

```bash
# Ambiente remoto (recomendado)
flutter run --dart-define=API_BASE_URL=https://procel.servehttp.com

# Ambiente local
flutter run --dart-define=API_BASE_URL=http://localhost:8080
```

### Compilar para Produção

```bash
flutter build apk --release   # Android
flutter build ios --release   # iOS
flutter build web             # Web
```

---

## State Management

### Riverpod (providers principais)

| Provider | Tipo | Descrição |
|---|---|---|
| `userIdProvider` | `FutureProvider<String?>` | userId do SharedPreferences |
| `accessTokenProvider` | `FutureProvider<String?>` | JWT do SharedPreferences |
| `isAuthenticatedProvider` | `FutureProvider<bool>` | Verifica sessão válida |
| `authDataProvider` | `FutureProvider<AuthData?>` | Dados completos (id, token, nome, email) |
| `missaoServiceProvider` | `Provider<MissaoService>` | Instância do serviço de missões |
| `missoesCatalogoProvider` | `FutureProvider<List<Missao>>` | Lista missões ativas |
| `atividadesDaPessoaProvider(id)` | `FutureProvider.family` | Todas as atividades do usuário |
| `atividadesPendentesProvider(id)` | `FutureProvider.family` | Apenas pendentes |
| `atividadesEmAndamentoProvider(id)` | `FutureProvider.family` | Apenas em andamento |
| `atividadesConcluidasProvider(id)` | `FutureProvider.family` | Apenas concluídas |
| `missaoNotifierProvider` | `StateNotifierProvider` | Ações: iniciar, concluir, cancelar, atribuir |

### Provider (gamification_state)

- **`GamificationState`** (`ChangeNotifier`) — estado global: missões, badges, XP, coins, streak, consumo

---

## Autenticação

### Fluxo completo

1. **App inicia** → `BackendSession.restoreToken()` no `main()` (`lib/main.dart`)
2. **Login/Register** → `BackendSession.login()` / `.registerAndLogin()`
   - Salva: `accessToken`, `userId`, `email`, `displayName` no SharedPreferences
3. **Proteção de rotas** → `authDataProvider` retorna `null` se não logado

### Arquivo: `lib/services/backend_session.dart`

- Classe utilitária (métodos estáticos)
- `BackendLoginResult` — DTO com `accessToken`, `tokenType`, `userId`, `email`, `roles`
- `_isExpiredJwt(token)` — valida expiração do token JWT (base64 decode + `exp`)
- Timeout: `ApiConfig.TIMEOUT_SECONDS` (30s)

### Arquivo: `lib/pages/backend_auth_screen.dart`

- Tela de login/registro com email + password
- Navega para `ShellPage` após login bem-sucedido

---

## Gamificação

### `lib/services/gamification_state.dart`

- **`GamificationMission`** — key, título, ícone, descrição, rewardXp, rewardCoins, progresso, buttonLabel, completed
- **`GamificationBadge`** — ícone, nome, thresholdXp
- **`GamificationState`** (`ChangeNotifier`) — estado global reativo

### Missões integradas (5 missões fixas)

| Key | Título | Ícone | Reward |
|---|---|---|---|
| `luz-eficiente` | Luz Eficiente | 💡 | 25 XP + 10 coins |
| `temperatura-inteligente` | Temperatura Inteligente | ❄️ | 25 XP |
| `sensor-scout` | Sensor Scout | 🔍 | 20 XP + 5 coins |
| `hora-do-repouso` | Hora do Repouso | 🔌 | 25 XP + 10 coins |
| `educar-e-compartilhar` | Educar é Compartilhar | 💬 | 15 XP |

### Sistema de níveis

- **Thresholds XP**: `0, 1000, 2000, 3000, 5000, 7000, 10000`
- Badges desbloqueados automaticamente ao atingir thresholds
- `loadFromBackend()` sincroniza missões concluídas do backend

### Componentes de gamificação (main.dart)

- **Home screen**: cards de progresso, badges, mini badges
- **Página de perfil**: XP, coins, streak, consumo de energia

---

## Missões

### `lib/services/missao_service.dart`

- Cliente Dio com autenticação Bearer Token (via SharedPreferences)
- Todos os métodos tratam `DioException` com mensagens amigáveis

### Endpoints consumidos

| Ação | Método | Endpoint |
|---|---|---|
| Listar missões ativas | GET | `/api/missoes?ativo=true` |
| Obter missão | GET | `/api/missoes/{id}` |
| Listar atividades | GET | `/api/pessoas/{pessoaId}/atividades` |
| Atribuir missão | POST | `/api/pessoas/{pessoaId}/atividades` |
| Atualizar status | PUT | `/api/pessoas/{pessoaId}/atividades/{atividadeId}` |
| Remover atividade | DELETE | `/api/pessoas/{pessoaId}/atividades/{atividadeId}` |

### `lib/models/missao_model.dart`

- **`Missao`** — id, titulo, descricao, tipo, value, ativo, createdAt
- **`AtividadeStatus`** (enum) — pendente, emAndamento, concluida, cancelada
  - `apiValue` → strings para API: `PENDENTE`, `EM_ANDAMENTO`, `CONCLUIDA`, `CANCELADA`
- **`PessoaMissao`** — atividade atribuída ao usuário (status, timestamps, dados da missão)
- **`AtribuirMissaoRequest`** / **`UpdateAtividadeRequest`** — DTOs para criar/atualizar

### Páginas e Components

| Arquivo | Descrição |
|---|---|
| `lib/pages/missoes/missoes_improved_page.dart` | Página principal com 4 abas: Pendentes, Em Andamento, Concluídas, Disponíveis |
| `lib/components/missoes_lista_widget.dart` | Lista de missões com cards e status coloridos |
| `lib/components/proximas_missoes_widget.dart` | Missões em destaque na home (máx 3, ordenadas por prioridade) |
| `lib/components/resumo_missoes_widget.dart` | Contadores visuais + barra de progresso |

### Estados de uma missão

| Status | Badge | Ações disponíveis |
|---|---|---|
| **Pendente** | Laranja | `[Iniciar]` |
| **Em Andamento** | Azul | `[Concluir]` |
| **Concluída** | Verde | Selo (sem ações) |
| **Cancelada** | Vermelho | (sem ações) |

### `lib/providers/missao_provider.dart`

- `missaoNotifierProvider` — `StateNotifier` para ações de missões
- Invalidação automática dos providers após ações (recarrega lista)
- Integração com `GamificationState.applyMissionCompletion()`

---

## Chatbot de Notificações

### `lib/services/chatbot_service.dart`

- **`ChatbotService`** — cliente HTTP para o chatbot (porta 8000)
- **`ChatbotResponse`** — DTO da resposta do chatbot
- Usa `...?variable != null ? {key: value} : null` (null-aware spread) para campos opcionais

### Endpoints do chatbot

| Função | Método | Endpoint |
|---|---|---|
| Enviar mensagem | POST | `/chat` |
| Notificação proativa | POST | `/chat/proactive` |
| Listar personas | GET | `/personas` |
| Listar target-profiles | GET | `/target-profiles` |
| Notificações salvas | GET | `/notifications/saved` |

### Arquivo: `lib/pages/chat_page.dart`

- Interface de chat com mensagens do usuário e do bot
- Histórico de conversa
- Mensagens proativas do backend
- `withValues(alpha: ...)` para sombras (API atualizada)

---

## Upload de PDF e Localização de Salas

### Fluxo completo (PDF → sala do aluno)

```

1. Usuário seleciona PDF
   ↓
2. PdfParserService.extractTextFromBytes()
   "Extrai texto do PDF via Syncfusion"
   ↓
3. extractMatricula(text) → "22202589"
   extractPeriodoLetivo(text) → "2026/1"
   ↓
4. parseTimetableFromText(text) → List<TimetableEntry>
   "Parseia: código, turma, disciplina, dia, horário"
   ↓
5. ScheduleRoomService.fetchRoomsForSchedule(entries, matricula, periodo)
   ↓
6. Backend resolve:
   GET /api/pessoas/{matricula}/disciplinas?periodoLetivo=...
   (auto-vínculo se vazio)
   GET /api/catalog/disciplinas/{id}/periodos-aula
   ↓
7. Match: nome da disciplina (normalizado) + dia da semana + horário
   ↓
8. Resultado: Map<TimetableEntry, Room?>
```

### Arquivo: `lib/services/pdf_parser_service.dart`

- **`extractTextFromBytes(bytes)`** — extrai texto do PDF via Syncfusion
- **`extractMatricula(text)`** — regex para "Aluno XXXX - ..." no cabeçalho
- **`extractPeriodoLetivo(text)`** — regex para "2026/1" no cabeçalho
- **`parseTimetableFromText(text)`** — parse principal:
  1. Identifica seções (MANHÃ/TARDE/NOITE)
  2. Detecta cabeçalhos de dias (ex: "QuintaSegundaHorarios SextaQuartaTerca")
  3. Extrai linhas de horário (ex: "07:30-09:00")
  4. Parseia disciplinas (formato: `11100059 - T2 - CÁLCULO 2`)
  5. Cria `TimetableEntry` por disciplina/dia/horário

### Arquivo: `lib/models/timetable_entry.dart`

```dart
class TimetableEntry {
  String? turma;       // ex: "T2"
  String? disciplina;  // ex: "CÁLCULO 2"
  String? codigo;      // ex: "11100059"
  String? dia;         // ex: "Segunda"
  String? startTime;   // ex: "07:30"
  String? endTime;     // ex: "09:00"
}
```

### Arquivo: `lib/services/schedule_room_service.dart`

- **`fetchRoomsForSchedule()`** — fluxo de busca de salas:
  1. GET `/api/pessoas/{matricula}/disciplinas` — disciplinas já vinculadas
  2. Se vazio → auto-vincula via POST no catálogo
  3. GET `/api/catalog/disciplinas/{id}/periodos-aula` — horários reais com salas
  4. **Match final:**
     - Normaliza nome da disciplina (remove acentos)
     - Bate horários (início PDF < fim aula AND fim PDF > início aula)
     - Bate dia da semana (domingo=0, segunda=1, ..., sábado=6)
     - Bate turma (se especificada)
  5. Retorna `Map<TimetableEntry, Room?>`

### Arquivo: `lib/models/room_model.dart`

```dart
class Room {
  String id;
  String name;       // ex: "Sala 301"
  String? building;  // ex: "UAF1"
  String? floor;     // ex: "3º andar"
  String? type;
  int? capacity;
}
```

### Arquivo: `lib/pages/upload_pdf_rooms/upload_pdf_rooms_widget.dart`

- Tela com botão **"Enviar PDF de horários"**
- Mostra status progressivo: "Extraindo texto...", "Parseando horários...", "Buscando salas..."
- Resultado: lista com disciplina, horário, dia, sala (verde=ok, vermelho=não encontrada)

### Rotas

```dart
// lib/main.dart
routes: {
  '/upload-pdf-rooms': (context) => Scaffold(body: UploadPdfRoomsWidget()),
}
```

---

## Backend & Endpoints

### `lib/config/api_config.dart`

- **Backend base**: `--dart-define=API_BASE_URL=https://...`
- **Chatbot base**: `--dart-define=CHATBOT_BASE_URL=http://...` (default: `http://localhost:8000`)
- Timeout padrão: 30s
- Headers: JSON + Authorization (Bearer token)

### Endpoints backend

| Recurso | Tipo | Endpoint |
|---|---|---|
| Login | POST | `/api/auth/login` |
| Registro | POST | `/api/auth/register` |
| Health | GET | `/actuator/health` |
| Pessoas | GET | `/api/pessoas` |
| Gamificação | GET | `/api/gamification/me` |
| Missões | GET | `/api/missoes` |
| Salas | GET | `/api/rooms` |

### Chatbot endpoints

| Função | Método | Endpoint |
|---|---|---|
| Enviar mensagem | POST | `http://localhost:8000/chat` |
| Notificação proativa | POST | `/chat/proactive` |