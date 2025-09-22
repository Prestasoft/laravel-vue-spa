# Especificaciones Sistema de Gestión de Votantes

## Resumen Ejecutivo
Sistema PWA en Flutter para que dirigentes de partidos políticos puedan gestionar sus listas de votantes, integrado con el sistema Laravel existente que consulta el Padrón Electoral.

## Requerimientos Funcionales

### Usuarios y Roles
- **Dirigentes**: Pueden agregar/gestionar sus propios votantes
- **Administradores**: Acceso completo y reportes consolidados
- **Invitados**: Sin acceso al módulo de votantes

### Funcionalidades Core

#### 1. Autenticación
- Login con credenciales existentes del sistema Laravel
- JWT token para sesiones
- Logout y refresh token automático

#### 2. Gestión de Votantes
- Buscar ciudadanos por cédula en el Padrón
- Agregar votantes a lista personal del dirigente
- Editar información adicional (teléfono, dirección, observaciones)
- Asignar colegio electoral y mesa
- Eliminar votantes de la lista
- Prevenir duplicados (un votante por dirigente)

#### 3. Búsquedas y Filtros
- Filtrar por colegio electoral
- Filtrar por mesa
- Búsqueda por nombre o cédula
- Filtros combinados
- Ordenamiento por nombre, fecha de registro, colegio

#### 4. Reportes y Estadísticas
- Total de votantes por dirigente
- Distribución por colegios
- Distribución por mesas
- Votantes agregados por fecha
- Exportar listas a Excel/PDF

#### 5. Funcionalidad Offline
- Almacenamiento local de datos
- Sincronización cuando hay conexión
- Indicador de estado online/offline
- Cola de cambios pendientes

## Requerimientos Técnicos

### Backend (Laravel)
- PHP 7.3+ (compatible con sistema actual)
- SQL Server (bases de datos existentes)
- API REST con autenticación JWT
- Validación de datos
- Paginación en endpoints
- Rate limiting para prevenir abuso

### Frontend (Flutter)
- Flutter 3.0+
- Dart 2.17+
- Provider o Riverpod para estado
- Dio para peticiones HTTP
- Hive o SQLite para almacenamiento local
- flutter_secure_storage para tokens

### PWA Requirements
- Service Worker para offline
- Manifest.json configurado
- HTTPS obligatorio
- Responsive design
- App instalable

## Estructura de Datos

### Tabla: Votantes
| Campo | Tipo | Descripción |
|-------|------|-------------|
| id | INT | PK auto-increment |
| cedula | VARCHAR(11) | Cédula del votante |
| dirigente_id | INT | FK a users |
| colegio_id | INT | FK a Colegio (nullable) |
| mesa | VARCHAR(10) | Código de mesa (nullable) |
| telefono | VARCHAR(20) | Teléfono (nullable) |
| direccion | TEXT | Dirección (nullable) |
| observaciones | TEXT | Notas del dirigente |
| fecha_registro | DATETIME | Fecha de registro |
| activo | BIT | Estado activo/inactivo |

### Tabla: MesasElectorales
| Campo | Tipo | Descripción |
|-------|------|-------------|
| id | INT | PK auto-increment |
| codigo | VARCHAR(20) | Código único de mesa |
| colegio_id | INT | FK a Colegio |
| numero_mesa | INT | Número de mesa |
| ubicacion | TEXT | Descripción ubicación |

### Tabla: GestionesVotantes
| Campo | Tipo | Descripción |
|-------|------|-------------|
| id | INT | PK auto-increment |
| votante_id | INT | FK a Votantes |
| dirigente_id | INT | FK a users |
| tipo_gestion | VARCHAR(50) | Tipo (llamada/visita/mensaje) |
| nota | TEXT | Descripción de la gestión |
| fecha | DATETIME | Fecha de la gestión |

## API Endpoints

### Autenticación
```
POST /api/login
POST /api/logout
POST /api/refresh
GET  /api/user
```

