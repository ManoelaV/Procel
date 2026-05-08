# PROCEL - Aplicativo de Economia de Energia

## O que é PROCEL?

PROCEL é uma aplicação mobile desenvolvida em Flutter que ajuda usuários a monitorar e economizar energia de forma gamificada. O aplicativo está sendo construído com Flutter e utiliza Firebase como backend.

## O que já foi implementado?

### Estrutura Base
- Projeto Flutter configurado e pronto para desenvolvimento
- Integração com Firebase (Authentication, Firestore, Cloud Functions, Dynamic Links)
- Suporte para plataformas Android, iOS e Web
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
- Modelos Firestore implementados:
  - UsersRecord (dados de usuários)
  - MetasRecord (metas de economia)
  - NotificacoesRecord (notificações)
  - QuestionarioRecord (questionários)
  - BPNSRecord (registro BPNS)
  - E outros esquemas específicos
- Integração com APIs externas
- Cloud Functions para lógica de servidor
- Regras de segurança Firestore configuradas

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

# Instalar dependências
flutter pub get
```

### Executar

```bash
# Em um emulador ou dispositivo conectado
flutter run

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

## Estrutura do Projeto

- `lib/auth/` - Autenticação Firebase
- `lib/backend/` - Modelos Firestore e configuração
- `lib/pages/` - Telas do aplicativo
- `lib/components/` - Componentes reutilizáveis
- `lib/providers/` - State management
- `lib/services/` - Serviços e APIs
- `lib/models/` - Modelos de dados
- `assets/` - Imagens, vídeos, áudios, fontes
- `firebase/` - Configurações e regras Firestore

## Tecnologias

- Flutter e Dart
- Firebase (Authentication, Firestore, Cloud Functions)
- Provider para state management
- Shared Preferences para armazenamento local

## Próximos Passos

O projeto está em desenvolvimento contínuo. Novas funcionalidades serão adicionadas conforme o projeto avança.

Para maiores informações ou contribuições, abra uma issue no repositório.