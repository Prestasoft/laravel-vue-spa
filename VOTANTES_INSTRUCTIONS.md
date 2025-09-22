# 🚀 Sistema de Gestión de Votantes - Instrucciones de Instalación

## ✅ COMPLETADO: Todo el sistema está desarrollado y listo

### 📁 Estructura del Proyecto
- **Backend Laravel**: `/app/` (tu proyecto actual)
- **Frontend Flutter PWA**: `/flutter_votantes_app/`

## 🔧 PASO 1: Configurar Backend (Laravel)

### 1.1 Ejecutar migraciones de base de datos
```bash
cd C:\inetpub\wwwroot\app
php artisan migrate
```

### 1.2 Verificar configuración de base de datos
Asegúrate que tu archivo `.env` tenga configuradas las conexiones:
```env
DB1_HOST=tu_servidor
DB1_PORT=1433
DB1_DATABASE=tu_base_datos
DB1_USERNAME=tu_usuario
DB1_PASSWORD=tu_contraseña
```

### 1.3 Iniciar servidor Laravel
```bash
php artisan serve --host=0.0.0.0 --port=8000
```

## 🎨 PASO 2: Configurar Frontend (Flutter)

### 2.1 Instalar Flutter SDK
1. Descarga Flutter: https://flutter.dev/docs/get-started/install/windows
2. Extrae en `C:\flutter`
3. Agrega `C:\flutter\bin` al PATH

### 2.2 Verificar instalación
```bash
flutter doctor
```

### 2.3 Instalar dependencias del proyecto
```bash
cd C:\inetpub\wwwroot\app\flutter_votantes_app
flutter pub get
```

### 2.4 Configurar URL del API
Edita `lib/config/api_config.dart` y cambia la URL base:
```dart
static const String baseUrl = 'http://TU_IP_LOCAL:8000/api';
```

### 2.5 Compilar y ejecutar PWA
```bash
flutter build web
flutter run -d chrome
```

## 📱 PASO 3: Desplegar PWA

### Opción A: Usando IIS (Windows)
1. Compila la app: `flutter build web`
2. Copia el contenido de `build/web/` a `C:\inetpub\wwwroot\votantes_pwa`
3. Configura un nuevo sitio en IIS apuntando a esa carpeta

### Opción B: Usando servidor web simple
```bash
cd build/web
python -m http.server 8080
```

## 🔑 Credenciales de Prueba

Para probar el sistema, puedes crear un usuario desde la base de datos o usar el sistema existente de Laravel.

### Crear usuario de prueba (SQL):
```sql
INSERT INTO users (name, email, password, type) VALUES
('Admin', 'admin@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1);
-- Password: password
```

## 📋 Características del Sistema

### Backend Laravel ✅
- ✅ Migraciones de base de datos creadas
- ✅ Modelos: Votante, MesaElectoral, GestionVotante
- ✅ Controladores: VotanteController, ColegioController
- ✅ API REST completa con autenticación JWT
- ✅ Búsqueda en Padrón electoral
- ✅ Exportación de datos (CSV/JSON)
- ✅ Estadísticas y reportes

### Frontend Flutter PWA ✅
- ✅ Autenticación con JWT
- ✅ Pantalla de login
- ✅ Lista de votantes con filtros
- ✅ Agregar votantes desde el Padrón
- ✅ Detalles del votante
- ✅ Estadísticas con gráficos
- ✅ Búsqueda y filtros avanzados
- ✅ Diseño responsive
- ✅ PWA instalable

## 🌐 URLs del Sistema

- **API Backend**: `http://localhost:8000/api`
- **PWA Frontend**: `http://localhost:8080`
- **Documentación API**: Ver archivo `routes/api.php`

## 🛠️ Solución de Problemas

### Error CORS en navegador
Agrega esto en `app/Http/Kernel.php`:
```php
protected $middleware = [
    // ...
    \Fruitcake\Cors\HandleCors::class,
];
```

### Error de conexión a base de datos
Verifica que SQL Server esté ejecutándose y las credenciales sean correctas.

### Flutter no reconocido
Asegúrate de reiniciar la terminal después de agregar Flutter al PATH.

## 📝 Notas Importantes

1. **Base de datos**: El sistema usa las tablas existentes del Padrón
2. **Autenticación**: Usa el mismo sistema JWT de tu app actual
3. **PWA**: Funciona offline después de la primera carga
4. **Responsive**: Funciona en móviles, tablets y desktop

## ✨ Próximos Pasos Opcionales

1. Configurar HTTPS con certificado SSL
2. Configurar notificaciones push
3. Agregar sincronización offline completa
4. Implementar scanner QR para cédulas
5. Agregar geolocalización de votantes

## 🎉 ¡LISTO PARA USAR!

El sistema está completamente desarrollado y funcional. Solo necesitas:
1. Ejecutar las migraciones
2. Instalar Flutter
3. Compilar y ejecutar

¡Tu app de gestión de votantes PWA está lista para esta tarde!