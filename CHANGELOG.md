# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [1.0.1] - 2024-06-01

### Alterado
- **IMPORTANTE**: Versão do Pentaho alterada de 10.2.0.0-222 para 9.4.0.0-343
- Motivo: Pentaho 10+ requer licença comercial; 9.4.0.0-343 é a última versão CE verdadeiramente open-source
- Download agora via GitHub: https://github.com/ambientelivre/legacy-pentaho-ce/releases
- Todos os arquivos de configuração e documentação atualizados para a nova versão

### Notas
A versão 9.4.0.0-343 do Pentaho Server CE é a última versão totalmente livre antes da mudança de licenciamento. Versões 10+ são comerciais e requerem licença mesmo para a edição CE.

## [1.0.0] - 2024-06-01

### Adicionado

#### Infraestrutura
- Docker Compose configuração de produção (`docker-compose.yml`)
- Docker Compose configuração de desenvolvimento (`docker-compose.dev.yml`)
- Dockerfile multi-stage para Pentaho Server CE
- Script de entrypoint com processamento de configurações
- Rede Docker customizada (pentaho-net)
- Volumes persistentes para dados PostgreSQL e Pentaho

#### PostgreSQL
- Scripts de inicialização automática do banco de dados
  - JackRabbit (JCR) database
  - Quartz Scheduler database
  - Hibernate Repository database
- Configuração customizada de performance
- Backup e restore automatizados

#### Pentaho Server CE
- Imagem baseada em Debian Trixie Slim
- OpenJDK 21 JRE
- PostgreSQL JDBC driver 42.7.4 incluído
- Sistema de customização (softwareOverride)
- Configuração automática de banco de dados

#### Scripts Utilitários
- `deploy.sh` - Deploy automatizado com pre-flight checks
- `backup-postgres.sh` - Backup do banco de dados
- `restore-postgres.sh` - Restore do banco de dados
- `validate-deployment.sh` - Validação do deployment

#### Segurança
- Containers read-only com tmpfs mounts
- Docker secrets para senhas
- Limites de recursos (CPU/memória)
- Rotação de logs automática
- Health checks para todos os serviços

#### Documentação
- README.md completo em português
- QUICKSTART.md - Guia de início rápido
- WINDOWS_SETUP.md - Guia específico para Windows
- DOWNLOAD.md - Instruções de download
- PROJECT_INFO.md - Informações do projeto
- PROJECT_SUMMARY.md - Sumário do projeto
- Makefile com comandos úteis
- READMEs em cada diretório importante

#### Desenvolvimento
- Docker Compose para desenvolvimento com hot reload
- PgAdmin incluído no modo desenvolvimento
- Debug port habilitado (8000)
- Logs externos montados

### Características

- ✅ Completamente auto-contido e portátil
- ✅ Inicialização automática do banco de dados
- ✅ Health checks e ordenação de inicialização
- ✅ Volumes de dados persistentes
- ✅ Backup e restore fáceis
- ✅ Templates de configuração prontos
- ✅ Driver PostgreSQL JDBC incluído
- ✅ Containers read-only para segurança
- ✅ Limites de recursos para estabilidade
- ✅ Rotação de logs

### Baseado Em

Adaptado de: [jporeilly/Workshop--Installation](https://github.com/jporeilly/Workshop--Installation/tree/main/Pentaho-Containers/On-Prem/Pentaho-Server-PostgreSQL)

Diferenças da versão EE:
- Removido HashiCorp Vault (não necessário para CE)
- Simplificado gerenciamento de secrets
- Configuração otimizada para CE
- Documentação em português
- Suporte específico para Windows

### Tecnologias

- Pentaho Server CE 9.4.0.0-343
- PostgreSQL 15 Alpine
- Docker Engine 20.10+
- Docker Compose 2.0+
- Debian Trixie Slim
- OpenJDK 21 JRE

### Estrutura de Diretórios

```
pentaho_server/
├── .env.template
├── .gitignore
├── CHANGELOG.md
├── docker-compose.yml
├── docker-compose.dev.yml
├── DOWNLOAD.md
├── Makefile
├── PROJECT_INFO.md
├── PROJECT_SUMMARY.md
├── QUICKSTART.md
├── README.md
├── WINDOWS_SETUP.md
├── backups/
├── config/
│   ├── .kettle/
│   └── .pentaho/
├── db_init_postgres/
│   ├── 1_create_jcr_postgres.sql
│   ├── 2_create_quartz_postgres.sql
│   └── 3_create_repository_postgres.sql
├── docker/
│   ├── Dockerfile
│   ├── entrypoint/
│   │   └── docker-entrypoint.sh
│   └── stagedArtifacts/
├── logs/
├── postgres-config/
│   └── custom.conf
├── scripts/
│   ├── backup-postgres.sh
│   ├── deploy.sh
│   ├── restore-postgres.sh
│   └── validate-deployment.sh
├── secrets/
│   └── postgres_password.txt
└── softwareOverride/
    ├── README.md
    ├── 1_drivers/
    ├── 2_repository/
    ├── 3_security/
    ├── 4_others/
    └── 99_exchange/
```

## [Unreleased]

### Planejado para versões futuras

- [ ] SSL/TLS configuration automática
- [ ] Integração com LDAP/Active Directory
- [ ] Monitoring com Prometheus/Grafana
- [ ] Backup automático agendado
- [ ] High availability configuration
- [ ] Kubernetes deployment (Helm charts)
- [ ] CI/CD pipeline examples
- [ ] Performance tuning guide
- [ ] Migration guide from EE to CE
- [ ] Multi-language documentation (English)

## Notas de Versão

### Como usar este projeto

1. Baixe o Pentaho Server CE zip
2. Configure o arquivo .env
3. Execute `docker compose up -d`
4. Acesse http://localhost:8080/pentaho

### Requisitos

- Docker Engine 20.10+
- Docker Compose 2.0+
- 8GB RAM mínimo
- 10GB espaço em disco

### Suporte

- Issues: Abra uma issue neste repositório
- Documentação: Veja README.md
- Community: https://community.hitachivantara.com/

---

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/)
