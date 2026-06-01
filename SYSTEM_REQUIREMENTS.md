# Requisitos de Sistema e Otimização

## ⚙️ Requisitos Mínimos vs Recomendados

### Configuração Mínima (Ajustada)
- **CPU**: 2 núcleos
- **RAM**: 4GB disponível
- **Disco**: 10GB livre
- **Docker**: 20.10+
- **Docker Compose**: 2.0+

### Configuração Recomendada
- **CPU**: 4+ núcleos
- **RAM**: 8GB+ disponível
- **Disco**: 20GB+ livre (SSD preferível)
- **Docker**: Última versão
- **Docker Compose**: Última versão

## 🔧 Ajustes para Recursos Limitados

### Sistema com 2 CPUs

O projeto já está configurado para funcionar com **2 CPUs**:

**Alocação padrão:**
- PostgreSQL: 1 CPU (limite), 0.5 CPU (reserva)
- Pentaho Server: 2 CPUs (limite), 1 CPU (reserva)

Se ainda enfrentar problemas, edite [docker-compose.yml](docker-compose.yml):

```yaml
# PostgreSQL - Reduzir ainda mais se necessário
deploy:
  resources:
    limits:
      cpus: '0.5'
      memory: 1G
    reservations:
      cpus: '0.25'
      memory: 256M

# Pentaho Server - Configuração mínima
deploy:
  resources:
    limits:
      cpus: '1.5'
      memory: 3G
    reservations:
      cpus: '0.5'
      memory: 1G
```

### Sistema com 4GB RAM

Edite [.env](.env) ou [.env.template](.env.template):

```bash
# Reduzir memória JVM
PENTAHO_MIN_MEMORY=512m
PENTAHO_MAX_MEMORY=1536m
PENTAHO_MAX_MEMORY_LIMIT=2G
```

E ajuste [docker-compose.yml](docker-compose.yml):

```yaml
# PostgreSQL
deploy:
  resources:
    limits:
      memory: 1G
    reservations:
      memory: 256M

# Pentaho Server
deploy:
  resources:
    limits:
      memory: 2G
    reservations:
      memory: 1G
```

### Sistema com 1 CPU (não recomendado)

⚠️ **Não é recomendado**, mas é possível:

```yaml
# PostgreSQL
deploy:
  resources:
    limits:
      cpus: '0.3'
      memory: 768M
    reservations:
      cpus: '0.1'
      memory: 256M

# Pentaho Server
deploy:
  resources:
    limits:
      cpus: '0.7'
      memory: 2G
    reservations:
      cpus: '0.3'
      memory: 768M
```

**Observações:**
- Performance será significativamente degradada
- Inicialização pode levar 10-15 minutos
- Operações serão lentas

## 🎯 Configurações Otimizadas por Cenário

### Desenvolvimento Local (Notebook/Desktop básico)

```bash
# .env
PENTAHO_MIN_MEMORY=1024m
PENTAHO_MAX_MEMORY=2048m
PENTAHO_MAX_MEMORY_LIMIT=3G
```

```yaml
# docker-compose.yml - Pentaho
deploy:
  resources:
    limits:
      cpus: '1.5'
      memory: 3G
    reservations:
      cpus: '0.5'
      memory: 1G
```

### Servidor de Testes (VM média)

```bash
# .env
PENTAHO_MIN_MEMORY=2048m
PENTAHO_MAX_MEMORY=4096m
PENTAHO_MAX_MEMORY_LIMIT=5G
```

```yaml
# docker-compose.yml - Pentaho
deploy:
  resources:
    limits:
      cpus: '3'
      memory: 5G
    reservations:
      cpus: '1'
      memory: 2G
```

### Produção (Servidor dedicado)

```bash
# .env
PENTAHO_MIN_MEMORY=4096m
PENTAHO_MAX_MEMORY=8192m
PENTAHO_MAX_MEMORY_LIMIT=10G
```

```yaml
# docker-compose.yml - Pentaho
deploy:
  resources:
    limits:
      cpus: '6'
      memory: 10G
    reservations:
      cpus: '2'
      memory: 4G
```

## 📊 Monitoramento de Recursos

### Ver uso atual

```bash
# Recursos em tempo real
docker stats

# Detalhes específicos
docker stats pentaho-server pentaho-postgres

# Verificar limites
docker inspect pentaho-server | grep -A 10 "Resources"
```

