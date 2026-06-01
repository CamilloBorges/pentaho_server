# Pentaho Server Community Edition - Docker Deployment

![Pentaho](https://img.shields.io/badge/Pentaho-CE%209.4-blue)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-336791)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED)
![License](https://img.shields.io/badge/License-Apache%202.0-green)

Deployment completo e pronto para produção do Pentaho Server Community Edition com PostgreSQL usando Docker Compose.

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Características](#características)
- [Pré-requisitos](#pré-requisitos)
- [Quick Start](#quick-start)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Configuração](#configuração)
- [Sistema de Override](#sistema-de-override)
- [Arquitetura](#arquitetura)
- [Gerenciamento de Banco de Dados](#gerenciamento-de-banco-de-dados)
- [Comandos Úteis](#comandos-úteis)
- [Troubleshooting](#troubleshooting)
- [Produção](#produção)
- [Backup e Recuperação](#backup-e-recuperação)

## 🎯 Visão Geral

Este projeto fornece um ambiente Docker completo e pronto para produção para:

- **Pentaho Server 9.4.0.0-343** (Community Edition)
- **PostgreSQL 15** com bancos de dados do repositório Pentaho

### ⚠️ Por que versão 9.4 e não 10+?

A partir da versão 10.0, o Pentaho Server passou a **exigir licença comercial** mesmo para a edição Community. A versão **9.4.0.0-343 é a última versão verdadeiramente open-source** (Apache License 2.0) sem restrições de uso comercial.

📚 Para mais detalhes, consulte: [VERSIONING.md](VERSIONING.md)

### Baseado em

Adaptado da instalação Enterprise Edition disponível em: [Workshop--Installation](https://github.com/jporeilly/Workshop--Installation/tree/main/Pentaho-Containers/On-Prem/Pentaho-Server-PostgreSQL)

## ✨ Características

- ✅ Completamente auto-contido e portátil
- ✅ Inicialização automática do banco de dados
- ✅ Health checks e ordenação adequada de inicialização
- ✅ Volumes de dados persistentes
- ✅ Backup e restore fáceis
- ✅ Templates de configuração prontos para produção
- ✅ Driver PostgreSQL JDBC incluído
- ✅ Containers read-only com tmpfs mounts para segurança
- ✅ Limites de recursos (CPU/memória) para estabilidade
- ✅ Rotação de logs para prevenir esgotamento de disco

## 📦 Pré-requisitos

### Requisitos do Sistema

- **SO**: Windows 10/11, Ubuntu 20.04+, macOS
- **CPU**: 2+ núcleos (4+ recomendado)
- **RAM**: 4GB mínimo, 8GB+ recomendado
- **Disco**: 10GB+ espaço disponível
- **Portas**: 8080 (HTTP), 8443 (HTTPS), 5432 (PostgreSQL)

📊 Para sistemas com recursos limitados, consulte: [SYSTEM_REQUIREMENTS.md](SYSTEM_REQUIREMENTS.md)

### Requisitos de Software

1. **Docker Engine 20.10+**
   ```bash
   # Windows/macOS: Instale Docker Desktop
   # Linux (Ubuntu):
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   sudo usermod -aG docker $USER
   ```

2. **Docker Compose 2.0+**
   ```bash
   # Verificar instalação
   docker compose version
   ```

3. **Pacote Pentaho**
   - Baixe `pentaho-server-ce-9.4.0.0-343.zip` de [GitHub](https://github.com/ambientelivre/legacy-pentaho-ce/releases/download/pentaho-server-ce-9.4.0.0-343/pentaho-server-ce-9.4.0.0-343.zip)
   - Coloque em `docker/stagedArtifacts/`

## 🚀 Quick Start

### 1. Clone ou Baixe este Projeto

```bash
git clone <seu-repositorio>
cd pentaho_server
```

### 2. Prepare o Pacote Pentaho

```bash
# Coloque o pacote Pentaho no diretório de staged artifacts
cp /path/to/pentaho-server-ce-9.4.0.0-343.zip docker/stagedArtifacts/
```

### 3. Configure o Ambiente (Opcional)

```bash
# Crie o arquivo .env a partir do template
cp .env.template .env

# Edite o .env para personalizar configurações (opcional)
nano .env
```

### 4. Deploy Automatizado

#### Windows (PowerShell)
```powershell
# Torne os scripts executáveis e execute o deploy
docker compose build --no-cache pentaho-server
docker compose up -d
```

#### Linux/macOS
```bash
# Dê permissão de execução aos scripts
chmod +x scripts/*.sh

# Execute o deploy automatizado
./scripts/deploy.sh
```

### 5. Acesse os Serviços

Após a conclusão do deployment (aguarde 2-5 minutos para inicialização completa):

- **Pentaho Server**: http://localhost:8080/pentaho
  - Usuário: `admin`
  - Senha: `password`

- **PostgreSQL**:
  - Host: `localhost`
  - Port: `5432`
  - Senha: `password`

## 📁 Estrutura do Projeto

```
pentaho_server/
├── README.md                           # Esta documentação
├── docker-compose.yml                  # Definição dos serviços Docker
├── .env.template                       # Template de configuração
├── .env                                # Configuração do ambiente (criar)
├── .gitignore                          # Arquivos ignorados pelo Git
│
├── docker/                             # Contexto de build Docker
│   ├── Dockerfile                      # Imagem Pentaho Server CE
│   ├── entrypoint/
│   │   └── docker-entrypoint.sh        # Script de inicialização
│   └── stagedArtifacts/                # Pacotes Pentaho
│       └── pentaho-server-ce-*.zip     # (colocar aqui)
│
├── db_init_postgres/                   # Scripts de inicialização PostgreSQL
│   ├── 1_create_jcr_postgres.sql       # JackRabbit (JCR)
│   ├── 2_create_quartz_postgres.sql    # Quartz Scheduler
│   └── 3_create_repository_postgres.sql # Hibernate Repository
│
├── postgres-config/                    # Configuração PostgreSQL
│   └── custom.conf                     # Tuning de performance
│
├── softwareOverride/                   # Customizações Pentaho
│   ├── README.md                       # Documentação do sistema
│   ├── 1_drivers/                      # Drivers JDBC
│   ├── 2_repository/                   # Configuração de BD
│   ├── 3_security/                     # Configurações de segurança
│   ├── 4_others/                       # Outras configurações
│   └── 99_exchange/                    # Troca de arquivos
│
├── scripts/                            # Scripts utilitários
│   ├── deploy.sh                       # Deploy automatizado
│   ├── backup-postgres.sh              # Backup do banco
│   ├── restore-postgres.sh             # Restore do banco
│   └── validate-deployment.sh          # Validação do deployment
│
├── secrets/                            # Secrets do Docker
│   └── postgres_password.txt           # Senha PostgreSQL
│
├── config/                             # Configurações de usuário
│   ├── .kettle/                        # Configuração PDI/Kettle
│   └── .pentaho/                       # Configurações Pentaho
│
└── backups/                            # Armazenamento de backups
```

## ⚙️ Configuração

### Variáveis de Ambiente

Edite o arquivo `.env` para customizar:

```bash
# Versão do Pentaho
PENTAHO_VERSION=9.4.0.0-343

# Portas
PENTAHO_HTTP_PORT=8080
PENTAHO_HTTPS_PORT=8443
POSTGRES_PORT=5432

# Memória JVM (ajuste conforme RAM disponível)
PENTAHO_MIN_MEMORY=2048m
PENTAHO_MAX_MEMORY=4096m
PENTAHO_MAX_MEMORY_LIMIT=6G

# Senhas (MUDE PARA PRODUÇÃO!)
POSTGRES_PASSWORD=password
PENTAHO_PASSWORD=password
```

### Configuração do PostgreSQL

Customize `postgres-config/custom.conf`:

```conf
# Limites de conexão
max_connections = 200

# Memória (ajuste conforme RAM disponível)
shared_buffers = 256MB
effective_cache_size = 768MB
work_mem = 16MB

# Performance
random_page_cost = 1.1
effective_io_concurrency = 200
```

## 🔧 Sistema de Override

O diretório `softwareOverride/` permite customizar o Pentaho Server sem modificar a instalação base.

### Estrutura de Diretórios

```
softwareOverride/
├── 1_drivers/              # JDBC drivers
│   └── tomcat/lib/
├── 2_repository/           # Configuração de BD
│   └── pentaho-solutions/system/
├── 3_security/             # Autenticação
│   └── pentaho-solutions/system/
└── 4_others/               # Outras configurações
    └── pentaho-solutions/system/
```

### Ordem de Processamento

Os diretórios são processados alfabeticamente durante a inicialização:

1. **1_drivers** - Drivers disponíveis antes das conexões
2. **2_repository** - Configuração de banco de dados
3. **3_security** - Mecanismos de autenticação
4. **4_others** - Configurações da aplicação

### Adicionando Customizações

1. Crie a estrutura de diretórios correspondente
2. Coloque seus arquivos de configuração
3. Reconstrua: `docker compose build pentaho-server`
4. Reinicie: `docker compose up -d pentaho-server`

## 🏗️ Arquitetura

### Serviços

```
┌─────────────────────────────────────────┐
│  pentaho-server:8080                    │
│  - Pentaho Server 9.4.0.0-343 CE        │
│  - Tomcat 9                             │
│  - OpenJDK 21                           │
│  - Limites: 6GB RAM, 4 CPUs             │
└─────────────┬───────────────────────────┘
              │ JDBC Connection (port 5432)
              ▼
┌─────────────────────────────────────────┐
│  postgres:5432 (hostname: repository)   │
│  - PostgreSQL 15                        │
│  - Limites: 2GB RAM, 2 CPUs             │
│  - 3 Bancos de Dados Pentaho:           │
│    • jackrabbit (JCR)                   │
│    • quartz (Scheduler)                 │
│    • hibernate (Repository/Logging)     │
└─────────────────────────────────────────┘
```

### Persistência de Dados

Volumes Docker nomeados garantem persistência:

- `pentaho_postgres_data` - Bancos de dados PostgreSQL
- `pentaho_solutions` - Repositório de soluções Pentaho
- `pentaho_data` - Arquivos de dados Pentaho

### Rede

Rede bridge `pentaho-net` (172.28.0.0/16) fornece:

- Descoberta de serviços (containers podem se comunicar por hostname)
- Isolamento de rede do host
- Subnet customizada para evitar conflitos com VPN

## 🗄️ Gerenciamento de Banco de Dados

### Backup do Banco de Dados

#### Windows (PowerShell)
```powershell
# Criar backup comprimido
docker compose exec -T postgres pg_dumpall -U postgres | gzip > backups/pentaho-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss').sql.gz
```

#### Linux/macOS
```bash
# Criar backup comprimido
./scripts/backup-postgres.sh
```

Backups são salvos em `backups/` com timestamp.

### Restore do Banco de Dados

#### Windows (PowerShell)
```powershell
# Restaurar de um backup
docker compose stop pentaho-server
Get-Content backups/pentaho-backup-YYYYMMDD-HHMMSS.sql.gz | gunzip | docker compose exec -T postgres psql -U postgres
docker compose up -d
```

#### Linux/macOS
```bash
./scripts/restore-postgres.sh backups/pentaho-postgres-backup-YYYYMMDD-HHMMSS.sql.gz
```

### Acesso Manual ao Banco

```bash
# PostgreSQL CLI (psql)
docker exec -it pentaho-postgres psql -U postgres

# Listar bancos de dados
\l

# Conectar a um banco específico
\c jackrabbit

# Listar tabelas
\dt
```

## 💻 Comandos Úteis

### Gerenciamento de Serviços

```bash
# Iniciar todos os serviços
docker compose up -d

# Parar todos os serviços
docker compose stop

# Reiniciar serviço específico
docker compose restart pentaho-server

# Ver status dos serviços
docker compose ps

# Remover todos os containers (mantém volumes)
docker compose down

# Remover tudo incluindo volumes (DESTRUTIVO!)
docker compose down -v
```

### Logs

```bash
# Ver todos os logs
docker compose logs

# Seguir logs em tempo real
docker compose logs -f

# Ver logs de serviço específico
docker compose logs pentaho-server
docker compose logs postgres

# Últimas 100 linhas
docker compose logs --tail=100 pentaho-server
```

### Acesso Shell

```bash
# Shell Pentaho Server
docker compose exec pentaho-server bash

# Shell PostgreSQL
docker compose exec postgres bash

# psql diretamente
docker compose exec postgres psql -U postgres
```

### Monitoramento de Recursos

```bash
# Uso de recursos em tempo real
docker stats

# Uso de disco
docker system df

# Detalhes dos volumes
docker volume ls
docker volume inspect pentaho_postgres_data
```

## 🔍 Troubleshooting

### Container não Inicia

```bash
# Verificar status do container
docker compose ps

# Ver logs
docker compose logs pentaho-server
docker compose logs postgres

# Reiniciar serviço específico
docker compose restart pentaho-server
```

### Porta Já em Uso

```bash
# Windows
netstat -ano | findstr :8080
netstat -ano | findstr :5432

# Linux/macOS
sudo lsof -i :8080
sudo lsof -i :5432

# Matar processo ou mudar porta no .env
```

### Erros de Conexão PostgreSQL

```bash
# Verificar se PostgreSQL está saudável
docker compose ps postgres

# Ver logs do PostgreSQL
docker compose logs postgres

# Testar conexão
docker exec pentaho-postgres pg_isready -U postgres
```

### Out of Memory

```bash
# Verificar uso de recursos
docker stats

# Aumentar memória JVM no .env
PENTAHO_MAX_MEMORY=6144m

# Reiniciar Pentaho
docker compose restart pentaho-server
```

### Validar Deployment

#### Linux/macOS
```bash
./scripts/validate-deployment.sh
```

#### Windows (Manual)
```powershell
# Verificar containers
docker compose ps

# Verificar bancos de dados
docker compose exec postgres psql -U postgres -c "\l"

# Testar acesso Pentaho
curl http://localhost:8080/pentaho/Login
```

## 🔒 Produção

### Checklist de Segurança

- [ ] Mudar todas as senhas padrão (PostgreSQL, admin)
- [ ] Restringir exposição da porta PostgreSQL
- [ ] Configurar firewall para portas necessárias
- [ ] Habilitar SSL/TLS para Pentaho Server
- [ ] Configurar backups automáticos regulares
- [ ] Configurar rotação de logs
- [ ] Atualizar imagens base regularmente
- [ ] Implementar monitoramento e alertas

### Mudar Senhas Padrão

1. **Senha PostgreSQL**
   
   Edite `.env`:
   ```bash
   POSTGRES_PASSWORD=sua_senha_segura_aqui
   ```

2. **Senha Admin Pentaho**
   
   Após primeiro login, mude via interface web do Pentaho.

### Restringir Porta PostgreSQL

Edite `docker-compose.yml` - remova ou comente a exposição da porta:

```yaml
postgres:
  # Comentar ou remover:
  # ports:
  #   - "${POSTGRES_PORT:-5432}:5432"
```

### Backups Automatizados

Configure um cron job (Linux/macOS):

```bash
# Editar crontab
crontab -e

# Adicionar backup diário às 2 AM
0 2 * * * /path/to/pentaho_server/scripts/backup-postgres.sh

# Adicionar limpeza semanal (manter últimos 30 dias)
0 3 * * 0 find /path/to/pentaho_server/backups/ -name "*.sql.gz" -mtime +30 -delete
```

Windows (Task Scheduler):
```powershell
# Criar script de backup backup-daily.ps1
# Agendar via Task Scheduler
```

## 💾 Backup e Recuperação

### Recuperação de Desastre

Recuperação Completa do Sistema:

1. Instalar Docker e Docker Compose no novo sistema
2. Clonar/copiar este diretório do projeto
3. Colocar ZIP do Pentaho em `docker/stagedArtifacts/`
4. Restaurar arquivo `.env` com configuração original
5. Restaurar banco de dados do backup
6. Iniciar serviços

```bash
# Restaurar banco de dados
./scripts/restore-postgres.sh backups/seu-backup.sql.gz

# Iniciar serviços
docker compose up -d
```

### Backup de Volumes

```bash
# Backup do volume PostgreSQL
docker run --rm \
  -v pentaho_postgres_data:/data \
  -v $(pwd)/backups:/backup \
  alpine tar czf /backup/postgres-volume-$(date +%Y%m%d).tar.gz -C /data .

# Backup do volume solutions
docker run --rm \
  -v pentaho_solutions:/data \
  -v $(pwd)/backups:/backup \
  alpine tar czf /backup/solutions-volume-$(date +%Y%m%d).tar.gz -C /data .
```

## 📚 Recursos e Suporte

### Documentação

- [Pentaho 9.4 Documentation](https://help.hitachivantara.com/Documentation/Pentaho/9.4)
- [Pentaho Community](https://community.hitachivantara.com/)
- [Informações sobre Versionamento](VERSIONING.md)
- [Docker Documentation](https://docs.docker.com/)
- [PostgreSQL 15 Documentation](https://www.postgresql.org/docs/15/)

### Contribuindo

Sinta-se livre para abrir issues ou pull requests com melhorias.

## 📝 Licença

Este projeto de deployment é fornecido como está. O Pentaho Server Community Edition é licenciado sob Apache License 2.0.

## 🙏 Agradecimentos

Baseado no trabalho de [jporeilly/Workshop--Installation](https://github.com/jporeilly/Workshop--Installation), adaptado para a versão Community Edition.

---

**Versão do Projeto**: 1.0.0  
**Versão do Pentaho**: 9.4.0.0-343 (Community Edition)  
**Versão do PostgreSQL**: 15  
**Última Atualização**: 2024

Para questões ou problemas, consulte a seção [Troubleshooting](#troubleshooting) ou revise os logs gerados.
