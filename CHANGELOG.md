# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [1.3.0] - 2026-06-01

### Corrigido
- **CRÍTICO**: Downgrade Java 21 → Java 17 para compatibilidade com Pentaho 9.4
  - Pentaho 9.4 foi desenvolvido para Java 8 e tem problemas graves com Java 21
  - OSGI/Karaf não inicializa no Java 21 (BundleException)
  - JCR (JackRabbit) falha ao inicializar no Java 21
  - Java 17 LTS é compatível com Pentaho 9.4 (Java 11 não disponível no Debian Trixie)
- Erro 404 causado por falha na inicialização do PentahoSystem

### Adicionado
- **Nginx** como reverse proxy
  - Acesso via porta 80 (HTTP) e 443 (HTTPS)
  - Configuração otimizada para Pentaho
  - Health check endpoint, logs isolados
- Volume nginx_logs
- Portas NGINX_HTTP_PORT e NGINX_HTTPS_PORT no .env

### Alterado
- Dockerfile usa OpenJDK 17 ao invés de 21
- Removida correção commons-pool (não necessária no Java 17)

## [1.2.0] - 2026-06-01

### Corrigido
- **IMPORTANTE**: Problema crítico de ClassLoader com commons-pool no Java 21
  - Pentaho 9.4 usa commons-pool 1.x que é incompatível com Java 21
  - Adicionado download automático de commons-pool2 2.12.0 no Dockerfile
  - Remove versão antiga automaticamente para evitar conflitos
- Container ficando unhealthy durante inicialização
  - Aumentado start-period: 180s → 300s (5 minutos)
  - Aumentado retries: 3 → 5
  - Health check usa /pentaho/ ao invés de /pentaho/Login
- Erro 404 intermitente durante startup

### Adicionado
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Guia completo de resolução de problemas
- Script de diagnóstico completo (full-diagnose.sh)
- Documentação detalhada do problema commons-pool
- Procedimentos de reset e recuperação

### Melhorado
- Health check mais robusto e tolerante
- Documentação de troubleshooting expandida
- Scripts de diagnóstico mais completos
## [1.2.0] - 2026-06-01

### Corrigido
- **IMPORTANTE**: Problema crítico de ClassLoader com commons-pool no Java 21
  - Pentaho 9.4 usa commons-pool 1.x que é incompatível com Java 21
  - Adicionado download automático de commons-pool2 2.12.0 no Dockerfile
  - Remove versão antiga automaticamente para evitar conflitos
- Container ficando unhealthy durante inicialização
  - Aumentado start-period: 180s → 300s (5 minutos)
  - Aumentado retries: 3 → 5
  - Health check usa /pentaho/ ao invés de /pentaho/Login
- Erro 404 intermitente durante startup

### Adicionado
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Guia completo de resolução de problemas
- Script de diagnóstico completo (full-diagnose.sh)
- Documentação detalhada do problema commons-pool
- Procedimentos de reset e recuperação

### Melhorado
- Health check mais robusto e tolerante
- Documentação de troubleshooting expandida
- Scripts de diagnóstico mais completos

## [1.1.0] - 2024-06-01

### Alterado
- **Limites de CPU ajustados** para compatibilidade com sistemas de 2 núcleos
  - Pentaho Server: 4 CPUs → 2 CPUs (limite)
  - PostgreSQL: 2 CPUs → 1 CPU (limite)
- **Requisitos de memória reduzidos** para melhor compatibilidade
  - JVM mínima: 2048m → 1024m
  - JVM máxima: 4096m → 2048m
  - Limite container: 6G → 4G
- Removido atributo `version` obsoleto dos arquivos docker-compose

### Adicionado
- [SYSTEM_REQUIREMENTS.md](SYSTEM_REQUIREMENTS.md) - Guia completo de requisitos e otimização
- [NETWORK_ACCESS.md](NETWORK_ACCESS.md) - Configuração de acesso remoto e troubleshooting de rede
- Configurações otimizadas para diferentes cenários (dev/teste/produção)
- Guia de diagnóstico de problemas de recursos
- Dicas de performance e tuning
- Script de diagnóstico completo de rede

### Corrigido
- Erro "range of CPUs is from 0.01 to 2.00" em sistemas com 2 CPUs
- Warning sobre atributo `version` obsoleto no Docker Compose

## [1.0.1] - 2024-06-01

### Alterado
- **IMPORTANTE**: Versão do Pentaho alterada de 10.2.0.0-222 para 9.4.0.0-343
- Motivo: Pentaho 10+ requer licença comercial; 9.4.0.0-343 é a última versão CE verdadeiramente open-source
- Download agora via GitHub: https://github.com/ambientelivre/legacy-pentaho-ce/releases
- Todos os arquivos de configuração e documentação atualizados para a nova versão

### Adicionado
- [VERSIONING.md](VERSIONING.md) - Explicação completa sobre versionamento e licenciamento

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
