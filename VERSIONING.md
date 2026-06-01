# Informações sobre Versionamento do Pentaho

## ⚠️ Importante: Mudança de Licenciamento

### Por que usamos a versão 9.4.0.0-343?

A partir da **versão 10.0**, o Pentaho Server passou por mudanças significativas no modelo de licenciamento:

- **Versão 9.x e anteriores**: Totalmente open-source (Apache License 2.0)
- **Versão 10.x em diante**: Requer licença comercial mesmo para "Community Edition"

### Versão Recomendada: 9.4.0.0-343

Esta é a **última versão verdadeiramente open-source** do Pentaho Server CE:

✅ **Vantagens:**
- 100% gratuita e open-source
- Sem restrições de licenciamento
- Totalmente funcional para uso corporativo
- Estável e testada em produção
- Comunidade ativa de suporte

📦 **Download:**
- GitHub: https://github.com/ambientelivre/legacy-pentaho-ce/releases
- Versão: pentaho-server-ce-9.4.0.0-343.zip

## Comparação de Versões

| Versão | Licença | Status | Uso Comercial | Recomendada |
|--------|---------|--------|---------------|-------------|
| 9.4.0.0-343 | Apache 2.0 | ✅ Open Source | ✅ Livre | ✅ Sim |
| 9.3.x | Apache 2.0 | ✅ Open Source | ✅ Livre | ⚠️ Usar 9.4 |
| 10.x | Proprietária | ❌ Comercial | ❌ Licença necessária | ❌ Não |
| 10.1+ | Proprietária | ❌ Comercial | ❌ Licença necessária | ❌ Não |

## Histórico de Mudanças no Pentaho

### Versão 9.x (2019-2021)
- Última série verdadeiramente open-source
- Apache License 2.0
- Suporte comunitário ativo
- **9.4.0.0-343**: Última versão da série 9.x

### Versão 10.x+ (2021+)
- Mudança para modelo comercial
- Licenciamento obrigatório
- Foco em clientes enterprise
- Community Edition limitada

## Recursos da Versão 9.4.0.0-343

### Componentes Incluídos:
- ✅ Pentaho Server (BA Platform)
- ✅ Pentaho Data Integration (Kettle/Spoon)
- ✅ Pentaho Analyzer
- ✅ Pentaho Report Designer
- ✅ Pentaho Dashboard Designer
- ✅ Pentaho Metadata Editor
- ✅ Pentaho Schema Workbench

### Conectividade:
- ✅ PostgreSQL, MySQL, Oracle, SQL Server
- ✅ MongoDB, Cassandra, HBase
- ✅ Apache Hadoop, Spark
- ✅ REST/SOAP APIs
- ✅ CSV, Excel, XML, JSON

### Funcionalidades:
- ✅ ETL/ELT completo
- ✅ Reporting avançado
- ✅ Dashboards interativos
- ✅ Análise OLAP
- ✅ Data Mining
- ✅ Agendamento de jobs

## Migrando para Versão 9.4

Se você está vindo de uma versão diferente:

### De versão 8.x ou anterior:
1. Faça backup completo dos dados
2. Exporte todas as soluções/relatórios
3. Instale a versão 9.4.0.0-343
4. Importe as soluções
5. Teste todas as funcionalidades

### De versão 10.x:
1. **Atenção**: Pode haver incompatibilidades
2. Exporte todos os artefatos
3. Revise mudanças de API
4. Teste extensivamente antes de produção

## Suporte e Comunidade

### Recursos Oficiais:
- Documentação: https://help.hitachivantara.com/Documentation/Pentaho/9.4
- Wiki: https://wiki.pentaho.com/
- Forums: https://community.hitachivantara.com/

### Comunidade Open Source:
- GitHub: https://github.com/pentaho/pentaho-platform
- Stack Overflow: Tag `pentaho`
- Reddit: r/pentaho

### Repositórios Alternativos:
- Legacy CE Builds: https://github.com/ambientelivre/legacy-pentaho-ce
- Community Forks: Diversos forks mantidos pela comunidade

## Plano de Suporte

### Versão 9.4.0.0-343:
- ✅ Suporte comunitário ativo
- ✅ Correções de bugs via comunidade
- ✅ Patches de segurança disponíveis
- ⚠️ Sem suporte oficial Hitachi Vantara

### Alternativas Comerciais:
Se precisar de suporte oficial, considere:
- Pentaho Enterprise Edition 10.x+
- Hitachi Vantara Support Contracts
- Consultoria especializada

## Roadmap

### Versão 9.4.0.0-343:
- **Status**: Manutenção comunitária
- **Foco**: Estabilidade e correções
- **Updates**: Através da comunidade

### Futuro:
- Comunidade pode criar forks com melhorias
- Integrações modernas sendo desenvolvidas
- Containers e cloud-native deployments

## Decisão: Por que 9.4.0.0-343?

Nossa escolha pela versão 9.4.0.0-343 se baseia em:

1. **Licenciamento Livre**: 100% open-source
2. **Maturidade**: Versão estável e testada
3. **Recursos Completos**: Todas as funcionalidades CE
4. **Sem Restrições**: Uso comercial permitido
5. **Comunidade**: Suporte ativo
6. **Docker**: Excelente compatibilidade

## Referências

- [Pentaho Licensing Changes](https://www.hitachivantara.com/en-us/products/pentaho-plus-platform.html)
- [Legacy CE Repository](https://github.com/ambientelivre/legacy-pentaho-ce)
- [Pentaho Wiki - Version History](https://wiki.pentaho.com/)

---

**Última atualização**: Junho 2024  
**Versão do Documento**: 1.0  
**Mantido por**: Comunidade Pentaho CE
