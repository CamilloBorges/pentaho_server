#!/bin/bash
# =============================================================================
# Script de Diagnóstico Completo - Pentaho Server CE
# =============================================================================
# Este script coleta informações detalhadas do ambiente para troubleshooting
#
# Uso:
#   chmod +x full-diagnose.sh
#   ./full-diagnose.sh
#   ./full-diagnose.sh > diagnostico-$(date +%Y%m%d-%H%M%S).txt
# =============================================================================

set -e

echo "========================================================================="
echo "DIAGNÓSTICO COMPLETO - PENTAHO SERVER CE"
echo "========================================================================="
echo ""
echo "Data/Hora: $(date)"
echo "Sistema: $(uname -a)"
echo "Docker: $(docker --version)"
echo "Docker Compose: $(docker compose version)"
echo ""

# =============================================================================
echo "========================================================================="
echo "1. STATUS DOS CONTAINERS"
echo "========================================================================="
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(NAMES|pentaho)"
echo ""

# =============================================================================
echo "========================================================================="
echo "2. IMAGENS DOCKER"
echo "========================================================================="
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep -E "(REPOSITORY|pentaho)"
echo ""

# =============================================================================
echo "========================================================================="
echo "3. VOLUMES"
echo "========================================================================="
docker volume ls | grep -E "(DRIVER|pentaho)"
echo ""

# =============================================================================
echo "========================================================================="
echo "4. REDE"
echo "========================================================================="
docker network ls | grep -E "(NETWORK ID|pentaho)"
echo ""
echo "Detalhes da rede pentaho-net:"
docker network inspect pentaho-net --format '{{json .IPAM.Config}}' 2>/dev/null | python3 -m json.tool || echo "Rede não encontrada ou erro ao inspecionar"
echo ""

# =============================================================================
echo "========================================================================="
echo "5. HEALTH CHECK - PENTAHO SERVER"
echo "========================================================================="
if docker ps -q -f name=pentaho-server > /dev/null 2>&1; then
    echo "Status do Container:"
    docker inspect pentaho-server --format='  Estado: {{.State.Status}} | Health: {{.State.Health.Status}}' 2>/dev/null || echo "Erro ao inspecionar"
    echo ""
    echo "Histórico de Health Checks (últimos 5):"
    docker inspect pentaho-server --format='{{range .State.Health.Log}}  {{.Start}} - {{.ExitCode}} - {{.Output}}{{end}}' 2>/dev/null | tail -5 || echo "Nenhum health check registrado"
else
    echo "Container pentaho-server não está em execução"
fi
echo ""

# =============================================================================
echo "========================================================================="
echo "6. HEALTH CHECK - POSTGRESQL"
echo "========================================================================="
if docker ps -q -f name=pentaho-postgres > /dev/null 2>&1; then
    docker inspect pentaho-postgres --format='  Estado: {{.State.Status}} | Health: {{.State.Health.Status}}' 2>/dev/null || echo "Erro ao inspecionar"
else
    echo "Container pentaho-postgres não está em execução"
fi
echo ""

# =============================================================================
echo "========================================================================="
echo "7. STARTUP STATUS"
echo "========================================================================="
if docker ps -q -f name=pentaho-server > /dev/null 2>&1; then
    echo "Procurando mensagem de startup completo..."
    docker logs pentaho-server 2>&1 | grep "Server startup in" | tail -1 || echo "Mensagem de startup não encontrada - pode ainda estar inicializando"
else
    echo "Container pentaho-server não está em execução"
fi
echo ""

# =============================================================================
echo "========================================================================="
echo "8. COMMONS-POOL CHECK"
echo "========================================================================="
if docker ps -q -f name=pentaho-server > /dev/null 2>&1; then
    echo "Bibliotecas commons-pool instaladas:"
    docker exec pentaho-server ls -lh /opt/pentaho/pentaho-server/tomcat/lib/ 2>/dev/null | grep commons-pool || echo "Nenhuma biblioteca commons-pool encontrada"
    echo ""
    echo "Verificando por erros de ClassLoader nos logs:"
    CLASSLOADER_ERRORS=$(docker logs pentaho-server 2>&1 | grep -c "NoClassDefFoundError.*CursorableLinkedList" || echo "0")
    echo "  Erros encontrados: $CLASSLOADER_ERRORS"
    if [ "$CLASSLOADER_ERRORS" -gt "0" ]; then
        echo "  ⚠️  ATENÇÃO: Erros de ClassLoader detectados!"
        echo "  Solução: Reconstruir imagem com commons-pool2"
        echo "  Comando: docker compose build --no-cache pentaho-server"
    fi
