# Software Override System

Este diretório permite customizar a configuração do Pentaho Server sem modificar a instalação base.

## Como Funciona

Os arquivos neste diretório são copiados para o Pentaho Server durante a inicialização do container, seguindo a estrutura de diretórios da instalação do Pentaho.

## Estrutura de Diretórios

### 1_drivers/
Drivers JDBC e conectores de dados.
- `tomcat/lib/` - Drivers JDBC (ex: PostgreSQL já incluído)
- `pentaho-solutions/system/kettle/` - Drivers Kettle

### 2_repository/
Configurações de banco de dados e repositório.
- `pentaho-solutions/system/hibernate/` - Configuração Hibernate
- `pentaho-solutions/system/jackrabbit/` - Configuração JackRabbit
- `pentaho-solutions/system/quartz/` - Configuração Quartz
- `tomcat/webapps/pentaho/META-INF/` - Context.xml

### 3_security/
Autenticação e autorização.
- `pentaho-solutions/system/` - Configurações de segurança

### 4_others/
Configurações diversas do Tomcat e aplicação.
- `pentaho-solutions/system/` - Configurações do sistema
- `tomcat/bin/` - Scripts do Tomcat

### 99_exchange/
Diretório para troca de arquivos (não processado automaticamente).

## Ordem de Processamento

Os diretórios são processados em ordem alfabética:
1. 1_drivers - Primeiro (drivers disponíveis antes das conexões)
2. 2_repository - Segundo (configuração de banco de dados)
3. 3_security - Terceiro (autenticação)
4. 4_others - Quarto (configurações da aplicação)

## Como Adicionar Customizações

1. Crie a estrutura de diretórios correspondente ao caminho no Pentaho
2. Coloque seus arquivos de configuração
3. Reconstrua o container: `docker compose build pentaho-server`
4. Reinicie: `docker compose up -d pentaho-server`

## Ignorar Diretórios

Para ignorar um diretório durante o processamento, crie um arquivo `.ignore` dentro dele.

## Exemplo

Para customizar o `pentaho.xml`:
```
softwareOverride/4_others/pentaho-solutions/system/pentaho.xml
```

Este arquivo será copiado para:
```
/opt/pentaho/pentaho-server/pentaho-solutions/system/pentaho.xml
```
