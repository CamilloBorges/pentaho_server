# Monitor Pentaho Build Progress
# Checks the build log on remote server

$ServerIP = "191.101.70.239"
$ServerUser = "root"
$LogFile = "/tmp/pentaho-rebuild.log"

Write-Host "📊 Verificando progresso do build..." -ForegroundColor Cyan
Write-Host ""

# Check if process is still running
Write-Host "🔍 Processos Docker Compose:" -ForegroundColor Yellow
ssh "${ServerUser}@${ServerIP}" "ps aux | grep 'docker compose' | grep -v grep || echo 'Nenhum processo docker compose rodando'"

Write-Host ""
Write-Host "📝 Últimas 30 linhas do log:" -ForegroundColor Yellow
ssh "${ServerUser}@${ServerIP}" "tail -30 $LogFile 2>/dev/null || echo 'Log ainda não criado'"

Write-Host ""
Write-Host "📦 Status dos containers:" -ForegroundColor Yellow  
ssh "${ServerUser}@${ServerIP}" "docker ps -a"

Write-Host ""
Write-Host "✅ Verificação completa!" -ForegroundColor Green
