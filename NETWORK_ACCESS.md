# Acesso Remoto ao Pentaho Server

## 🌐 Configuração de Rede

Este guia explica como configurar o acesso ao Pentaho Server de redes externas.

## 📋 Pré-requisitos

1. Servidor com IP público ou acessível na rede: `191.101.70.239`
2. Docker e Docker Compose instalados
3. Portas 8080 e 8443 liberadas no firewall

## 🔧 Configuração Padrão

Por padrão, o Docker Compose está configurado para aceitar conexões de qualquer origem:

```yaml
ports:
  - "8080:8080"    # HTTP - acessa de qualquer IP
  - "8443:8443"    # HTTPS - acessa de qualquer IP
```

Isso é equivalente a:
```yaml
ports:
  - "0.0.0.0:8080:8080"
  - "0.0.0.0:8443:8443"
```

## 🚨 Problemas Comuns e Soluções

### ❌ Erro 404 ao Acessar

**Sintoma**: `http://191.101.70.239:8080/pentaho` retorna 404

**Causas Possíveis**:

#### 1. Pentaho ainda está inicializando ⏳

```bash
# Verificar status de inicialização
docker logs pentaho-server 2>&1 | tail -50

# Procurar por:
# "INFO: Server startup in [xxxxx] milliseconds" ✅
# "INFO: Starting ProtocolHandler" ✅
```

**Solução**: Aguardar 5-10 minutos na primeira inicialização.

#### 2. Container não está rodando ⚠️

```bash
# Verificar status
docker ps -a | grep pentaho

# Se STATUS não for "Up", verificar logs
docker logs pentaho-server

# Reiniciar se necessário
docker compose restart pentaho-server
```

#### 3. Path incorreto 🔗

Tente estas URLs:
- ✅ `http://191.101.70.239:8080/pentaho`
- ✅ `http://191.101.70.239:8080/pentaho/`
- ✅ `http://191.101.70.239:8080/pentaho/Login` (página de login direta)

#### 4. Problemas de contexto do Tomcat 🔧

Se o erro persistir, verifique o contexto do Tomcat:

```bash
# Verificar se o webapp foi deployed
docker exec pentaho-server ls -la /opt/pentaho/pentaho-server/tomcat/webapps/

# Deve existir o diretório "pentaho"
```

### ❌ Connection Timeout / Refused

**Sintoma**: Navegador não consegue conectar

**Causas e Soluções**:

#### 1. Firewall do servidor bloqueando 🔥

```bash
# Ubuntu/Debian - UFW
sudo ufw status
sudo ufw allow 8080/tcp
sudo ufw allow 8443/tcp

# CentOS/RHEL - Firewalld
sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent
sudo firewall-cmd --zone=public --add-port=8443/tcp --permanent
sudo firewall-cmd --reload

# Verificar portas abertas
sudo netstat -tlnp | grep :8080
```

#### 2. Docker fazendo bind apenas em localhost 🔒

```bash
# Verificar bind da porta
docker port pentaho-server

# Deve mostrar:
# 8080/tcp -> 0.0.0.0:8080  ✅ CORRETO - aceita de qualquer IP
# 8080/tcp -> 127.0.0.1:8080  ❌ ERRADO - só localhost
```

**Solução se estiver em 127.0.0.1**:

Edite `docker-compose.yml`:

```yaml
ports:
  - "0.0.0.0:8080:8080"     # Bind explícito em todas interfaces
  - "0.0.0.0:8443:8443"
```

Recrie o container:
```bash
docker compose down
docker compose up -d
```

#### 3. Cloud Provider bloqueando (AWS, Azure, GCP) ☁️

Se estiver em cloud, verifique:
- **Security Groups** (AWS)
- **Network Security Groups** (Azure)
- **Firewall Rules** (GCP)

Certifique-se que permitem tráfego de entrada nas portas 8080 e 8443.

#### 4. SELinux bloqueando (CentOS/RHEL) 🛡️

```bash
# Verificar status do SELinux
getenforce

# Se "Enforcing", pode estar bloqueando
# Testar temporariamente:
sudo setenforce 0

# Se funcionar, configurar permanentemente:
sudo setsebool -P httpd_can_network_connect 1
```

### ❌ Erro 502 Bad Gateway

**Causa**: Reverse proxy (Nginx/Apache) não consegue conectar ao Pentaho

**Solução**: Verificar configuração do proxy e conectividade com container

### ❌ Erro 500 Internal Server Error

**Causa**: Problema de configuração do Pentaho ou banco de dados

```bash
# Verificar logs detalhados
docker logs pentaho-server 2>&1 | grep -i error
docker logs pentaho-server 2>&1 | grep -i exception

# Verificar conexão com PostgreSQL
docker logs pentaho-server | grep -i postgres
```

## 🧪 Teste de Conectividade

### Teste 1: Do próprio servidor

```bash
# Teste HTTP interno
curl -v http://localhost:8080/pentaho

# Teste HTTP pelo IP
curl -v http://191.101.70.239:8080/pentaho

# Teste com código de resposta
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/pentaho
# Deve retornar: 200 ou 302 (redirect) ✅
# Se retornar: 404, Pentaho não iniciou ou path incorreto ❌
```

### Teste 2: Verificar se porta está ouvindo

```bash
# Listar portas abertas
sudo netstat -tlnp | grep 8080
# ou
sudo ss -tlnp | grep 8080

# Deve mostrar:
# tcp6  0  0  :::8080  :::*  LISTEN  <pid>/docker-proxy
```

### Teste 3: Teste de rede externo

De outra máquina:

```bash
# Teste de ping (ICMP)
ping 191.101.70.239

# Teste de porta TCP
telnet 191.101.70.239 8080
# ou
nc -zv 191.101.70.239 8080

# Teste HTTP
curl -I http://191.101.70.239:8080/pentaho
```

