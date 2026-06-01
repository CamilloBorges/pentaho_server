# Logs do Pentaho Server

Este diretório contém os logs do Pentaho Server quando executado em modo desenvolvimento.

No modo de produção (docker-compose.yml), os logs ficam dentro do container e podem ser acessados via:

```bash
docker compose logs pentaho-server
docker compose logs -f pentaho-server  # Follow mode
```

No modo de desenvolvimento (docker-compose.dev.yml), os logs são montados neste diretório para fácil acesso.

## Arquivos de Log Principais

- `catalina.out` - Log principal do Tomcat/Pentaho
- `catalina.YYYY-MM-DD.log` - Logs diários do Tomcat
- `localhost.YYYY-MM-DD.log` - Logs do aplicativo
- `pentaho.log` - Logs específicos do Pentaho

## Visualizar Logs

```bash
# Últimas linhas
tail -f logs/catalina.out

# Filtrar erros
grep -i error logs/*.log

# Filtrar warnings
grep -i warn logs/*.log
```
