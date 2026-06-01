#!/bin/bash
# =============================================================================
# Script de Reconstrução Rápida - Execute no Servidor
# =============================================================================
# Este script reconstrói e reinicia o Pentaho com Java 11
#
# Uso:
#   chmod +x rebuild-java11.sh
#   ./rebuild-java11.sh
# =============================================================================

set -e

echo "========================================================================="
echo "RECONSTRUÇÃO PENTAHO - JAVA 11"
echo "========================================================================="
echo ""
echo "Este script irá:"
echo "  1. Parar os containers"
echo "  2. Reconstruir a imagem com Java 11 (sem cache)"
echo "  3. Iniciar os containers"
echo ""
read -p "Deseja continuar? (s/N): " confirm

if [ "$confirm" != "s" ] && [ "$confirm" != "S" ]; then
    echo "❌ Operação cancelada"
    exit 1
fi

echo ""
echo "1. Parando containers..."
docker compose down
echo "   ✅ Containers parados"

echo ""
echo "2. Reconstruindo imagem com Java 11..."
echo "   ⏳ Isso pode levar 5-10 minutos..."
docker compose build --no-cache pentaho-server
echo "   ✅ Imagem reconstruída"

echo ""
echo "3. Iniciando containers..."
docker compose up -d
echo "   ✅ Containers iniciados"

echo ""
echo "========================================================================="
echo "DEPLOY CONCLUÍDO!"
echo "========================================================================="
echo ""
echo "🌐 URLs de Acesso:"
echo "   Nginx (Recomendado): http://localhost"
echo "   Direto:              http://localhost:8080/pentaho"
echo ""
echo "📊 Monitorar logs:"
echo "   docker logs -f pentaho-server"
echo ""
echo "⏳ IMPORTANTE: Aguarde 5-10 minutos para inicialização completa"
echo "   Procure por: 'Server startup in [xxxxx] milliseconds' nos logs"
echo ""
echo "🔍 Verificar que Java 11 está sendo usado:"
echo "   docker exec pentaho-server java -version"
echo "   Deve mostrar: openjdk version \"11.x.x\""
echo ""
