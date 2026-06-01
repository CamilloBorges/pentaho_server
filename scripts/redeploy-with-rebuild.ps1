# Redeploy Pentaho with Full Rebuild
# This script connects once to SSH and executes all commands in sequence

$ServerIP = "191.101.70.239"
$ServerUser = "root"
$ProjectDir = "~/pentaho_server"

Write-Host "🔄 Iniciando redeploy completo com rebuild..." -ForegroundColor Cyan
Write-Host ""
Write-Host "Etapas:" -ForegroundColor Yellow
Write-Host "  1. Parar containers e remover volumes" -ForegroundColor Gray
Write-Host "  2. Git pull (commit fa19d6a)" -ForegroundColor Gray
Write-Host "  3. Rebuild image Pentaho (--no-cache)" -ForegroundColor Gray
Write-Host "  4. Subir containers" -ForegroundColor Gray
Write-Host ""

# Single SSH command with all steps
$sshCommand = @"
cd $ProjectDir && \
docker compose down -v && \
git pull && \
docker compose build --no-cache pentaho-server && \
docker compose up -d && \
echo '' && \
echo '✅ Deploy completo!' && \
echo '' && \
docker compose ps
"@

Write-Host "📡 Conectando em $ServerUser@$ServerIP..." -ForegroundColor Cyan
Write-Host "   (O rebuild pode demorar ~10 minutos)" -ForegroundColor Yellow
Write-Host ""

ssh "${ServerUser}@${ServerIP}" $sshCommand

Write-Host ""
Write-Host "✅ Script finalizado!" -ForegroundColor Green
