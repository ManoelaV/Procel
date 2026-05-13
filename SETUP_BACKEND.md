# 🔌 Como Conectar Front-end e Back-end do PROCEL

## Estrutura do Projeto

```
Procel/                    # Front-end Flutter (este repositório)
├── lib/
│   ├── backend/          # Conexão com APIs
│   │   ├── api_manager.dart
│   │   └── api_requests/
│   └── ...
└── backend-repo/         # Back-end Java (Git Submodule)
    └── Procel-Ingestion/ # API Spring Boot
```

## 1️⃣ Clonar o Repositório com Submodule

Se você acabou de clonar o repositório:

```bash
git clone https://github.com/ManoelaV/Procel.git
cd Procel
git submodule update --init --recursive
```

## 2️⃣ Iniciar o Back-end (Localmente)

### Pré-requisitos
- Java 21
- Docker (ou PostgreSQL instalado localmente)
- PowerShell (opcional)

### Iniciar PostgreSQL

```powershell
cd backend-repo/Procel-Ingestion
docker compose up -d
```

### Executar a API

```powershell
.\mvnw.cmd spring-boot:run
```

A API estará disponível em: **http://localhost:8080**

Documentação Swagger: **http://localhost:8080/swagger-ui/index.html**

---

## 3️⃣ Configurar o Front-end para Acessar o Back-end

### Opção A: Servidor Local (Desenvolvimento)

Crie um arquivo `lib/config/api_config.dart`:

```dart
class ApiConfig {
  // Desenvolvimento
  static const String baseUrl = 'http://localhost:8080';
  
  // Ou use esta variável de ambiente
  static const String baseUrlEnv = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );
}
```

### Opção B: Servidor Remoto (Testes sem Backend Local)

Use o servidor publicado em:
```
https://procel.servehttp.com
```

No `api_config.dart`:
```dart
static const String baseUrl = 'https://procel.servehttp.com';
```

### Opção C: Variável de Ambiente

Execute o Flutter passando a URL:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:8080
```

---

## 4️⃣ Fazer Requisições HTTP do Front-end

Use o gerenciador de requisições em `lib/backend/api_requests/api_manager.dart`:

```dart
import 'package:procel/config/api_config.dart';

// Exemplo: Fazer login
final response = await http.post(
  Uri.parse('${ApiConfig.baseUrl}/auth/login'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'email': 'usuario@email.com',
    'password': 'senha123'
  }),
);
```

---

## 5️⃣ Endpoints Disponíveis da API

Consulte a documentação Swagger para ver todos os endpoints:

- **Local**: http://localhost:8080/swagger-ui/index.html
- **Remoto**: https://procel.servehttp.com/swagger-ui/index.html

Alguns exemplos:

- `POST /auth/login` - Autenticar
- `POST /auth/cadastro` - Cadastro de usuário
- `GET /sensores` - Listar sensores
- `GET /medicoes?sensorId={id}` - Obter medições

---

## 6️⃣ Atualizar Submodule

Se o back-end foi atualizado no repositório:

```bash
cd backend-repo
git pull origin main
cd ..
git add backend-repo
git commit -m "Update backend-repo submodule"
```

---

## 📱 Rodando Front-end + Back-end Simultaneamente

**Terminal 1** (Back-end):

```bash
cd backend-repo/Procel-Ingestion
.\mvnw.cmd spring-boot:run
```

**Terminal 2** (Front-end):

```bash
flutter run
```

---

## ⚠️ Troubleshooting

### Erro de conexão recusada (Connection refused)

- Certifique-se de que o PostgreSQL está rodando: `docker ps`
- Certifique-se de que a API está rodando na porta 8080

### Erro CORS (Cross-Origin)

- O back-end precisa estar configurado para aceitar requisições do front-end
- Verifique `application.properties` ou `application.yml` no back-end

### Erro de autenticação (401/403
)
- Verifique se está enviando o token JWT corretamente no header `Authorization: Bearer <token>`

---

**Mais dúvidas?** Consulte o [README do Back-end](./backend-repo/README.md)
