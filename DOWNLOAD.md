# IMPORTANTE: Leia antes de usar!

## 📦 Download do Pentaho Server

Este repositório **NÃO** inclui o pacote binário do Pentaho Server devido ao tamanho do arquivo e licenciamento.

### Você precisa baixar:

**Pentaho Server Community Edition 9.4.0.0-343**

### Onde baixar:

🔗 **GitHub**: https://github.com/ambientelivre/legacy-pentaho-ce/releases/download/pentaho-server-ce-9.4.0.0-343/pentaho-server-ce-9.4.0.0-343.zip

### Como instalar:

1. Baixe o arquivo `pentaho-server-ce-9.4.0.0-343.zip`
2. Coloque-o em: `docker/stagedArtifacts/`
3. O caminho completo deve ser:
   ```
   docker/stagedArtifacts/pentaho-server-ce-9.4.0.0-343.zip
   ```

### Estrutura esperada:

```
pentaho_server/
└── docker/
    └── stagedArtifacts/
        └── pentaho-server-ce-9.4.0.0-343.zip  ← Coloque aqui!
```

### Versões compatíveis:

Este projeto foi testado com:
- ✅ Pentaho Server CE 9.4.0.0-343
- ✅ Pentaho Server CE 9.3.0.0
- ✅ Pentaho Server CE 9.2.0.0

Para usar uma versão diferente:
1. Baixe a versão desejada
2. Coloque em `docker/stagedArtifacts/`
3. Atualize `PENTAHO_VERSION` no arquivo `.env`
4. Reconstrua: `docker compose build --no-cache pentaho-server`

---

## ⚠️ Avisos Importantes

### Senhas Padrão

Este projeto usa senhas padrão para facilitar o desenvolvimento:
- PostgreSQL: `password`
- Admin Pentaho: `password`

**🔒 PARA PRODUÇÃO**: Mude TODAS as senhas antes de usar em ambiente produtivo!

### Requisitos do Sistema

Mínimos:
- 8GB RAM
- 10GB espaço em disco
- Docker Desktop ou Docker Engine + Docker Compose

Recomendados:
- 16GB RAM
- 20GB espaço em disco
- CPU com 4+ núcleos

### Portas Usadas

Certifique-se de que estas portas estão livres:
- `8080` - Pentaho Server HTTP
- `8443` - Pentaho Server HTTPS
- `5432` - PostgreSQL

---

## 🚀 Começando

Após baixar o Pentaho Server:

1. Leia o [QUICKSTART.md](QUICKSTART.md) para início rápido
2. Consulte o [README.md](README.md) para documentação completa

---

## 📝 Licença

- **Este projeto**: Fornecido como está, sem garantias
- **Pentaho Server CE**: Apache License 2.0
- **PostgreSQL**: PostgreSQL License

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se livre para:
- Abrir issues
- Enviar pull requests
- Sugerir melhorias
- Reportar bugs

---

**Última atualização**: 2024
