# Troubleshooting - Pentaho Server CE Docker

Guia completo de resolução de problemas comuns.

## 📋 Índice

- [Container Unhealthy](#container-unhealthy)
- [Erro 404 ao Acessar](#erro-404)
- [Commons Pool ClassLoader Error](#commons-pool-error)
- [Erro de CPU/Memória](#recursos-insuficientes)
- [PostgreSQL Connection Failed](#postgres-connection)
- [Logs e Diagnóstico](#logs-e-diagnostico)

---

## 🔴 Container Unhealthy

### Sintoma
```bash
docker ps
# STATUS: Up X minutes (unhealthy)
```

### Diagnóstico

```bash
# Ver motivo da falha do health check
docker inspect pentaho-server | grep -A 20 "Health"

# Ver logs do health check
docker logs pentaho-server 2>&1 | grep -i health
```

### Causas Comuns

#### 1. Pentaho ainda está inicializando

**Solução**: Aguarde. A primeira inicialização leva **5-10 minutos**.

```bash
# Verificar se já terminou
docker logs pentaho-server 2>&1 | grep "Server startup in"

# Deve mostrar:
# INFO: Server startup in [xxxxx] milliseconds
```

#### 2. Health check muito rigoroso

**Problema**: Health check falha antes do Pentaho terminar de iniciar.

**Solução Aplicada**: Dockerfile já configurado com:
- `start-period=300s` (5 minutos antes de começar a verificar)
- `retries=5` (mais tentativas)
- Endpoint `/pentaho/` ao invés de `/pentaho/Login`

#### 3. Commons-pool ClassLoader Error

**Problema**: Pentaho 9.4 usa `commons-pool 1.x` que é incompatível com Java 21.

**Sintoma nos logs**:
```
NoClassDefFoundError: org/apache/commons/pool/impl/CursorableLinkedList$Cursor
this web application instance has been stopped already
```

**Solução Aplicada**: Dockerfile agora baixa `commons-pool2 2.12.0` automaticamente.

**Se já tem container rodando**, reconstrua:
```bash
docker compose down
docker compose build --no-cache pentaho-server
docker compose up -d
```

---

## 🔴 Erro 404

### Sintoma
```bash
curl http://localhost:8080/pentaho
# HTTP 404
```

### Diagnóstico Completo

```bash
#!/bin/bash
echo "=== DIAGNÓSTICO 404 ==="

# 1. Container rodando?
echo "1. STATUS:"
docker ps | grep pentaho

# 2. Iniciou completamente?
echo "2. STARTUP:"
docker logs pentaho-server 2>&1 | grep "Server startup in"

# 3. Health status
echo "3. HEALTH:"
docker inspect pentaho-server --format='{{.State.Health.Status}}'

# 4. Teste direto
echo "4. CURL:"
curl -I http://localhost:8080/pentaho/

# 5. Últimos logs
echo "5. LOGS:"
docker logs --tail 30 pentaho-server
```

### Causas e Soluções

#### 1. Pentaho não iniciou

```bash
# Ver se há erros
docker logs pentaho-server | grep -i error

# Reiniciar
docker compose restart pentaho-server
```

#### 2. Webapp não foi deployed

```bash
# Verificar webapps
docker exec pentaho-server ls -la /opt/pentaho/pentaho-server/tomcat/webapps/

# Deve ter diretório "pentaho"
```

**Se não existir**:
```bash
# Verificar se o war existe
docker exec pentaho-server ls -la /opt/pentaho/pentaho-server/tomcat/webapps/*.war

# Reconstruir container
docker compose down
docker compose build --no-cache
docker compose up -d
```

#### 3. URL incorreta

Tente:
- ✅ `http://localhost:8080/pentaho`
- ✅ `http://localhost:8080/pentaho/`
- ✅ `http://localhost:8080/pentaho/Login`
- ❌ `http://localhost:8080` (pode não redirecionar)

---

## 🔴 Commons Pool ClassLoader Error {#commons-pool-error}

### Sintoma Completo

```
Exception in thread "Timer-0" java.lang.NoClassDefFoundError: org/apache/commons/pool/impl/CursorableLinkedList$Cursor
        at org.apache.commons.pool.impl.CursorableLinkedList.cursor(CursorableLinkedList.java:305)
        at org.apache.commons.pool.impl.GenericObjectPool.evict(GenericObjectPool.java:1549)
Caused by: java.lang.ClassNotFoundException: Illegal access: this web application instance has been stopped already
```

### Causa Raiz

Pentaho Server 9.4 foi compilado para Java 8 e usa `commons-pool 1.5.x`, que tem problemas de ClassLoader no Java 21 durante shutdown de webapps.

### Solução Permanente (APLICADA)

O Dockerfile foi atualizado para:

1. **Baixar commons-pool2 2.12.0** (compatível com Java 21)
2. **Remover commons-pool 1.x** (evita conflitos)

Código no Dockerfile:
```dockerfile
# Fix commons-pool compatibility issue with Java 21
RUN wget -q https://repo1.maven.org/maven2/org/apache/commons/commons-pool2/2.12.0/commons-pool2-2.12.0.jar \
    -O ${PENTAHO_HOME}/tomcat/lib/commons-pool2-2.12.0.jar && \
    find ${PENTAHO_HOME}/tomcat/lib -name 'commons-pool-1*.jar' -delete 2>/dev/null || true
```

### Aplicar a Correção

```bash
# 1. Parar containers
docker compose down

# 2. Reconstruir sem cache
docker compose build --no-cache pentaho-server

# 3. Iniciar
docker compose up -d

# 4. Acompanhar logs
docker logs -f pentaho-server
```

### Verificar Correção

```bash
# Ver se commons-pool2 está presente
docker exec pentaho-server ls -la /opt/pentaho/pentaho-server/tomcat/lib/ | grep commons-pool

# Deve mostrar:
# commons-pool2-2.12.0.jar
```

### Solução Manual (se não quiser reconstruir)

```bash
# Baixar commons-pool2
wget https://repo1.maven.org/maven2/org/apache/commons/commons-pool2/2.12.0/commons-pool2-2.12.0.jar

# Copiar para container
docker cp commons-pool2-2.12.0.jar pentaho-server:/opt/pentaho/pentaho-server/tomcat/lib/

# Remover versão antiga
docker exec pentaho-server sh -c 'rm -f /opt/pentaho/pentaho-server/tomcat/lib/commons-pool-1*.jar'

# Reiniciar
docker compose restart pentaho-server
```

---

## 🔴 Recursos Insuficientes

### Sintoma
```
Error: range of CPUs is from 0.01 to X.00
```
ou
```
Container keeps restarting
OOMKilled status
```

### Solução

Consulte o guia completo: [SYSTEM_REQUIREMENTS.md](SYSTEM_REQUIREMENTS.md)

**Quick Fix**:

```bash
# Edite docker-compose.yml
# Reduza os limites conforme seu sistema

# Para 2 CPUs / 4GB RAM:
deploy:
  resources:
    limits:
      cpus: '2'
      memory: 4G
    reservations:
      cpus: '1'
      memory: 2G
```

---

## 🔴 PostgreSQL Connection Failed

### Sintoma
```
Could not connect to PostgreSQL
Connection refused
```

### Diagnóstico

```bash
# PostgreSQL está rodando?
docker ps | grep postgres

# Teste de conexão
docker exec pentaho-server nc -zv repository 5432

# Logs do PostgreSQL
docker logs pentaho-postgres
```

### Soluções

#### 1. PostgreSQL ainda inicializando

```bash
# Aguardar health check
docker inspect pentaho-postgres | grep -A 5 "Health"
```

#### 2. Senha incorreta

Verifique `.env`:
```bash
cat .env | grep POSTGRES_PASSWORD
```

Deve corresponder a `secrets/postgres_password.txt`:
```bash
cat secrets/postgres_password.txt
```

#### 3. Rede não configurada

```bash
# Verificar rede
docker network inspect pentaho-net

# Recriar
docker compose down
docker compose up -d
```

---

## 🔍 Logs e Diagnóstico

### Comandos Úteis

```bash
# Logs em tempo real
docker logs -f pentaho-server

# Últimas 100 linhas
docker logs --tail 100 pentaho-server

# Logs com timestamp
docker logs --timestamps pentaho-server

# Buscar erros
docker logs pentaho-server 2>&1 | grep -i error

# Buscar exceções
docker logs pentaho-server 2>&1 | grep -i exception

# Logs do Tomcat
docker exec pentaho-server tail -f /opt/pentaho/pentaho-server/tomcat/logs/catalina.out

# Logs de acesso
docker exec pentaho-server tail -f /opt/pentaho/pentaho-server/tomcat/logs/localhost_access_log.*.txt
```

### Script de Diagnóstico Completo

Crie `full-diagnose.sh`:

```bash
#!/bin/bash

echo "=== DIAGNÓSTICO COMPLETO PENTAHO ==="
echo ""
echo "Data: $(date)"
echo "Sistema: $(uname -a)"
echo ""

echo "=== 1. CONTAINERS ==="
docker ps -a
echo ""

echo "=== 2. IMAGENS ==="
docker images | grep pentaho
echo ""

echo "=== 3. VOLUMES ==="
docker volume ls | grep pentaho
echo ""

echo "=== 4. REDES ==="
docker network ls | grep pentaho
docker network inspect pentaho-net 2>/dev/null || echo "Rede não encontrada"
echo ""

echo "=== 5. HEALTH PENTAHO ==="
docker inspect pentaho-server --format='Status: {{.State.Status}} | Health: {{.State.Health.Status}}'
docker inspect pentaho-server | grep -A 30 '"Health":'
echo ""

echo "=== 6. HEALTH POSTGRES ==="
docker inspect pentaho-postgres --format='Status: {{.State.Status}} | Health: {{.State.Health.Status}}'
echo ""

echo "=== 7. STARTUP STATUS ==="
docker logs pentaho-server 2>&1 | grep "Server startup in" | tail -1
echo ""

echo "=== 8. ERROS RECENTES ==="
docker logs --tail 50 pentaho-server 2>&1 | grep -i error
echo ""

echo "=== 9. COMMONS-POOL CHECK ==="
docker exec pentaho-server ls -la /opt/pentaho/pentaho-server/tomcat/lib/ | grep commons-pool
echo ""

echo "=== 10. PORTAS ==="
docker port pentaho-server
docker port pentaho-postgres
echo ""

echo "=== 11. TESTE CONECTIVIDADE ==="
echo -n "Pentaho HTTP: "
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/pentaho/
echo ""
echo -n "PostgreSQL: "
docker exec pentaho-server nc -zv repository 5432 2>&1 | grep succeeded || echo "FALHOU"
echo ""

echo "=== 12. RECURSOS ==="
docker stats --no-stream pentaho-server pentaho-postgres
echo ""

echo "=== 13. CONFIGURAÇÃO .env ==="
cat .env | grep -v "^#" | grep -v "^$"
echo ""

echo "=== 14. ÚLTIMOS 30 LOGS ==="
docker logs --tail 30 pentaho-server
echo ""

echo "=== FIM DIAGNÓSTICO ==="
```

Execute:
```bash
chmod +x full-diagnose.sh
./full-diagnose.sh > diagnostico-$(date +%Y%m%d-%H%M%S).txt
```

---

## 🆘 Procedimentos de Recuperação

### Reset Completo

```bash
# ⚠️ ATENÇÃO: APAGA TODOS OS DADOS

# 1. Parar tudo
docker compose down

# 2. Remover volumes
docker volume rm pentaho_server_pentaho_data
docker volume rm pentaho_server_pentaho_solutions
docker volume rm pentaho_server_postgres_data

# 3. Remover imagens (opcional)
docker rmi pentaho_server-pentaho-server

# 4. Reconstruir
docker compose build --no-cache

# 5. Iniciar
docker compose up -d
```

### Reset Apenas PostgreSQL

```bash
# Parar containers
docker compose down

# Remover apenas volume do PostgreSQL
docker volume rm pentaho_server_postgres_data

# Reiniciar
docker compose up -d
```

### Reset Apenas Pentaho

```bash
# Parar Pentaho
docker compose stop pentaho-server

# Remover dados
docker volume rm pentaho_server_pentaho_data

# Reiniciar
docker compose up -d pentaho-server
```

---

## 📞 Suporte Adicional

### Documentação Relacionada

- [README.md](README.md) - Documentação principal
- [SYSTEM_REQUIREMENTS.md](SYSTEM_REQUIREMENTS.md) - Otimização de recursos
- [NETWORK_ACCESS.md](NETWORK_ACCESS.md) - Problemas de rede
- [VERSIONING.md](VERSIONING.md) - Informações sobre versão

### Informações para Reportar Problemas

Ao reportar problemas, inclua:

1. Saída do diagnóstico completo (`full-diagnose.sh`)
2. Versão do Docker: `docker --version`
3. Sistema operacional: `uname -a` ou `systeminfo`
4. Conteúdo do `.env` (remova senhas!)
5. Últimos 100 logs: `docker logs --tail 100 pentaho-server`

### Comandos de Debug Avançado

```bash
# Entrar no container
docker exec -it pentaho-server bash

# Dentro do container:
# - Ver processos
ps aux

# - Ver portas
netstat -tlnp

# - Testar banco
psql -h repository -U postgres -d postgres

# - Ver variáveis de ambiente
env | grep PENTAHO

# - Ver arquivos de configuração
cat /opt/pentaho/pentaho-server/tomcat/conf/server.xml

# - Reiniciar Pentaho (dentro do container)
/opt/pentaho/pentaho-server/stop-pentaho.sh
/opt/pentaho/pentaho-server/start-pentaho.sh
```

---

**Última atualização**: Junho 2026  
**Versão**: 1.1.0