### Votantes
```
GET    /api/votantes?page=1&per_page=20
POST   /api/votantes
GET    /api/votantes/{id}
PUT    /api/votantes/{id}
DELETE /api/votantes/{id}
GET    /api/votantes/buscar/{cedula}
GET    /api/votantes/exportar?formato=excel
```

### Filtros
```
GET /api/votantes?colegio_id={id}
GET /api/votantes?mesa={codigo}
GET /api/votantes?search={texto}
GET /api/votantes?order_by={campo}&order_dir={asc|desc}
```

### Catálogos
```
GET /api/colegios
GET /api/colegios/{id}/mesas
GET /api/mesas
```

### Estadísticas
```
GET /api/estadisticas/votantes
GET /api/estadisticas/por-colegio
GET /api/estadisticas/por-mesa
GET /api/estadisticas/por-dirigente
```

## Interfaces de Usuario

### Pantallas Principales
1. **Login**
   - Campo email
   - Campo contraseña
   - Botón iniciar sesión
   - Link recuperar contraseña

2. **Dashboard**
   - Resumen estadísticas
   - Accesos rápidos
   - Últimos votantes agregados

3. **Lista de Votantes**
   - Barra de búsqueda
   - Filtros (drawer lateral)
   - Lista con cards de votantes
   - Paginación infinita
   - FAB para agregar nuevo

4. **Agregar/Editar Votante**
   - Campo búsqueda por cédula
   - Datos del Padrón (solo lectura)
   - Campos editables (teléfono, dirección, etc.)
   - Selector de colegio y mesa
   - Botón guardar

5. **Detalle de Votante**
   - Información completa
   - Historial de gestiones
   - Opciones de contacto
   - Botón editar/eliminar

6. **Estadísticas**
   - Gráficos de distribución
   - Tablas resumen
   - Opciones de exportación

## Flujos de Usuario

### Flujo: Agregar Votante
1. Usuario toca FAB "+"
2. Ingresa cédula del votante
3. Sistema busca en Padrón
4. Muestra datos encontrados
5. Usuario completa info adicional
6. Selecciona colegio y mesa
7. Guarda votante
8. Regresa a lista actualizada

### Flujo: Filtrar Lista
1. Usuario abre drawer de filtros
2. Selecciona colegio(s)
3. Selecciona mesa(s)
4. Aplica filtros
5. Lista se actualiza
6. Muestra contador de resultados

## Seguridad

### Autenticación y Autorización
- JWT con expiración de 24 horas
- Refresh token de 7 días
- Middleware de autenticación en todas las rutas protegidas
- Validación de permisos por rol

### Validaciones
- Cédula: formato válido dominicano
- Teléfono: formato válido
- Email: formato válido
- Campos requeridos según contexto

### Protección de Datos
- HTTPS obligatorio
- Encriptación de tokens locales
- No almacenar contraseñas localmente
- Logs de auditoría de acciones

## Métricas de Éxito
- Tiempo de carga < 3 segundos
- Funcionalidad offline completa
- Sincronización sin pérdida de datos
- Soporte para 1000+ votantes por dirigente
- Compatibilidad con navegadores modernos
- Instalable como PWA

## Cronograma Estimado
- **Semana 1-2**: Backend API
- **Semana 3**: Flutter estructura base
- **Semana 4-5**: Funcionalidades core
- **Semana 6**: PWA y offline
- **Semana 7**: Testing y ajustes
- **Semana 8**: Despliegue

## Tecnologías Recomendadas

### Backend
- Laravel 8 (existente)
- SQL Server (existente)
- Redis para caché (opcional)

### Frontend
- Flutter 3.19+
- Provider/Riverpod
- Dio + Interceptors
- Hive para storage
- fl_chart para gráficos
- pdf/excel packages para exportación

### DevOps
- Git para versionado
- GitHub Actions para CI/CD
- Docker para contenedores (opcional)
- Nginx para servidor web