else
    echo "Container pentaho-server não está em execução"
fi
echo ""

# =============================================================================
echo "========================================================================="
echo "9. MAPEAMENTO DE PORTAS"
echo "========================================================================="
if docker ps -q -f name=pentaho-server > /dev/null 2>&1; then
    echo "Pentaho Server:"
    docker port pentaho-server 2>/dev/null || echo "Erro ao obter portas"
else
    echo "Container pentaho-server não está em execução"
fi
echo ""
if docker ps -q -f name=pentaho-postgres > /dev/null 2>&1; then
    echo "PostgreSQL:"
    docker port pentaho-postgres 2>/dev/null || echo "Erro ao obter portas"
else
    echo "Container pentaho-postgres não está em execução"
fi
echo ""

# =============================================================================
echo "========================================================================="
echo "10. TESTE DE CONECTIVIDADE"
echo "========================================================================="
if docker ps -q -f name=pentaho-server > /dev/null 2>&1; then
    echo -n "HTTP Pentaho (localhost:8080/pentaho/): "
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/pentaho/ 2>/dev/null || echo "000")
    echo "$HTTP_CODE"
    case $HTTP_CODE in
        200|302) echo "  ✅ OK - Pentaho está respondendo" ;;
        404) echo "  ⚠️  404 - Pentaho iniciou mas webapp não encontrada" ;;
        000) echo "  ❌ ERRO - Não foi possível conectar" ;;
        *) echo "  ⚠️  Código inesperado" ;;
    esac
    echo ""
    
    echo -n "PostgreSQL (repository:5432): "
    docker exec pentaho-server nc -zv repository 5432 2>&1 | grep -q "succeeded" && echo "✅ Conectado" || echo "❌ Falhou"
else
    echo "Container pentaho-server não está em execução - testes ignorados"
fi
echo ""

# =============================================================================
echo "========================================================================="
echo "11. USO DE RECURSOS"
echo "========================================================================="
echo "Uso atual de CPU/RAM:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}" | grep -E "(CONTAINER|pentaho)"
echo ""

# =============================================================================
echo "========================================================================="
echo "12. CONFIGURAÇÃO .env"
echo "========================================================================="
if [ -f .env ]; then
    echo "Arquivo .env encontrado:"
    cat .env | grep -v "^#" | grep -v "^$" | sed 's/PASSWORD=.*/PASSWORD=***OCULTO***/'
else
    echo "Arquivo .env não encontrado!"
    echo "⚠️  Crie um a partir de .env.template"
fi
echo ""

# =============================================================================
echo "========================================================================="
echo "13. ÚLTIMOS ERROS NOS LOGS"
echo "========================================================================="
if docker ps -q -f name=pentaho-server > /dev/null 2>&1; then
    echo "Últimos 10 erros/exceções:"
    docker logs pentaho-server 2>&1 | grep -i -E "(error|exception)" | tail -10 || echo "Nenhum erro encontrado nos logs recentes"
else
    echo "Container pentaho-server não está em execução"
fi
echo ""

# =============================================================================
echo "========================================================================="
echo "14. ÚLTIMAS 30 LINHAS DOS LOGS"
echo "========================================================================="
if docker ps -q -f name=pentaho-server > /dev/null 2>&1; then
    docker logs --tail 30 pentaho-server 2>&1
else
    echo "Container pentaho-server não está em execução"
fi
echo ""

# =============================================================================
echo "========================================================================="
echo "15. CHECKLIST DE VERIFICAÇÃO"
echo "========================================================================="

check_item() {
    if $1; then
        echo "  ✅ $2"
        return 0
    else
        echo "  ❌ $2"
        return 1
    fi
}

check_item "docker ps -q -f name=pentaho-postgres > /dev/null 2>&1" "PostgreSQL container rodando"
check_item "docker ps -q -f name=pentaho-server > /dev/null 2>&1" "Pentaho container rodando"

