# Pentaho Server CE - Makefile
# Comandos convenientes para gerenciar o ambiente Docker

.PHONY: help build up down restart logs logs-pentaho logs-postgres shell-pentaho shell-postgres backup restore validate clean

# Cores para output
GREEN  := \033[0;32m
YELLOW := \033[1;33m
NC     := \033[0m

help: ## Mostrar esta ajuda
	@echo "$(GREEN)Pentaho Server CE - Docker Commands$(NC)"
	@echo ""
	@echo "Comandos disponíveis:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'

build: ## Construir imagens Docker
	@echo "$(GREEN)Construindo imagens Docker...$(NC)"
	docker compose build --no-cache pentaho-server

up: ## Iniciar todos os serviços
	@echo "$(GREEN)Iniciando serviços...$(NC)"
	docker compose up -d
	@echo "$(GREEN)Aguarde 2-5 minutos para inicialização completa$(NC)"
	@echo "Acesse: http://localhost:8080/pentaho"

down: ## Parar todos os serviços
	@echo "$(YELLOW)Parando serviços...$(NC)"
	docker compose down

restart: ## Reiniciar todos os serviços
	@echo "$(YELLOW)Reiniciando serviços...$(NC)"
	docker compose restart

restart-pentaho: ## Reiniciar apenas Pentaho Server
	@echo "$(YELLOW)Reiniciando Pentaho Server...$(NC)"
	docker compose restart pentaho-server

logs: ## Ver logs de todos os serviços
	docker compose logs -f

logs-pentaho: ## Ver logs do Pentaho Server
	docker compose logs -f pentaho-server

logs-postgres: ## Ver logs do PostgreSQL
	docker compose logs -f postgres

ps: ## Ver status dos containers
	docker compose ps

shell-pentaho: ## Acessar shell do Pentaho Server
	docker compose exec pentaho-server bash

shell-postgres: ## Acessar shell do PostgreSQL
	docker compose exec postgres bash

psql: ## Acessar PostgreSQL CLI
	docker compose exec postgres psql -U postgres

backup: ## Fazer backup do banco de dados
	@echo "$(GREEN)Criando backup do banco de dados...$(NC)"
	@bash scripts/backup-postgres.sh

validate: ## Validar deployment
	@echo "$(GREEN)Validando deployment...$(NC)"
	@bash scripts/validate-deployment.sh

stats: ## Mostrar estatísticas de recursos
	docker stats --no-stream

clean: ## Remover containers (mantém volumes)
	@echo "$(YELLOW)Removendo containers...$(NC)"
	docker compose down

clean-all: ## Remover tudo (containers + volumes) - CUIDADO!
	@echo "$(YELLOW)⚠️  CUIDADO: Isto irá remover TODOS os dados!$(NC)"
	@read -p "Tem certeza? (yes/no): " answer; \
	if [ "$$answer" = "yes" ]; then \
		docker compose down -v; \
		echo "$(GREEN)Removido com sucesso$(NC)"; \
	else \
		echo "Cancelado"; \
	fi

install: ## Instalação inicial completa
	@echo "$(GREEN)Iniciando instalação do Pentaho Server CE...$(NC)"
	@if [ ! -f ".env" ]; then \
		cp .env.template .env; \
		echo "$(GREEN)Arquivo .env criado$(NC)"; \
	fi
	@if [ ! -f "secrets/postgres_password.txt" ]; then \
		echo "password" > secrets/postgres_password.txt; \
		echo "$(GREEN)Arquivo de senha criado$(NC)"; \
	fi
	@echo "$(GREEN)Verificando pacote Pentaho...$(NC)"
	@if ! ls docker/stagedArtifacts/pentaho-server-ce-*.zip 1> /dev/null 2>&1; then \
		echo "$(YELLOW)⚠️  Coloque o pacote pentaho-server-ce-*.zip em docker/stagedArtifacts/$(NC)"; \
		exit 1; \
	fi
	@$(MAKE) build
	@$(MAKE) up
	@echo "$(GREEN)Instalação concluída!$(NC)"
	@echo "Acesse: http://localhost:8080/pentaho"
	@echo "Usuário: admin / Senha: password"
