# Security Configuration

Este diretório contém configurações de segurança e autenticação.

## Arquivos de Configuração

### Spring Security
- `applicationContext-spring-security-hibernate.properties`
- Configuração de autenticação com Hibernate

### Memory Security
- `applicationContext-spring-security-memory.xml`
- Configuração de autenticação em memória

## Customização

Para customizar a autenticação ou autorização:
1. Crie os arquivos de configuração nesta estrutura
2. Reconstrua o container
3. Reinicie os serviços
