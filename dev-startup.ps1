# Script para iniciar o PROCEL em desenvolvimento

Write-Host "🚀 Iniciando PROCEL (Front-end + Back-end)" -ForegroundColor Cyan
Write-Host ""

# Verificar Java
Write-Host "✓ Verificando Java..." -ForegroundColor Green
java -version 2>&1 | Write-Host

# Verificar Docker
Write-Host "✓ Verificando Docker..." -ForegroundColor Green
docker --version

Write-Host ""
Write-Host "📋 Opções:" -ForegroundColor Yellow
Write-Host "1 - Iniciar Back-end (Java + PostgreSQL)"
Write-Host "2 - Iniciar Front-end (Flutter)"
Write-Host "3 - Iniciar AMBOS (em abas diferentes)"
Write-Host "4 - Parar tudo"
Write-Host ""

$choice = Read-Host "Escolha uma opção (1-4)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "🔧 Iniciando Back-end..." -ForegroundColor Cyan
        Write-Host "   Subindo PostgreSQL com Docker..." -ForegroundColor Gray
        Set-Location backend-repo/Procel-Ingestion
        docker compose up -d
        Write-Host "   ✓ PostgreSQL está rodando" -ForegroundColor Green
        Write-Host "   Iniciando API Spring Boot..." -ForegroundColor Gray
        .\mvnw.cmd spring-boot:run
    }
    "2" {
        Write-Host ""
        Write-Host "📱 Iniciando Front-end..." -ForegroundColor Cyan
        flutter run --dart-define=API_BASE_URL=http://localhost:8080
    }
    "3" {
        Write-Host ""
        Write-Host "⚙️  Iniciando Back-end e Front-end simultaneamente..." -ForegroundColor Cyan
        Write-Host ""
        
        # Backend em nova aba PowerShell
        $backendScript = {
            Set-Location $pwd
            cd backend-repo/Procel-Ingestion
            docker compose up -d
            Write-Host "✓ PostgreSQL iniciado" -ForegroundColor Green
            Write-Host "Iniciando API Spring Boot..." -ForegroundColor Cyan
            .\mvnw.cmd spring-boot:run
        }
        
        # Frontend em nova aba PowerShell
        $frontendScript = {
            Set-Location $pwd
            flutter run --dart-define=API_BASE_URL=http://localhost:8080
        }
        
        # Iniciar em novas abas (Windows)
        Start-Process powershell -ArgumentList "-NoExit -Command `$pwd = '$PWD'; $($backendScript.ToString())"
        Start-Sleep -Seconds 3
        Start-Process powershell -ArgumentList "-NoExit -Command `$pwd = '$PWD'; $($frontendScript.ToString())"
        
        Write-Host "✓ Back-end iniciando em nova aba..." -ForegroundColor Green
        Write-Host "✓ Front-end iniciando em nova aba..." -ForegroundColor Green
        Write-Host ""
        Write-Host "Aguarde alguns segundos para tudo inicializar..." -ForegroundColor Yellow
    }
    "4" {
        Write-Host ""
        Write-Host "🛑 Parando tudo..." -ForegroundColor Red
        Set-Location backend-repo/Procel-Ingestion
        docker compose down
        Write-Host "✓ PostgreSQL parado" -ForegroundColor Green
    }
    default {
        Write-Host "❌ Opção inválida" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "✨ Pronto!" -ForegroundColor Green
