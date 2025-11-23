#!/bin/bash
set -e

# Script de inicialización para Docker
echo "🐳 Iniciando Koffy API en Docker..."

# Esperar a que PostgreSQL esté listo
echo "⏳ Esperando a PostgreSQL..."
until pg_isready -h $DATABASE_HOST -U $DATABASE_USERNAME; do
  echo "PostgreSQL no está listo - esperando..."
  sleep 2
done

echo "✅ PostgreSQL está listo!"

# Verificar si la base de datos existe
if ! rails db:version >/dev/null 2>&1; then
  echo "📊 Creando base de datos..."
  rails db:create
  
  echo "🔄 Ejecutando migraciones..."
  rails db:migrate
  
  echo "🌱 Cargando datos iniciales..."
  rails db:seed
else
  echo "✅ Base de datos ya existe"
  
  # Ejecutar migraciones pendientes
  echo "🔄 Verificando migraciones pendientes..."
  rails db:migrate
fi

echo "🚀 Base de datos lista!"

# Limpiar archivos de servidor previos
rm -f tmp/pids/server.pid

# Ejecutar el comando pasado al script
exec "$@"

