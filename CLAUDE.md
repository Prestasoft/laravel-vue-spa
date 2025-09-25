# CLAUDE.md

Este archivo proporciona orientación a Claude Code (claude.ai/code) cuando trabaja con código en este repositorio.

## Resumen del Proyecto

Esta es una aplicación SPA Laravel-Vue que gestiona la autenticación de usuarios, búsquedas en base de datos SQL Server (Padron) y gestión de votantes. La aplicación utiliza JWT para autenticación, Vue 2 para el frontend, y se conecta a múltiples bases de datos SQL Server.

## Comandos

### Desarrollo
- `npm run dev` - Ejecutar servidor de desarrollo con recarga en caliente
- `npm run watch` - Observar cambios en archivos
- `npm run watch-win` - Observar cambios en archivos (Windows)
- `npm run build` - Compilar para producción
- `npm run build-win` - Compilar para producción (Windows con NODE_OPTIONS)
- `npm run eslint` - Ejecutar ESLint con corrección automática

### Pruebas
- `vendor/bin/phpunit` - Ejecutar pruebas unitarias y de características
- `php artisan dusk` - Ejecutar pruebas de navegador

### Laravel Artisan
- `php artisan serve` - Iniciar servidor de desarrollo Laravel
- `php artisan migrate` - Ejecutar migraciones de base de datos
- `php artisan key:generate` - Generar clave de aplicación
- `php artisan jwt:secret` - Generar secreto JWT

## Arquitectura

### Configuración de Base de Datos
La aplicación usa múltiples conexiones de base de datos:
- **sqlsrv_db1**: Base de datos principal conteniendo tablas `users`, `Padron`, `UserSearchLogs`, `votantes`, `gestiones_votantes`, `Colegio`
- **sqlsrv_db2**: Base de datos secundaria conteniendo tabla `FOTOS_PRM_PRM` para fotos

Todos los modelos definen explícitamente su conexión usando `protected $connection = 'sqlsrv_db1';`

### Estructura Frontend
- **Vue 2 + Vuex + Vue Router** arquitectura SPA
- Componentes organizados bajo `resources/js/`:
  - `pages/` - Componentes de ruta (home, users, votantes, historials, páginas auth)
  - `components/` - Componentes reutilizables (Navbar, Card, Button, etc.)
  - `layouts/` - Componentes de diseño (default, basic, error)
  - `store/modules/` - Módulos Vuex para gestión de estado
  - `router/routes.js` - Definiciones de rutas
  - Alias `~` apunta al directorio `resources/js/`

### Flujo de Autenticación
- Autenticación basada en JWT usando `tymon/jwt-auth`
- Modelo User implementa interfaz `JWTSubject`
- Rutas API protegidas con middleware `auth:api`
- Tipos de usuario: `TYPE_ADMIN = 1`, `TYPE_GUEST = 2`

### Controladores Principales
- **PadronController**: Maneja búsquedas de registros ciudadanos, registra todas las búsquedas
- **UserController**: Operaciones CRUD de usuarios (solo admin)
- **LogController**: Funcionalidad de visualización de logs de búsqueda
- **VotanteController**: Gestión completa de votantes (CRUD, búsqueda, estadísticas)
- **ColegioController**: Listado de colegios electorales

### Sistema de Votantes
- **Modelo Votante**: Gestión de votantes con campos cédula, teléfono, mesa, colegio_id
- **Relaciones**: Votante pertenece a User (dirigente), tiene muchas GestionVotante
- **Características**:
  - Búsqueda y agregación de votantes desde padrón electoral
  - Gestión de estado (activo/inactivo)
  - Asignación a mesas y colegios
  - Sistema de fotos con carga lazy loading
  - Estadísticas y filtros avanzados
  - Interfaz profesional con diseño responsivo

### Estructura de Rutas API
Rutas protegidas (`auth:api`):
- `/votantes` - CRUD completo de votantes
- `/votantes/buscar/{cedula}` - Búsqueda de votante en padrón
- `/votantes/estadisticas` - Estadísticas de votantes
- `/votantes/{cedula}/foto` - Obtención de foto individual
- `/colegios` - Listado de colegios
- Endpoints de gestión de usuarios
- Endpoints de búsqueda
- Visualización de logs de búsqueda

Rutas públicas (`guest:api`):
- Autenticación (login, registro, recuperación contraseña)
- Integración OAuth
- Endpoints públicos de búsqueda

### Proceso de Compilación
- Laravel Mix con cargador Vue
- Extracción CSS en producción
- Hashing de versión para busting de caché
- Salida de compilación en directorio `public/dist/`

### Notas Importantes para Windows/IIS
- Usar `npm run build-win` en lugar de `npm run build` para evitar errores OpenSSL
- La aplicación está desplegada en IIS con configuración en `public/web.config`
- Base URL configurada como `http://198.100.150.217/`

### Cambios Recientes Implementados
1. **Sistema de Votantes Completo**: Página profesional con estadísticas, filtros y gestión completa
2. **Corrección de Autenticación**: Arreglado sistema JWT para aplicación principal y PWA
3. **Integración con SQL Server**: Corregidos mapeos de campos y sensibilidad a mayúsculas
4. **Diseño Profesional**: Interfaz moderna con gradientes, animaciones y diseño responsivo
5. **Sistema de Fotos**: Implementado lazy loading para evitar errores de codificación
6. **Botones Profesionales**: Rediseñados con gradientes y efectos hover
7. **Interacción Mejorada**: Click en nombre, cédula o foto muestra detalles del votante