### Logs de performance

```bash
# Ver tempo de inicialização
docker compose logs pentaho-server | grep "Server startup"

# Verificar se há throttling de CPU
docker stats --no-stream

# Memória usada vs disponível
docker compose exec pentaho-server free -h
```

## 🔍 Diagnóstico de Problemas

### Erro: "range of CPUs is from 0.01 to X"

**Problema**: Sistema não tem CPUs suficientes

**Solução**:
1. Verifique CPUs disponíveis:
   ```bash
   # Linux/macOS
   nproc
   
   # Windows PowerShell
   (Get-WmiObject Win32_ComputerSystem).NumberOfLogicalProcessors
   ```

2. Ajuste os limites no `docker-compose.yml` para ficar abaixo do número de CPUs

3. Reconstrua:
   ```bash
   docker compose down
   docker compose up -d
   ```

### Erro: Out of Memory (OOM)

**Problema**: Memória insuficiente

**Solução**:
1. Verifique memória disponível:
   ```bash
   # Linux
   free -h
   
   # Windows PowerShell
   Get-WmiObject Win32_ComputerSystem | Select TotalPhysicalMemory
   ```

2. Reduza a alocação:
   - Edite `.env` para reduzir `PENTAHO_MAX_MEMORY`
   - Ajuste limites no `docker-compose.yml`

3. Reinicie:
   ```bash
   docker compose restart
   ```

### Container reinicia constantemente

**Problema**: Recursos insuficientes ou configuração incorreta

**Diagnóstico**:
```bash
# Ver motivo da falha
docker compose logs --tail=50 pentaho-server

# Verificar eventos
docker events --filter container=pentaho-server

# Status do container
docker inspect pentaho-server | grep -A 20 "State"
```

**Solução**:
- Aumente timeout do health check
- Reduza uso de memória
- Verifique logs para erros específicos

## 💡 Dicas de Performance

### 1. Use SSD
- Volumes Docker em SSD melhoram significativamente a performance
- Especialmente importante para PostgreSQL

### 2. Ajuste swappiness (Linux)
```bash
# Reduzir uso de swap
sudo sysctl vm.swappiness=10
```

### 3. Docker Desktop - Alocação de Recursos

**Windows/macOS**: Docker Desktop > Settings > Resources

- **CPUs**: Alocar 2-4 CPUs
- **Memory**: Alocar 6-8GB
- **Swap**: 2GB
- **Disk**: 60GB+

### 4. Desabilite serviços não usados

Se não precisa do PgAdmin (modo dev):

```yaml
# docker-compose.dev.yml
# Comente ou remova o serviço pgadmin
# pgadmin:
#   ...
```

### 5. PostgreSQL Tuning

Para sistemas com pouca memória, edite [postgres-config/custom.conf](postgres-config/custom.conf):

```conf
# Configuração para 2GB RAM
shared_buffers = 128MB
effective_cache_size = 512MB
work_mem = 8MB
maintenance_work_mem = 32MB
```

## 🧪 Testes de Performance

### Benchmark de inicialização

```bash
# Medir tempo de startup
time docker compose up -d
docker compose logs -f pentaho-server | grep "Server startup"
```

### Teste de carga

```bash
# Verificar recursos durante operação
watch -n 1 'docker stats --no-stream'
```

## 📋 Checklist de Otimização

Antes de iniciar em ambiente com recursos limitados:

- [ ] Verificar CPUs disponíveis (`nproc` ou Task Manager)
- [ ] Verificar RAM disponível (`free -h` ou Task Manager)
- [ ] Ajustar `.env` com memória apropriada
- [ ] Ajustar `docker-compose.yml` com limites de CPU/RAM
- [ ] Testar startup: `docker compose up -d`
- [ ] Monitorar: `docker stats`
- [ ] Validar: `docker compose logs -f pentaho-server`
- [ ] Ajustar se necessário e reiniciar

## 🆘 Suporte

Se continuar com problemas de recursos:

1. Revise os logs: `docker compose logs`
2. Verifique a documentação: [README.md](README.md)
3. Consulte [TROUBLESHOOTING.md](README.md#troubleshooting)
4. Abra uma issue com detalhes do sistema

---

**Última atualização**: Junho 2024  
**Versão**: 1.1