if docker ps -q -f name=pentaho-postgres > /dev/null 2>&1; then
    POSTGRES_HEALTH=$(docker inspect pentaho-postgres --format='{{.State.Health.Status}}' 2>/dev/null)
    check_item "[ '$POSTGRES_HEALTH' = 'healthy' ]" "PostgreSQL healthy"
fi

if docker ps -q -f name=pentaho-server > /dev/null 2>&1; then
    PENTAHO_HEALTH=$(docker inspect pentaho-server --format='{{.State.Health.Status}}' 2>/dev/null)
    check_item "[ '$PENTAHO_HEALTH' = 'healthy' ]" "Pentaho healthy"
    
    check_item "docker logs pentaho-server 2>&1 | grep -q 'Server startup in'" "Pentaho terminou startup"
    
    check_item "docker exec pentaho-server ls /opt/pentaho/pentaho-server/tomcat/lib/commons-pool2-*.jar > /dev/null 2>&1" "commons-pool2 instalado"
    
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/pentaho/ 2>/dev/null || echo "000")
    check_item "[ '$HTTP_CODE' = '200' ] || [ '$HTTP_CODE' = '302' ]" "Pentaho respondendo HTTP"
fi

check_item "[ -f .env ]" "Arquivo .env existe"
check_item "[ -f docker-compose.yml ]" "docker-compose.yml existe"
check_item "docker network ls | grep -q pentaho-net" "Rede pentaho-net existe"

echo ""

# =============================================================================
echo "========================================================================="
echo "16. RECOMENDAÇÕES"
echo "========================================================================="

ISSUES=0

if ! docker ps -q -f name=pentaho-server > /dev/null 2>&1; then
    echo "⚠️  Container Pentaho não está rodando"
    echo "   Solução: docker compose up -d"
    ISSUES=$((ISSUES+1))
fi

if docker ps -q -f name=pentaho-server > /dev/null 2>&1; then
    PENTAHO_HEALTH=$(docker inspect pentaho-server --format='{{.State.Health.Status}}' 2>/dev/null)
    if [ "$PENTAHO_HEALTH" != "healthy" ]; then
        echo "⚠️  Container Pentaho está unhealthy"
        echo "   Verificar: docker logs pentaho-server"
        echo "   Consultar: TROUBLESHOOTING.md"
        ISSUES=$((ISSUES+1))
    fi
    
    CLASSLOADER_ERRORS=$(docker logs pentaho-server 2>&1 | grep -c "NoClassDefFoundError.*CursorableLinkedList" 2>/dev/null || echo "0")
    if [ "$CLASSLOADER_ERRORS" -gt "0" ]; then
        echo "⚠️  Detectados erros de ClassLoader (commons-pool)"
        echo "   Solução: docker compose down && docker compose build --no-cache && docker compose up -d"
        echo "   Consultar: TROUBLESHOOTING.md#commons-pool-error"
        ISSUES=$((ISSUES+1))
    fi
    
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/pentaho/ 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" = "404" ]; then
        echo "⚠️  Pentaho retornando 404"
        echo "   Pode estar ainda inicializando. Aguarde 5-10 minutos."
        echo "   Se persistir: Consultar TROUBLESHOOTING.md#erro-404"
        ISSUES=$((ISSUES+1))
    fi
fi

if [ ! -f .env ]; then
    echo "⚠️  Arquivo .env não encontrado"
    echo "   Solução: cp .env.template .env"
    ISSUES=$((ISSUES+1))
fi

if [ $ISSUES -eq 0 ]; then
    echo "✅ Nenhum problema detectado!"
    echo ""
    echo "🎉 Pentaho Server está pronto para uso!"
    echo "   Acesse: http://localhost:8080/pentaho"
    echo "   Usuário: admin / Senha: password"
else
    echo ""
    echo "Total de problemas detectados: $ISSUES"
    echo ""
    echo "📚 Consulte a documentação:"
    echo "   - TROUBLESHOOTING.md - Guia completo de problemas"
    echo "   - NETWORK_ACCESS.md - Problemas de acesso"
    echo "   - SYSTEM_REQUIREMENTS.md - Otimização de recursos"
fi

echo ""
echo "========================================================================="
echo "FIM DO DIAGNÓSTICO"
echo "========================================================================="
echo ""
echo "💾 Para salvar este diagnóstico:"
echo "   ./full-diagnose.sh > diagnostico-\$(date +%Y%m%d-%H%M%S).txt"
echo ""
