# Instalação no Windows

Este guia específico ajuda usuários Windows a configurar o Pentaho Server CE com Docker.

## Pré-requisitos Windows

### 1. Docker Desktop para Windows

Download: https://www.docker.com/products/docker-desktop/

**Requisitos**:
- Windows 10/11 Pro, Enterprise, ou Education (64-bit)
- WSL 2 habilitado
- Virtualização habilitada na BIOS
- 8GB RAM mínimo

### 2. Instalação Docker Desktop

1. Baixe o instalador do Docker Desktop
2. Execute o instalador
3. Marque "Use WSL 2 instead of Hyper-V"
4. Reinicie o computador quando solicitado
5. Abra o Docker Desktop e aguarde inicialização

### 3. Verificar Instalação

Abra PowerShell ou CMD e execute:

```powershell
docker --version
docker compose version
```

Você deve ver as versões instaladas.

## Baixar Pentaho Server

1. Acesse: https://github.com/ambientelivre/legacy-pentaho-ce/releases
2. Baixe: `pentaho-server-ce-9.4.0.0-343.zip`
3. Coloque em: `docker\stagedArtifacts\`

## Configuração Inicial

### 1. Criar Arquivo .env

No PowerShell, dentro da pasta do projeto:

```powershell
# Copiar template
Copy-Item .env.template .env

# (Opcional) Editar com Notepad
notepad .env
```

### 2. Verificar Estrutura

```powershell
# Verificar se o arquivo Pentaho está no lugar certo
Get-ChildItem docker\stagedArtifacts\*.zip

# Deve mostrar: pentaho-server-ce-9.4.0.0-343.zip
```

## Deployment

### Opção 1: PowerShell (Recomendado)

```powershell
# Navegar até o diretório do projeto
cd C:\Users\seu-usuario\OneDrive\source\pentaho_server

# Construir a imagem
docker compose build --no-cache pentaho-server

# Iniciar os serviços
docker compose up -d

# Acompanhar logs
docker compose logs -f pentaho-server
```

### Opção 2: Docker Desktop Interface

1. Abra o Docker Desktop
2. Vá para a aba "Images"
3. Clique em "Build" e selecione o `docker-compose.yml`
4. Após o build, vá para "Containers"
5. Clique em "Start" no container pentaho-server

## Verificar Status

```powershell
# Ver containers rodando
docker compose ps

# Ver logs do Pentaho
docker compose logs pentaho-server

# Ver logs do PostgreSQL
docker compose logs postgres
```

## Acessar os Serviços

### Pentaho Server
- URL: http://localhost:8080/pentaho
- Usuário: `admin`
- Senha: `password`

### PostgreSQL (via pgAdmin ou cliente SQL)
- Host: `localhost`
- Port: `5432`
- Usuário: `postgres`
- Senha: `password`

## Comandos Úteis PowerShell

```powershell
# Parar todos os serviços
docker compose stop

# Iniciar serviços novamente
docker compose start

# Reiniciar apenas o Pentaho
docker compose restart pentaho-server

# Ver uso de recursos
docker stats

# Ver volumes criados
docker volume ls

# Backup do banco de dados
docker compose exec -T postgres pg_dumpall -U postgres | gzip > backups\backup-$(Get-Date -Format 'yyyyMMdd-HHmmss').sql.gz

# Parar e remover tudo (mantém volumes)
docker compose down

# Remover tudo incluindo dados (CUIDADO!)
docker compose down -v
```

## Problemas Comuns Windows

### Porta 8080 em Uso

```powershell
# Verificar o que está usando a porta
netstat -ano | findstr :8080

# Encontrar o processo
tasklist | findstr "PID_AQUI"

# Matar o processo (ou mudar a porta no .env)
taskkill /PID PID_AQUI /F
```

### WSL 2 não está habilitado

1. Abra PowerShell como Administrador
2. Execute:
```powershell
wsl --install
wsl --set-default-version 2
```
3. Reinicie o computador

### Virtualização não habilitada

1. Reinicie o computador
2. Entre na BIOS (geralmente F2, F10, DEL durante boot)
3. Procure por "Virtualization Technology" ou "VT-x"
4. Habilite e salve

### Docker Desktop não inicia

1. Abra o Gerenciador de Tarefas
2. Finalize todos os processos do Docker
3. Abra Docker Desktop novamente
4. Se persistir, desinstale e reinstale o Docker Desktop

### Erro de Memória

```powershell
# No .env, reduza a memória:
PENTAHO_MIN_MEMORY=1024m
PENTAHO_MAX_MEMORY=2048m
PENTAHO_MAX_MEMORY_LIMIT=4G

# Reinicie
docker compose down
docker compose up -d
```

### Permissões de Arquivo

Se tiver problemas com permissões:

1. Certifique-se de que o Docker Desktop tem acesso à pasta
2. Em Docker Desktop > Settings > Resources > File Sharing
3. Adicione o drive/pasta do projeto
4. Clique em "Apply & Restart"

## Desenvolvimento no Windows

### Visual Studio Code

Recomendado para editar arquivos:

1. Instale VS Code: https://code.visualstudio.com/
2. Instale extensões:
   - Docker
   - Remote - Containers
   - YAML

### Acessar Shell do Container

```powershell
# Pentaho Server
docker compose exec pentaho-server bash

# PostgreSQL
docker compose exec postgres bash
```

### Editar Configurações

Use VS Code ou Notepad++ para editar:
- `.env` - Configurações gerais
- `docker-compose.yml` - Definição dos serviços
- Arquivos em `softwareOverride/` - Customizações do Pentaho

## Backup e Restore Windows

### Backup

```powershell
# Criar diretório de backups se não existir
New-Item -ItemType Directory -Force -Path backups

# Backup completo
docker compose exec -T postgres pg_dumpall -U postgres | gzip > "backups\pentaho-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss').sql.gz"
```

### Restore

```powershell
# Parar Pentaho
docker compose stop pentaho-server

# Restaurar
Get-Content "backups\pentaho-backup-YYYYMMDD-HHMMSS.sql.gz" | gunzip | docker compose exec -T postgres psql -U postgres

# Reiniciar
docker compose up -d
```

## Firewall Windows

Se necessário, adicione regras de firewall:

```powershell
# Permitir porta 8080 (como Administrador)
New-NetFirewallRule -DisplayName "Pentaho Server" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow

# Permitir porta 5432 (se acessar PostgreSQL externamente)
New-NetFirewallRule -DisplayName "PostgreSQL" -Direction Inbound -LocalPort 5432 -Protocol TCP -Action Allow
```

## Performance no Windows

Para melhor performance:

1. **Alocar mais recursos ao Docker Desktop**:
   - Docker Desktop > Settings > Resources
   - Aumente CPUs para 4+
   - Aumente Memory para 8GB+
   - Aumente Disk image size para 60GB+

2. **WSL 2 otimizado**:
   Crie arquivo `%USERPROFILE%\.wslconfig`:
   ```
   [wsl2]
   memory=8GB
   processors=4
   swap=2GB
   ```

3. **Desabilitar Antivírus para pastas Docker** (temporariamente para testes)

## Próximos Passos

1. Leia o [QUICKSTART.md](QUICKSTART.md)
2. Consulte o [README.md](README.md) para detalhes completos
3. Explore as customizações em `softwareOverride/`

## Suporte

- Docker Desktop Docs: https://docs.docker.com/desktop/windows/
- WSL 2 Docs: https://docs.microsoft.com/en-us/windows/wsl/
- Pentaho Community: https://community.hitachivantara.com/

---

**Versão**: 1.0.0  
**Última Atualização**: 2024