### Teste 4: Dentro do container

```bash
# Acessar shell do container
docker exec -it pentaho-server bash

# Dentro do container:
curl http://localhost:8080/pentaho
ps aux | grep java
netstat -tlnp
exit
```

## 🔒 Segurança para Acesso Externo

### 1. Restrição por IP (Recomendado)

Se você tem IPs fixos, restrinja o acesso:

```yaml
# docker-compose.yml
ports:
  - "192.168.1.100:8080:8080"  # Apenas desta origem
```

Ou use firewall:

```bash
# Permitir apenas de IPs específicos
sudo ufw allow from 203.0.113.0/24 to any port 8080
sudo ufw deny 8080
```

### 2. HTTPS Obrigatório

Configure certificado SSL/TLS:

```bash
# Gerar certificado auto-assinado (desenvolvimento)
openssl req -newkey rsa:2048 -nodes \
  -keyout pentaho.key \
  -x509 -days 365 \
  -out pentaho.crt

# Copiar para o container
docker cp pentaho.key pentaho-server:/opt/pentaho/pentaho-server/tomcat/conf/
docker cp pentaho.crt pentaho-server:/opt/pentaho/pentaho-server/tomcat/conf/
```

Para produção, use certificado válido (Let's Encrypt).

### 3. Reverse Proxy (Nginx/Traefik)

Configure proxy reverso com:
- SSL/TLS terminação
- Autenticação básica
- Rate limiting
- WAF (Web Application Firewall)

### 4. Altere Senhas Padrão

**IMPORTANTE**: Altere as senhas padrão!

```bash
# Editar .env
PENTAHO_PASSWORD=SuaSenhaForte123!
POSTGRES_PASSWORD=SenhaPostgresSegura456!
```

Recrie os containers:
```bash
docker compose down -v  # ⚠️ APAGA DADOS
docker compose up -d
```

### 5. VPN / Túnel SSH

Para acesso mais seguro:

```bash
# SSH Tunnel
ssh -L 8080:localhost:8080 root@191.101.70.239

# Acessar via: http://localhost:8080/pentaho
```

## 📊 Monitoramento de Acesso

### Logs de Acesso

```bash
# Logs do Tomcat
docker exec pentaho-server tail -f /opt/pentaho/pentaho-server/tomcat/logs/localhost_access_log.*.txt

# Logs de aplicação
docker logs -f pentaho-server
```

### Métricas

```bash
# Conexões ativas
docker exec pentaho-server netstat -an | grep :8080 | wc -l

# Top processos
docker stats pentaho-server
```

## 🔧 Configurações Avançadas

### Múltiplos IPs/Portas

```yaml
ports:
  - "8080:8080"      # HTTP padrão
  - "8081:8080"      # HTTP alternativo
  - "443:8443"       # HTTPS na porta padrão
```

### IPv6

```yaml
ports:
  - "[::]:8080:8080"  # Aceitar IPv6
```

## 📚 Checklist de Troubleshooting

Quando tiver problemas de acesso externo, siga esta ordem:

- [ ] 1. Container está rodando? `docker ps`
- [ ] 2. Pentaho iniciou completamente? `docker logs pentaho-server | grep "startup in"`
- [ ] 3. Porta está ouvindo? `sudo netstat -tlnp | grep 8080`
- [ ] 4. Bind está em 0.0.0.0? `docker port pentaho-server`
- [ ] 5. Firewall permite? `sudo ufw status`
- [ ] 6. Teste local funciona? `curl http://localhost:8080/pentaho`
- [ ] 7. Teste externo funciona? `telnet 191.101.70.239 8080`
- [ ] 8. Cloud firewall permite? (Security Groups, etc)
- [ ] 9. SELinux/AppArmor bloqueando? `getenforce`
- [ ] 10. Logs mostram erros? `docker logs pentaho-server | grep -i error`

## 🆘 Comandos de Diagnóstico Completo

Execute este script no servidor:

```bash
#!/bin/bash
echo "=== DIAGNÓSTICO PENTAHO NETWORK ==="
echo ""
echo "1. CONTAINERS:"
docker ps -a | grep pentaho
echo ""
echo "2. PORTAS DOCKER:"
docker port pentaho-server
echo ""
echo "3. PORTAS SISTEMA:"
sudo netstat -tlnp | grep :8080
echo ""
echo "4. FIREWALL (UFW):"
sudo ufw status 2>/dev/null || echo "UFW não instalado"
echo ""
echo "5. FIREWALL (FIREWALLD):"
sudo firewall-cmd --list-all 2>/dev/null || echo "Firewalld não instalado"
echo ""
echo "6. SELINUX:"
getenforce 2>/dev/null || echo "SELinux não ativo"
echo ""
echo "7. TESTE LOCAL:"
curl -s -o /dev/null -w "HTTP %{http_code}\n" http://localhost:8080/pentaho
echo ""
echo "8. LOGS RECENTES:"
docker logs --tail 20 pentaho-server
echo ""
echo "9. STARTUP STATUS:"
docker logs pentaho-server 2>&1 | grep -i "server startup" | tail -1
echo ""
echo "=== FIM DIAGNÓSTICO ==="
```

Salve como `diagnose-network.sh`, execute:
```bash
chmod +x diagnose-network.sh
./diagnose-network.sh
```

---

**Veja também**:
- [README.md](README.md) - Documentação principal
- [SYSTEM_REQUIREMENTS.md](SYSTEM_REQUIREMENTS.md) - Requisitos de sistema
- [TROUBLESHOOTING.md](README.md#troubleshooting) - Problemas gerais
