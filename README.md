# ☕ Koffy API

API REST construida con Ruby on Rails que proporciona autenticación JWT con Google OAuth y un panel de administración completo.

## 🌟 Características

- ✅ **API REST en modo API-only**
- ✅ **Autenticación JWT** con devise-jwt
- ✅ **Google OAuth 2.0** para login social
- ✅ **Panel de administración** con ActiveAdmin
- ✅ **PostgreSQL** como base de datos
- ✅ **CORS** configurado para frontends externos
- ✅ **Dual authentication**: JWT para API, sesiones para admins

## 🚀 Inicio Rápido

### Opción A: Con Docker 🐳 (Recomendado)

**La forma más fácil de iniciar:**

```bash
# 1. Configurar variables de entorno
cp .env .env.local  # Edita y agrega tu GOOGLE_CLIENT_ID

# 2. Iniciar con Docker
docker-compose up --build
```

¡Listo! Tu API estará en http://localhost:3000

Ver la [**Guía Completa de Docker**](DOCKER.md) para más detalles.

---

### Opción B: Instalación Local

### 1. Instalar dependencias

Las gemas ya están instaladas. Si necesitas reinstalar:

```bash
bundle install
```

### 2. Configurar PostgreSQL

```bash
sudo service postgresql start
```

### 3. Configurar variables de entorno

Edita el archivo `.env` y agrega tu Google Client ID:

```bash
GOOGLE_CLIENT_ID=tu_client_id_aqui
```

### 4. Configurar base de datos

```bash
rails db:create
rails db:migrate
rails db:seed
```

### 5. Iniciar el servidor

```bash
rails server
```

## 📖 Documentación Completa

- ⚡ **[QUICKSTART.md](QUICKSTART.md)** - ¡Empieza en 3 pasos!
- 🐳 **[DOCKER.md](DOCKER.md)** - Guía completa de Docker (Recomendado)
- 🔧 **[SETUP.md](SETUP.md)** - Configuración detallada (instalación local)
- 💻 **[API_EXAMPLES.md](API_EXAMPLES.md)** - Ejemplos de código para consumir la API
- 🏗️ **[ARCHITECTURE.md](ARCHITECTURE.md)** - Arquitectura y diagramas del sistema
- ✅ **[CHECKLIST.md](CHECKLIST.md)** - Lista de verificación
- 📊 **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** - Resumen del proyecto

## 🔑 Acceso Rápido

### API Endpoints

- **POST** `/auth/google` - Autenticación con Google
- **POST** `/login` - Login con email/password
- **DELETE** `/logout` - Cerrar sesión

### Panel de Administración

- **URL**: http://localhost:3000/admin
- **Usuario por defecto**: admin@example.com
- **Contraseña por defecto**: password

## 📚 Tecnologías

- Ruby 3.1.2
- Rails 7.2.3
- PostgreSQL
- Devise + devise-jwt
- ActiveAdmin
- Rack-CORS

## 🤝 Contribuir

Este proyecto está listo para desarrollo. Personaliza según tus necesidades.

## 📄 Licencia

Este proyecto es de código abierto.
