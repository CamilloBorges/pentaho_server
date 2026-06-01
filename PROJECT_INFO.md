# Configuração do Projeto

Este arquivo é criado automaticamente e mantém informações sobre a configuração do projeto.

## Informações do Projeto

- **Nome**: Pentaho Server CE Docker
- **Versão**: 1.0.0
- **Data de Criação**: 2024
- **Tipo**: Docker Compose Deployment

## Componentes

### Serviços Docker
- Pentaho Server CE 9.4.0.0-343
- PostgreSQL 15 Alpine

### Bancos de Dados
- jackrabbit (JackRabbit JCR)
- quartz (Quartz Scheduler)
- hibernate (Hibernate Repository)

### Volumes
- pentaho_postgres_data
- pentaho_solutions
- pentaho_data

### Redes
- pentaho-net (172.28.0.0/16)

## Requisitos

### Sistema Operacional
- Windows 10/11
- Ubuntu 20.04+
- macOS

### Software
- Docker Engine 20.10+
- Docker Compose 2.0+

### Hardware
- CPU: 4+ núcleos
- RAM: 8GB mínimo, 16GB recomendado
- Disco: 10GB+ disponível

## Portas Expostas

- 8080: Pentaho Server HTTP
- 8443: Pentaho Server HTTPS
- 5432: PostgreSQL

## Estrutura de Diretórios

```
pentaho_server/
├── .env                        # Configuração de ambiente
├── .env.template               # Template de configuração
├── .gitignore                  # Arquivos ignorados pelo Git
├── docker-compose.yml          # Definição dos serviços
├── Makefile                    # Comandos úteis
├── README.md                   # Documentação principal
├── QUICKSTART.md               # Guia rápido
├── DOWNLOAD.md                 # Instruções de download
├── backups/                    # Backups do banco de dados
├── config/                     # Configurações de usuário
│   ├── .kettle/
│   └── .pentaho/
├── db_init_postgres/           # Scripts de inicialização
│   ├── 1_create_jcr_postgres.sql
│   ├── 2_create_quartz_postgres.sql
│   └── 3_create_repository_postgres.sql
├── docker/                     # Contexto Docker
│   ├── Dockerfile
│   ├── entrypoint/
│   │   └── docker-entrypoint.sh
│   └── stagedArtifacts/
│       └── (coloque aqui pentaho-server-ce-*.zip)
├── postgres-config/            # Configuração PostgreSQL
│   └── custom.conf
├── scripts/                    # Scripts utilitários
│   ├── backup-postgres.sh
│   ├── deploy.sh
│   ├── restore-postgres.sh
│   └── validate-deployment.sh
├── secrets/                    # Secrets Docker
│   └── postgres_password.txt
└── softwareOverride/           # Customizações Pentaho
    ├── README.md
    ├── 1_drivers/
    ├── 2_repository/
    ├── 3_security/
    ├── 4_others/
    └── 99_exchange/
```

## Credenciais Padrão

⚠️ **ATENÇÃO**: Mude estas senhas em produção!

### PostgreSQL
- Usuário: postgres
- Senha: password
- Host: localhost
- Porta: 5432

### Pentaho Server
- Usuário: admin
- Senha: password
- URL: http://localhost:8080/pentaho

### Usuários de Banco de Dados
- jcr_user / password (jackrabbit)
- pentaho_user / password (quartz)
- hibuser / password (hibernate)

## URLs de Acesso

- Pentaho Server: http://localhost:8080/pentaho
- Pentaho Admin: http://localhost:8080/pentaho/Login

## Comandos Rápidos

### Iniciar
```bash
docker compose up -d
```

### Parar
```bash
docker compose stop
```

### Ver Logs
```bash
docker compose logs -f pentaho-server
```

### Backup
```bash
docker compose exec -T postgres pg_dumpall -U postgres | gzip > backup.sql.gz
```

### Validar
```bash
./scripts/validate-deployment.sh  # Linux/macOS
```

## Suporte

- Documentação Pentaho: https://help.hitachivantara.com/Documentation/Pentaho
- Community: https://community.hitachivantara.com/
- PostgreSQL Docs: https://www.postgresql.org/docs/15/
- Docker Docs: https://docs.docker.com/

## Notas

- Este é um ambiente de desenvolvimento/teste
- Para produção, implemente as recomendações de segurança do README.md
- Backups regulares são essenciais
- Monitore o uso de recursos com `docker stats`
