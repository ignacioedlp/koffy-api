# Makefile para comandos comunes de Koffy API

.PHONY: help build up down restart logs console bash migrate seed test clean

# Comando por defecto
help:
	@echo "🚀 Koffy API - Comandos Disponibles:"
	@echo ""
	@echo "  make build      - Construir imágenes de Docker"
	@echo "  make up         - Iniciar todos los servicios"
	@echo "  make down       - Detener todos los servicios"
	@echo "  make restart    - Reiniciar todos los servicios"
	@echo "  make logs       - Ver logs en tiempo real"
	@echo "  make console    - Abrir Rails console"
	@echo "  make bash       - Abrir bash en el contenedor"
	@echo "  make migrate    - Ejecutar migraciones"
	@echo "  make seed       - Cargar datos iniciales"
	@echo "  make test       - Ejecutar tests"
	@echo "  make clean      - Limpiar todo (incluye volúmenes)"
	@echo ""

# Construir imágenes
build:
	docker-compose build

# Iniciar servicios
up:
	docker-compose up

# Iniciar servicios en background
up-d:
	docker-compose up -d

# Detener servicios
down:
	docker-compose down

# Reiniciar servicios
restart:
	docker-compose restart

# Ver logs
logs:
	docker-compose logs -f

# Rails console
console:
	docker-compose exec web rails console

# Bash en el contenedor
bash:
	docker-compose exec web bash

# Ejecutar migraciones
migrate:
	docker-compose exec web rails db:migrate

# Cargar seeds
seed:
	docker-compose exec web rails db:seed

# Reset completo de DB
reset:
	docker-compose exec web rails db:reset

# Ejecutar tests
test:
	docker-compose exec web rails test

# Limpiar todo
clean:
	docker-compose down -v
	docker system prune -f

# Primera vez: construir, iniciar y configurar
setup:
	docker-compose up --build -d
	@echo "✅ Servicios iniciados"
	@echo "⏳ Esperando a que la aplicación esté lista..."
	@sleep 10
	@echo "✅ ¡Todo listo!"
	@echo ""
	@echo "🌐 API: http://localhost:3000"
	@echo "🔐 Admin: http://localhost:3000/admin"
	@echo "   User: admin@example.com"
	@echo "   Pass: password"

# Ver estado de servicios
status:
	docker-compose ps

# Instalar gemas nuevas
bundle:
	docker-compose exec web bundle install
	docker-compose restart web

