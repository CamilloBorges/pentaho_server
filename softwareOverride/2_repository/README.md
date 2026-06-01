# Repository Configuration

Este diretório contém configurações de banco de dados e repositório.

## Arquivos Importantes

### Hibernate Configuration
- `pentaho-solutions/system/hibernate/hibernate-settings.xml`
- Configuração do repositório Hibernate

### JackRabbit Configuration
- `pentaho-solutions/system/jackrabbit/repository.xml`
- Configuração do repositório de conteúdo JCR

### Quartz Scheduler Configuration
- `pentaho-solutions/system/quartz/quartz.properties`
- Configuração do agendador

### Tomcat Context
- `tomcat/webapps/pentaho/META-INF/context.xml`
- Configuração de datasources do Tomcat

## Customização

As configurações de banco de dados são aplicadas automaticamente pelo script de entrypoint.
Você pode adicionar customizações adicionais criando arquivos nesta estrutura.
