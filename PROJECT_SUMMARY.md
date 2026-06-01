# Pentaho Server CE Docker - Sumário do Projeto

## 📋 Visão Geral

Este projeto fornece um ambiente Docker completo e pronto para produção para o Pentaho Server Community Edition com PostgreSQL.

## 🎯 Características Principais

✅ **Deployment Automatizado**
- Scripts de deploy automatizados
- Inicialização automática do banco de dados
- Health checks e ordenação de inicialização

✅ **Segurança**
- Containers read-only
- Tmpfs mounts para segurança
- Secrets management com Docker secrets
- Limites de recursos (CPU/memória)

✅ **Operações**
- Backup e restore automatizados
- Validação de deployment
- Rotação de logs
- Sistema de customização (softwareOverride)

✅ **Desenvolvimento**
- Docker Compose para desenvolvimento
- Hot reload de configurações
- Debug port habilitado
- PgAdmin incluído

## 📊 Arquitetura

```
┌──────────────────────────────────┐
│   Pentaho Server CE 9.4          │
│   - Tomcat 9                     │
│   - OpenJDK 21                   │
│   - Port: 8080, 8443             │
└───────────┬──────────────────────┘
            │
            ▼
┌──────────────────────────────────┐
│   PostgreSQL 15                  │
│   - jackrabbit (JCR)             │
│   - quartz (Scheduler)           │
│   - hibernate (Repository)       │
│   - Port: 5432                   │
└──────────────────────────────────┘
```

## 📁 Estrutura de Arquivos

### Arquivos Principais
- `docker-compose.yml` - Configuração de produção
- `docker-compose.dev.yml` - Configuração de desenvolvimento
- `Dockerfile` - Imagem Pentaho Server CE
- `.env.template` - Template de configuração
- `Makefile` - Comandos úteis (Linux/macOS)

### Diretórios Importantes
- `db_init_postgres/` - Scripts SQL de inicialização
- `docker/entrypoint/` - Script de inicialização do container
- `scripts/` - Scripts de backup, deploy e validação
- `softwareOverride/` - Sistema de customização
- `postgres-config/` - Configuração do PostgreSQL

### Documentação
- `README.md` - Documentação completa
- `QUICKSTART.md` - Guia de início rápido
- `WINDOWS_SETUP.md` - Guia específico para Windows
- `DOWNLOAD.md` - Instruções de download
- `PROJECT_INFO.md` - Informações do projeto

## 🚀 Quick Start

```bash
# 1. Baixar Pentaho Server CE
# Coloque pentaho-server-ce-9.4.0.0-343.zip em docker/stagedArtifacts/

# 2. Criar arquivo de configuração
cp .env.template .env

# 3. Construir e iniciar
docker compose build --no-cache pentaho-server
docker compose up -d

# 4. Acessar
# URL: http://localhost:8080/pentaho
# User: admin / Password: password
```

## 🔧 Comandos Principais

### Gerenciamento
```bash
docker compose up -d              # Iniciar
docker compose stop               # Parar
docker compose restart            # Reiniciar
docker compose logs -f            # Ver logs
docker compose ps                 # Status
```

### Backup & Restore
```bash
# Backup
docker compose exec -T postgres pg_dumpall -U postgres | gzip > backup.sql.gz

# Restore
gunzip -c backup.sql.gz | docker compose exec -T postgres psql -U postgres
```

### Desenvolvimento
```bash
docker compose -f docker-compose.dev.yml up -d
```

## 📦 Componentes

### Software
- Pentaho Server CE 9.4.0.0-343
- PostgreSQL 15 Alpine
- OpenJDK 21 JRE
- Tomcat 9
- PostgreSQL JDBC Driver 42.7.4

### Volumes Docker
- `pentaho_postgres_data` - Dados PostgreSQL
- `pentaho_solutions` - Soluções Pentaho
- `pentaho_data` - Dados Pentaho

### Rede
- `pentaho-net` - Bridge network (172.28.0.0/16)

## 🔒 Segurança

### Padrão (Desenvolvimento)
- PostgreSQL: `postgres/password`
- Pentaho Admin: `admin/password`
- DB Users: `password`

### Produção
⚠️ **IMPORTANTE**: Mude todas as senhas!

1. Edite `.env`:
   ```bash
   POSTGRES_PASSWORD=senha_forte_aqui
   PENTAHO_PASSWORD=senha_forte_aqui
   ```

2. Atualize `secrets/postgres_password.txt`

3. Mude senha admin via interface web

## 📊 Requisitos

### Mínimo
- CPU: 2 núcleos
- RAM: 8GB
- Disco: 10GB
- Docker: 20.10+
- Docker Compose: 2.0+

### Recomendado
- CPU: 4+ núcleos
- RAM: 16GB
- Disco: 20GB+
- SSD para melhor performance

## 🔍 Troubleshooting

### Logs
```bash
docker compose logs pentaho-server  # Logs Pentaho
docker compose logs postgres        # Logs PostgreSQL
docker stats                        # Uso de recursos
```

### Problemas Comuns
1. **Porta em uso**: Mude no `.env`
2. **Out of memory**: Aumente `PENTAHO_MAX_MEMORY`
3. **PostgreSQL não conecta**: Verifique health check
4. **Pentaho não inicia**: Aguarde 5 minutos

## 📚 Recursos

### Links Úteis
- [Pentaho Docs](https://help.hitachivantara.com/Documentation/Pentaho)
- [Pentaho Community](https://community.hitachivantara.com/)
- [Docker Docs](https://docs.docker.com/)
- [PostgreSQL Docs](https://www.postgresql.org/docs/15/)

### Referência
Baseado em: [Workshop--Installation](https://github.com/jporeilly/Workshop--Installation/tree/main/Pentaho-Containers/On-Prem/Pentaho-Server-PostgreSQL)

## 📝 Licença

- **Este projeto**: Fornecido como está
- **Pentaho CE**: Apache License 2.0
- **PostgreSQL**: PostgreSQL License

## 🤝 Contribuindo

Contribuições são bem-vindas!
- Abra issues para bugs
- Envie PRs com melhorias
- Compartilhe feedback

---

**Versão**: 1.0.0  
**Data**: 2024  
**Adaptado para**: Pentaho Server Community Edition 9.4.0.0-343  
**Status**: Production Ready ✅
