# 🚀 Pentaho Server CE - Instalação em 5 Minutos

## ✅ Checklist de Instalação

### Pré-requisitos (5 minutos)
- [ ] Docker Desktop instalado e rodando
- [ ] Docker Compose 2.0+ instalado
- [ ] 8GB RAM disponível
- [ ] 10GB espaço em disco livre
- [ ] Portas 8080, 8443, 5432 livres

### Download (2 minutos)
- [ ] Baixar Pentaho Server CE 9.4.0.0-343 do [GitHub](https://github.com/ambientelivre/legacy-pentaho-ce/releases/download/pentaho-server-ce-9.4.0.0-343/pentaho-server-ce-9.4.0.0-343.zip)
- [ ] Salvar em `docker/stagedArtifacts/pentaho-server-ce-9.4.0.0-343.zip`

### Configuração (1 minuto)
- [ ] Copiar `.env.template` para `.env`
  ```bash
  cp .env.template .env
  ```
- [ ] (Opcional) Editar `.env` para customizar portas/memória

### Deploy (2-5 minutos)
- [ ] Construir imagem Docker
  ```bash
  docker compose build --no-cache pentaho-server
  ```
- [ ] Iniciar serviços
  ```bash
  docker compose up -d
  ```
- [ ] Aguardar inicialização (2-5 minutos)
  ```bash
  docker compose logs -f pentaho-server
  ```

### Verificação (1 minuto)
- [ ] Acessar http://localhost:8080/pentaho
- [ ] Login com: `admin` / `password`
- [ ] Explorar dashboards de exemplo

---

## 📋 Comandos Essenciais

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

### Status
```bash
docker compose ps
```

---

## ⚡ Quick Commands (Linux/macOS)

Se você tem Make instalado:

```bash
make install    # Instalação completa
make up         # Iniciar
make down       # Parar
make logs       # Ver logs
make backup     # Fazer backup
make validate   # Validar deployment
```

---

## 🐛 Troubleshooting Rápido

### Problema: Porta 8080 em uso
```bash
# Windows
netstat -ano | findstr :8080

# Linux/macOS
lsof -i :8080
```
**Solução**: Mude `PENTAHO_HTTP_PORT=8081` no `.env`

### Problema: Out of Memory
**Solução**: Edite `.env`:
```bash
PENTAHO_MAX_MEMORY=2048m
```

### Problema: PostgreSQL não conecta
```bash
docker compose logs postgres
docker compose restart postgres
```

### Problema: Pentaho não responde
**Solução**: Aguarde mais tempo (até 5 minutos)
```bash
docker compose logs -f pentaho-server
# Procure por: "Server startup in [X] milliseconds"
```

---

## 📱 URLs Rápidas

| Serviço | URL | Credenciais |
|---------|-----|-------------|
| Pentaho | http://localhost:8080/pentaho | admin / password |
| PostgreSQL | localhost:5432 | postgres / password |

---

## 📚 Documentação Completa

- 📖 [README.md](README.md) - Documentação completa
- ⚡ [QUICKSTART.md](QUICKSTART.md) - Guia detalhado
- 🪟 [WINDOWS_SETUP.md](WINDOWS_SETUP.md) - Setup Windows
- 💾 [DOWNLOAD.md](DOWNLOAD.md) - Download do Pentaho

---

## 🎯 Próximos Passos

Após instalação bem-sucedida:

1. ✅ **Mudar Senha Admin** (Produção)
2. 🔍 **Explorar Exemplos**
3. 🔌 **Configurar Conexões de Dados**
4. 💾 **Configurar Backups Automáticos**
5. 🔒 **Implementar Segurança** (Produção)

---

## 🆘 Ajuda

- 📧 Issues: Abra uma issue neste repositório
- 💬 Community: https://community.hitachivantara.com/
- 📚 Docs: https://help.hitachivantara.com/Documentation/Pentaho

---

**Versão**: 1.0.0 | **Status**: ✅ Production Ready | **Licença**: Apache 2.0
