# PROCEL - Aplicativo de Economia de Energia

## O que é PROCEL?

PROCEL é uma aplicação mobile desenvolvida em Flutter que ajuda usuários a monitorar e economizar energia de forma gamificada. O app conversa com um back-end Java separado, hospedado neste repositório como submodule, e ainda mantém a camada Firebase para recursos legados e de suporte.

## O que já foi implementado?

### Estrutura Base
- Projeto Flutter configurado e pronto para desenvolvimento
- Integração com Firebase (Authentication, Firestore, Cloud Functions, Dynamic Links)
- State management com Provider
- Arquitetura organizada com separação de responsabilidades

### Autenticação e Usuários
- Sistema de autenticação com Firebase
- Gerenciamento de usuários no Firestore
- Suporte para múltiplas formas de login (email, Google, Apple, GitHub)
- Autenticação anônima disponível

### Páginas e Funcionalidades
- Página de metas (adicionar, visualizar, gerenciar metas)
- Página de sintomas relacionados a diabetes
- Página de notificações
- Página de configurações do usuário
- Página de escalas de motivação
- Página de notícias
- Dashboard principal
- Componentes reutilizáveis para interface

### Backend e Banco de Dados
- Back-end Java/Spring Boot separado em `backend-repo/Procel-Ingestion`
- PostgreSQL como banco do serviço de ingestão
- Endpoints REST para autenticação, pessoas, presenças, sensores, medições, salas e regras
- Firestore continua disponível para partes legadas do app e sincronizações específicas
- Cloud Functions continuam no ecossistema Firebase quando necessário

### Recursos Adicionais
- Sistema de notificações push
- Armazenamento local com Shared Preferences
- Ativos organizados (imagens, vídeos, áudios, PDFs, animações Rive)
- Logs e rastreamento de ações do usuário
- Gerenciamento de dados com sincronização Firestore

## Como começar?

### Instalação

```bash
# Clonar o repositório
git clone https://github.com/ManoelaV/Procel.git
cd Procel

# Baixar o back-end como submodule
git submodule update --init --recursive

# Instalar dependências
flutter pub get
```

### Executar

```bash
# Terminal 1 - back-end
cd backend-repo/Procel-Ingestion
docker compose up -d
.\mvnw.cmd spring-boot:run

# Terminal 2 - front-end
cd ..\..\
flutter run --dart-define=API_BASE_URL=http://localhost:8080

# Com logs detalhados
flutter run -v
```

### Compilar para Produção

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web
```

## Sincronização do Backend

O back-end agora é um repositório independente em `backend-repo/`. Usamos um **GitHub Action** para manter o front-end sempre sincronizado com as atualizações do back-end.

### Como funciona

- **Automático**: A cada hora, o Action `.github/workflows/sync-backend.yml` clona o repositório do backend (`ravilon/PROCEL-Back-End`) e substitui o conteúdo em `backend-repo/`.
- **Manual**: Você pode também rodar localmente o script `scripts/pull-backend-updates.ps1` para puxar atualizações na hora:
  ```powershell
  powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\pull-backend-updates.ps1
  ```
- **Commits automáticos**: Se houver mudanças, o Action comita e faz push automaticamente na branch main do front.

### Se o backend for privado

Adicione um secret `BACKEND_TOKEN` nas configurações do repositório front (Settings > Secrets and variables > Actions):
- Gere um token de leitura no GitHub (Settings > Developer settings > Personal access tokens > Tokens (classic))
- Adicione o token com o nome `BACKEND_TOKEN`

Assim, o Action conseguirá clonar repositórios privados.

## Estrutura do Projeto

- `lib/auth/` - Autenticação Firebase
- `lib/backend/` - Camada de APIs, schemas e integração com serviços
- `lib/config/` - Configuração da URL base do back-end e endpoints
- `lib/pages/` - Telas do aplicativo
- `lib/components/` - Componentes reutilizáveis
- `lib/providers/` - State management
- `lib/services/` - Serviços e APIs
- `lib/models/` - Modelos de dados
- `assets/` - Imagens, vídeos, áudios, fontes
- `backend-repo/` - Back-end Java/Spring Boot (sincronizado automaticamente)
- `firebase/` - Configurações e regras Firestore

## Tecnologias

- Flutter e Dart
- Firebase (Authentication, Firestore, Cloud Functions)
- Java 21 + Spring Boot + PostgreSQL no back-end de ingestão
- Provider para state management
- Shared Preferences para armazenamento local

## Fluxo Fechado

O caminho principal do app agora fica assim:

1. O Flutter sobe com `API_BASE_URL` apontando para o back-end Java.
2. O back-end expõe a API em `/api/...` e persiste no PostgreSQL.
3. O front consome os endpoints via `lib/config/api_config.dart`.
4. O submodule `backend-repo/` mantém o código do back-end versionado junto do app.

Base local padrão:

```text
http://localhost:8080
```

Base remota de testes:

```text
https://procel.servehttp.com
```

## Próximos Passos

O projeto está em desenvolvimento contínuo. Novas funcionalidades serão adicionadas conforme o projeto avança.