# Quick Start Guide - Pentaho Server CE

Este guia rápido irá ajudá-lo a começar com o Pentaho Server CE em menos de 10 minutos.

## 🚀 Início Rápido (5 Passos)

### 1. Pré-requisitos

Certifique-se de ter instalado:
- ✅ Docker Desktop (Windows/macOS) ou Docker Engine (Linux)
- ✅ Docker Compose 2.0+
- ✅ 8GB RAM disponível
- ✅ 10GB espaço em disco

### 2. Baixar Pentaho Server CE

1. Visite: https://github.com/ambientelivre/legacy-pentaho-ce/releases
2. Baixe: `pentaho-server-ce-9.4.0.0-343.zip`
3. Coloque o arquivo em: `docker/stagedArtifacts/`

```bash
# Estrutura deve ficar assim:
docker/stagedArtifacts/pentaho-server-ce-9.4.0.0-343.zip
```

### 3. Configurar Ambiente

```bash
# Criar arquivo de configuração
cp .env.template .env

# (Opcional) Editar configurações
# Você pode usar as configurações padrão para começar
```

### 4. Iniciar os Serviços

#### Opção A: Usando Make (Linux/macOS)
```bash
make install
```

#### Opção B: Usando Docker Compose Diretamente
```bash
# Construir a imagem
docker compose build --no-cache pentaho-server

# Iniciar os serviços
docker compose up -d

# Acompanhar os logs
docker compose logs -f pentaho-server
```

#### Opção C: Usando Script de Deploy (Linux/macOS)
```bash
chmod +x scripts/*.sh
./scripts/deploy.sh
```

### 5. Acessar o Pentaho

Aguarde 2-5 minutos para a inicialização completa. Você pode acompanhar o progresso:

```bash
docker compose logs -f pentaho-server
```

Procure por: `Server startup in [X] milliseconds`

Então acesse:
- **URL**: http://localhost:8080/pentaho
- **Usuário**: admin
- **Senha**: password

## 📊 Verificar Status

```bash
# Ver status dos containers
docker compose ps

# Validar deployment (Linux/macOS)
./scripts/validate-deployment.sh

# Verificar logs
docker compose logs pentaho-server
docker compose logs postgres
```

## 🔧 Comandos Úteis

```bash
# Parar serviços
docker compose stop

# Reiniciar serviços
docker compose restart

# Ver logs em tempo real
docker compose logs -f

# Parar e remover tudo (mantém dados)
docker compose down

# Backup do banco de dados
docker compose exec -T postgres pg_dumpall -U postgres | gzip > backup.sql.gz
```

## ❓ Problemas Comuns

### Container não inicia
```bash
# Ver logs de erro
docker compose logs pentaho-server

# Verificar se as portas estão livres
netstat -ano | findstr :8080  # Windows
lsof -i :8080                 # Linux/macOS

# Reiniciar
docker compose restart
```

### Pentaho não responde
- Aguarde mais tempo (pode levar até 5 minutos)
- Verifique os logs: `docker compose logs -f pentaho-server`
- Verifique memória disponível: `docker stats`

### Erro "Pentaho package not found"
- Certifique-se de que o arquivo ZIP está em `docker/stagedArtifacts/`
- Verifique o nome do arquivo (deve começar com `pentaho-server-ce-`)

### PostgreSQL não conecta
```bash
# Verificar se está rodando
docker compose ps postgres

# Testar conexão
docker exec pentaho-postgres pg_isready -U postgres
```

## 🎯 Próximos Passos

Após o acesso bem-sucedido:

1. **Mudar Senha Admin**
   - Vá para: Manage Users
   - Mude a senha do usuário admin

2. **Explorar Samples**
   - Navegue pelas amostras incluídas
   - Teste os dashboards de exemplo

3. **Criar Primeira Conexão de Dados**
   - Configure uma conexão com seu banco de dados
   - Crie uma transformação simples no Spoon

4. **Configurar Backup Automático**
   - Configure backups regulares (ver README.md)

5. **Produção**
   - Mude todas as senhas padrão
   - Configure SSL/TLS
   - Restrinja acesso à rede

## 📚 Documentação Completa

Para informações detalhadas, consulte:
- [README.md](README.md) - Documentação completa
- [softwareOverride/README.md](softwareOverride/README.md) - Sistema de customização

## 🆘 Suporte

- Documentação Pentaho: https://help.hitachivantara.com/Documentation/Pentaho
- Community: https://community.hitachivantara.com/
- Issues: Abra uma issue neste repositório

---

**Boa sorte com seu Pentaho Server! 🎉**
