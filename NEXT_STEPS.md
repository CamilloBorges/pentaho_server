# 🚀 Próximos Passos - Correção do Erro 404

## 📋 Diagnóstico Atual

Seu Pentaho Server apresentou o seguinte problema:

❌ **Status**: Container UNHEALTHY  
❌ **HTTP**: 404 Not Found  
⚠️ **Erro**: ClassLoader exception com commons-pool  

**Causa Raiz**: Pentaho 9.4 usa `commons-pool 1.x` que é incompatível com Java 21.

---

## ✅ Solução Aplicada

Os seguintes arquivos foram corrigidos:

1. ✅ **Dockerfile** - Adicionado download automático de commons-pool2 2.12.0
2. ✅ **Dockerfile** - Health check melhorado (300s start-period, 5 retries)
3. ✅ **TROUBLESHOOTING.md** - Guia completo de problemas criado
4. ✅ **NETWORK_ACCESS.md** - Guia de acesso remoto criado
5. ✅ **scripts/full-diagnose.sh** - Script de diagnóstico completo

---

## 🔧 Como Aplicar a Correção

Execute **NO SERVIDOR** (root@srv484251):

### Passo 1: Atualizar os arquivos

```bash
# Voltar para o diretório do projeto
cd ~/pentaho_server

# Se estiver usando Git, puxe as alterações
git pull

# OU se não estiver usando Git, copie os arquivos atualizados manualmente
```

### Passo 2: Reconstruir a imagem

```bash
# Parar containers em execução
docker compose down

# Reconstruir sem cache (IMPORTANTE!)
docker compose build --no-cache pentaho-server

# Isso pode levar 5-10 minutos
```

### Passo 3: Iniciar novamente

```bash
# Iniciar os containers
docker compose up -d

# Acompanhar os logs
docker logs -f pentaho-server
```

### Passo 4: Aguardar inicialização

⏳ **Aguarde 5-10 minutos** para a primeira inicialização completa.

Procure por esta mensagem nos logs:
```
INFO: Server startup in [xxxxx] milliseconds
```

### Passo 5: Verificar

```bash
# Rodar script de diagnóstico
chmod +x scripts/full-diagnose.sh
./scripts/full-diagnose.sh

# Testar acesso
curl -I http://localhost:8080/pentaho/

# Deve retornar: HTTP/1.1 200 OK ou 302 Found
```

---

## 🧪 Verificação Rápida

Execute este comando para verificar se a correção foi aplicada:

```bash
# Verificar se commons-pool2 está instalado
docker exec pentaho-server ls -la /opt/pentaho/pentaho-server/tomcat/lib/ | grep commons-pool

# Deve mostrar:
# commons-pool2-2.12.0.jar ✅

# Se ainda mostrar commons-pool-1.*.jar, reconstrua a imagem
```

---

## 🌐 Acesso Externo

Após o Pentaho iniciar com sucesso:

### Acesso Local (no servidor)
```bash
http://localhost:8080/pentaho
```

### Acesso Remoto (de outras máquinas)
```bash
http://191.101.70.239:8080/pentaho
```

**Credenciais Padrão**:
- Usuário: `admin`
- Senha: `password`

⚠️ **IMPORTANTE**: Altere as senhas padrão em produção!

---

## 📊 Monitoramento

Enquanto aguarda a inicialização:

```bash
# Terminal 1: Logs em tempo real
docker logs -f pentaho-server

# Terminal 2: Status dos containers
watch -n 5 'docker ps'

# Terminal 3: Uso de recursos
watch -n 5 'docker stats --no-stream'
```

---

## ❓ Se Ainda Tiver Problemas

### 1. Container continua unhealthy

```bash
# Ver últimos logs
docker logs --tail 100 pentaho-server

# Consultar troubleshooting
cat TROUBLESHOOTING.md
```

### 2. Ainda recebe 404

```bash
# Verificar se webapp foi deployed
docker exec pentaho-server ls -la /opt/pentaho/pentaho-server/tomcat/webapps/

# Deve ter diretório "pentaho"
```

### 3. Erros de ClassLoader persistem

```bash
# Verificar se a imagem foi realmente reconstruída
docker images | grep pentaho

# Última coluna deve ser recente (poucos minutos/horas)

# Se antiga, force rebuild:
docker compose down
docker rmi pentaho_server-pentaho-server
docker compose build --no-cache
docker compose up -d
```

---

## 📚 Documentação Completa

Para mais detalhes, consulte:

- 📖 [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Todos os problemas comuns
- 🌐 [NETWORK_ACCESS.md](NETWORK_ACCESS.md) - Acesso remoto e firewall
- ⚙️ [SYSTEM_REQUIREMENTS.md](SYSTEM_REQUIREMENTS.md) - Otimização de recursos
- 📋 [README.md](README.md) - Documentação principal

---

## 🆘 Suporte

Se precisar de mais ajuda:

1. Execute o diagnóstico completo:
   ```bash
   ./scripts/full-diagnose.sh > diagnostico-$(date +%Y%m%d-%H%M%S).txt
   ```

2. Compartilhe o arquivo `diagnostico-*.txt` gerado

3. Inclua também:
   - Versão do Docker: `docker --version`
   - Sistema: `uname -a`
   - Conteúdo do .env (sem senhas!)

---

## ✨ Resultado Esperado

Após seguir estes passos, você deverá ver:

```bash
$ docker ps
CONTAINER       STATUS
pentaho-server  Up X minutes (healthy)   ✅
pentaho-postgres Up X minutes (healthy)  ✅

$ curl -I http://localhost:8080/pentaho/
HTTP/1.1 302 Found  ✅

$ curl http://191.101.70.239:8080/pentaho/
<html>...Pentaho Login Page...</html>  ✅
```

🎉 **Pentaho Server rodando com sucesso!**

---

**Versão**: 1.2.0  
**Data**: Junho 2026  
**Status**: Problema identificado e corrigido
