# =============================================================================
# Script de Deploy Remoto via SSH
# =============================================================================
# Este script envia os arquivos e reconstrói o Pentaho no servidor remoto
#
# Uso (PowerShell):
#   .\scripts\deploy-remote.ps1 -ServerIP "191.101.70.239" -ServerUser "root"
# =============================================================================

param(
    [string]$ServerIP = "191.101.70.239",
    [string]$ServerUser = "root",
    [string]$ServerPath = "~/pentaho_server"
)

Write-Host "=========================================================================" -ForegroundColor Cyan
Write-Host "DEPLOY REMOTO - PENTAHO SERVER CE" -ForegroundColor Cyan
Write-Host "=========================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Servidor: $ServerUser@$ServerIP" -ForegroundColor Yellow
Write-Host "Destino: $ServerPath" -ForegroundColor Yellow
Write-Host ""

# Confirmar
$confirm = Read-Host "Deseja continuar? (s/N)"
if ($confirm -ne "s" -and $confirm -ne "S") {
    Write-Host "Deploy cancelado pelo usuário" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "1. Sincronizando arquivos com o servidor..." -ForegroundColor Green

# Usar rsync se disponível, senão usar scp
$hasRsync = Get-Command rsync -ErrorAction SilentlyContinue

if ($hasRsync) {
    Write-Host "   Usando rsync para sincronização eficiente..." -ForegroundColor Cyan
    
    # Excluir arquivos desnecessários
    $exclude = @(
        ".git",
        ".gitignore",
        "*.log",
        "logs/*",
        "backups/*",
        "*.md~",
        ".env",
        "secrets/postgres_password.txt"
    )
    
    $excludeArgs = $exclude | ForEach-Object { "--exclude=$_" }
    
    & rsync -avz --delete $excludeArgs -e "ssh" . "${ServerUser}@${ServerIP}:${ServerPath}/"
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "   ❌ Erro ao sincronizar arquivos" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "   Rsync não disponível. Use Git no servidor para atualizar os arquivos." -ForegroundColor Yellow
    Write-Host "   Comandos no servidor:" -ForegroundColor Yellow
    Write-Host "     cd $ServerPath" -ForegroundColor Gray
    Write-Host "     git pull" -ForegroundColor Gray
}

Write-Host "   ✅ Arquivos sincronizados" -ForegroundColor Green
Write-Host ""

Write-Host "2. Parando containers..." -ForegroundColor Green
ssh "${ServerUser}@${ServerIP}" "cd $ServerPath && docker compose down"

if ($LASTEXITCODE -ne 0) {
    Write-Host "   ⚠️  Aviso: Erro ao parar containers (podem não estar rodando)" -ForegroundColor Yellow
}

Write-Host "   ✅ Containers parados" -ForegroundColor Green
Write-Host ""

Write-Host "3. Reconstruindo imagem (sem cache)..." -ForegroundColor Green
Write-Host "   ⏳ Isso pode levar 5-10 minutos..." -ForegroundColor Yellow

ssh "${ServerUser}@${ServerIP}" "cd $ServerPath && docker compose build --no-cache pentaho-server"

if ($LASTEXITCODE -ne 0) {
    Write-Host "   ❌ Erro ao reconstruir imagem" -ForegroundColor Red
    exit 1
}

Write-Host "   ✅ Imagem reconstruída" -ForegroundColor Green
Write-Host ""

Write-Host "4. Iniciando containers..." -ForegroundColor Green
ssh "${ServerUser}@${ServerIP}" "cd $ServerPath && docker compose up -d"

if ($LASTEXITCODE -ne 0) {
    Write-Host "   ❌ Erro ao iniciar containers" -ForegroundColor Red
    exit 1
}

Write-Host "   ✅ Containers iniciados" -ForegroundColor Green
Write-Host ""

Write-Host "5. Aguardando inicialização..." -ForegroundColor Green
Write-Host "   ⏳ Pentaho leva 5-10 minutos para inicializar completamente" -ForegroundColor Yellow
Write-Host ""

# Aguardar 30 segundos
Write-Host "   Aguardando 30 segundos..." -ForegroundColor Cyan
Start-Sleep -Seconds 30

Write-Host ""
Write-Host "6. Verificando status..." -ForegroundColor Green

$status = ssh "${ServerUser}@${ServerIP}" "cd $ServerPath && docker ps"
Write-Host $status

Write-Host ""
Write-Host "=========================================================================" -ForegroundColor Cyan
Write-Host "DEPLOY CONCLUÍDO!" -ForegroundColor Green
Write-Host "=========================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "🌐 URLs de Acesso:" -ForegroundColor Yellow
Write-Host "   Nginx (Recomendado): http://$ServerIP" -ForegroundColor Cyan
Write-Host "   Direto:              http://$ServerIP:8080/pentaho" -ForegroundColor Gray
Write-Host ""
Write-Host "🔐 Credenciais Padrão:" -ForegroundColor Yellow
Write-Host "   Usuário: admin" -ForegroundColor Cyan
Write-Host "   Senha:   password" -ForegroundColor Cyan
Write-Host ""
Write-Host "📊 Monitorar logs:" -ForegroundColor Yellow
Write-Host "   ssh $ServerUser@$ServerIP 'docker logs -f pentaho-server'" -ForegroundColor Gray
Write-Host ""
Write-Host "⏳ IMPORTANTE: Aguarde 5-10 minutos para inicialização completa" -ForegroundColor Yellow
Write-Host "   Procure por: 'Server startup in [xxxxx] milliseconds' nos logs" -ForegroundColor Gray
Write-Host ""
