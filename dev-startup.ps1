# Script para iniciar o PROCEL em desenvolvimento.

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$backendPath = Join-Path $projectRoot 'backend-repo\Procel-Ingestion'

function Test-Prerequisites {
    Write-Host " Iniciando PROCEL (Front-end + Back-end)" -ForegroundColor Cyan
    Write-Host ""

    Write-Host " Verificando Java..." -ForegroundColor Green
    java -version 2>&1 | Write-Host

    Write-Host " Verificando Docker..." -ForegroundColor Green
    docker --version
    Write-Host ""
}

function Start-Backend {
    Write-Host " Iniciando Back-end..." -ForegroundColor Cyan
    Set-Location $backendPath
    docker compose up -d
    Write-Host " PostgreSQL está rodando" -ForegroundColor Green
    Write-Host "Iniciando API Spring Boot..." -ForegroundColor Gray
    .\mvnw.cmd spring-boot:run
}

function Start-Frontend {
    Write-Host " Iniciando Front-end..." -ForegroundColor Cyan
    Set-Location $projectRoot
    flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
}

function Start-Both {
    Write-Host "  Iniciando Back-end e Front-end simultaneamente..." -ForegroundColor Cyan
    Write-Host ""

    Start-Process powershell -WorkingDirectory $backendPath -ArgumentList @(
        '-NoExit',
        '-Command',
        "Set-Location -LiteralPath '$backendPath'; docker compose up -d; .\mvnw.cmd spring-boot:run"
    )

    Start-Process powershell -WorkingDirectory $projectRoot -ArgumentList @(
        '-NoExit',
        '-Command',
        "Set-Location -LiteralPath '$projectRoot'; flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080"
    )

    Write-Host " Back-end e front-end iniciando em janelas separadas" -ForegroundColor Green
    Write-Host ""
    Write-Host "Aguarde alguns segundos para tudo inicializar..." -ForegroundColor Yellow
}

function Stop-Backend {
    Write-Host "🛑 Parando tudo..." -ForegroundColor Red
    Set-Location $backendPath
    docker compose down
    Write-Host "✓ PostgreSQL parado" -ForegroundColor Green
}

Test-Prerequisites

Write-Host "📋 Opções:" -ForegroundColor Yellow
Write-Host "1 - Iniciar Back-end (Java + PostgreSQL)"
Write-Host "2 - Iniciar Front-end (Flutter)"
Write-Host "3 - Iniciar AMBOS (em janelas diferentes)"
Write-Host "4 - Parar tudo"
Write-Host ""

$choice = Read-Host "Escolha uma opção (1-4)"

switch ($choice) {
    '1' { Start-Backend }
    '2' { Start-Frontend }
    '3' { Start-Both }
    '4' { Stop-Backend }
    default { Write-Host " Opção inválida" -ForegroundColor Red }
}

Write-Host ""
Write-Host " Pronto!" -ForegroundColor Green
