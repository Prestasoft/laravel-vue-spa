# 📱 SGVRD Flutter - Guía de Desarrollo para Mac Studio

## 🎯 Resumen del Proyecto

**SGVRD** (Sistema de Gestión de Votantes República Dominicana) es una aplicación Flutter que se conecta con el backend Laravel existente en https://198.100.150.217 para gestionar votantes con funcionalidades de GPS, fotos, y sincronización offline.

## 🚀 Configuración Inicial en Mac Studio

### 1. Instalar Flutter en macOS

```bash
# Instalar Homebrew si no lo tienes
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Instalar Flutter
brew install --cask flutter

# Verificar instalación
flutter doctor

# Aceptar licencias de Android
flutter doctor --android-licenses
```

### 2. Instalar Herramientas de Desarrollo

```bash
# Xcode (para iOS)
# Instalar desde App Store

# Android Studio
brew install --cask android-studio

# VS Code (recomendado)
brew install --cask visual-studio-code

# Extensiones VS Code recomendadas
code --install-extension Dart-Code.dart-code
code --install-extension Dart-Code.flutter
```

### 3. Clonar y Configurar el Proyecto

```bash
# Clonar el proyecto (ajusta la ruta según tu configuración)
cd ~/Documents
git clone [tu-repositorio] sgvrd_flutter
cd sgvrd_flutter

# Instalar dependencias
flutter pub get

# Abrir en VS Code
code .
```

## 📁 Estructura del Proyecto

```
sgvrd_flutter/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   └── api_constants.dart      # URLs y configuración API
│   │   ├── theme/
│   │   │   └── app_theme.dart          # Tema con colores dominicanos
│   │   └── utils/
│   │       └── router.dart             # Configuración de rutas
│   ├── data/
│   │   ├── datasources/
│   │   │   └── api_service.dart        # Servicio API con Dio
│   │   └── models/
│   │       ├── user_model.dart         # Modelo de usuario
│   │       └── votante_model.dart      # Modelo de votante
│   ├── presentation/
│   │   ├── providers/
│   │   │   ├── auth_provider.dart      # Estado de autenticación
│   │   │   ├── votante_provider.dart   # Estado de votantes
│   │   │   └── location_provider.dart  # Estado de ubicación
│   │   └── screens/
│   │       ├── login_screen.dart       # ✅ Pantalla de login
│   │       ├── dashboard_screen.dart   # ✅ Dashboard con estadísticas
│   │       ├── votantes_screen.dart    # ✅ Lista de votantes
│   │       ├── votante_detail_screen.dart # ⚠️ Por completar
│   │       ├── map_screen.dart         # ⚠️ Por completar
│   │       └── profile_screen.dart     # ⚠️ Por completar
│   └── main.dart                       # Punto de entrada
├── android/                            # Configuración Android
├── ios/                                # Configuración iOS
└── pubspec.yaml                        # Dependencias
```

## 🔧 Configuración del Entorno

### Archivo: `lib/core/constants/api_constants.dart`
```dart
class ApiConstants {
  // IMPORTANTE: Cambiar según tu entorno
  static const String baseUrl = 'https://198.100.150.217';
  static const String apiUrl = '$baseUrl/api';

  // Para desarrollo local, puedes usar:
  // static const String baseUrl = 'http://localhost:8000';
}
```

### Permitir Certificados Autofirmados (Desarrollo)
El código ya incluye en `main.dart`:
```dart
ApiService.allowSelfSignedCertificate();
```

## 📋 Estado Actual del Desarrollo

### ✅ Completado
- [x] Estructura del proyecto con clean architecture
- [x] Modelos de datos (User, Votante)
- [x] Servicio API con Dio y manejo de errores
- [x] Autenticación JWT con almacenamiento seguro
- [x] Pantalla de Login con animaciones
- [x] Dashboard con estadísticas
- [x] Lista de votantes con búsqueda
- [x] Providers de estado (Auth, Votante, Location)
- [x] Navegación con go_router
- [x] Tema con colores dominicanos

### ⚠️ Por Completar

#### 1. Pantalla de Detalle/Edición de Votante
**Archivo:** `lib/presentation/screens/votante_detail_screen.dart`

Funcionalidades necesarias:
- Formulario para editar datos del votante
- Búsqueda por cédula en el padrón
- Captura de foto desde cámara
- Captura de ubicación GPS
- Validación de duplicados
- Guardar y sincronizar

#### 2. Vista de Mapa
**Archivo:** `lib/presentation/screens/map_screen.dart`

Funcionalidades necesarias:
- Integrar flutter_map o google_maps_flutter
- Mostrar marcadores con fotos de votantes
- Filtros por coordinador/colegio
- Clusters para agrupar marcadores
- Navegación a ubicación

#### 3. Perfil de Usuario
**Archivo:** `lib/presentation/screens/profile_screen.dart`

Funcionalidades necesarias:
- Mostrar información del usuario
- Cambiar contraseña
- Ver permisos asignados
- Cerrar sesión
- Configuración de la app

#### 4. Base de Datos Local (SQLite)
Implementar para modo offline:
```dart
// Crear archivo: lib/data/datasources/local_database.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  // Implementar:
  // - Crear tablas locales
  // - CRUD de votantes offline
  // - Cola de sincronización
  // - Manejo de conflictos
}
```

#### 5. Sincronización Offline
Implementar lógica de sincronización:
- Detectar conexión/desconexión
- Guardar cambios localmente
- Sincronizar cuando hay conexión
- Resolver conflictos

#### 6. Escáner de Cédula
Integrar OCR para cédulas:
```dart
// Dependencias necesarias:
// camera: ^0.10.5
// google_mlkit_text_recognition: ^0.11.0
```

## 🛠️ Comandos Útiles para Desarrollo

```bash
# Ejecutar en iOS Simulator
flutter run -d ios

# Ejecutar en Android Emulator
flutter run -d android

# Ejecutar en dispositivo físico
flutter run

# Ver dispositivos disponibles
flutter devices

# Limpiar proyecto
flutter clean

# Actualizar dependencias
flutter pub upgrade

# Generar iconos de la app
flutter pub run flutter_launcher_icons:main

# Analizar código
flutter analyze

# Ejecutar tests
flutter test

# Ver cobertura de tests
flutter test --coverage
```

## 📦 Compilación para Producción

### iOS (Mac Studio)
```bash
# Compilar para iOS
flutter build ios --release

# Abrir en Xcode para firmar y subir a App Store
open ios/Runner.xcworkspace

# Compilar IPA directamente
flutter build ipa --release
```

### Android
```bash
# APK para distribución directa
flutter build apk --release

# App Bundle para Google Play
flutter build appbundle --release

# APK dividido por arquitectura
flutter build apk --split-per-abi --release
```

## 🔑 Endpoints del API Backend

El backend Laravel expone los siguientes endpoints:

### Autenticación
- `POST /api/login` - Login con email y password
- `POST /api/logout` - Cerrar sesión
- `GET /api/user` - Obtener usuario actual

### Votantes
- `GET /api/votantes` - Lista paginada de votantes
- `POST /api/votantes` - Crear nuevo votante
- `PUT /api/votantes/{id}` - Actualizar votante
- `DELETE /api/votantes/{id}` - Eliminar votante
- `GET /api/votantes/buscar/{cedula}` - Buscar por cédula
- `GET /api/votantes/foto/{cedula}` - Obtener foto del padrón
- `GET /api/votantes/estadisticas` - Estadísticas generales
- `GET /api/votantes/mapa` - Datos para el mapa

### Colegios
- `GET /api/colegios` - Lista de colegios electorales

## 🎨 Guía de Diseño

### Colores Principales (Bandera Dominicana)
```dart
static const Color primaryBlue = Color(0xFF002D62);  // Azul
static const Color primaryRed = Color(0xFFCE1126);   // Rojo
static const Color white = Colors.white;              // Blanco
```

### Tipografía
- Font Family: Montserrat
- Títulos: Bold, 20-24sp
- Subtítulos: SemiBold, 16-18sp
- Texto: Regular, 14-16sp

### Iconos
- Material Icons
- Tamaño estándar: 24dp
- Tamaño pequeño: 16-20dp

## 📱 Permisos Necesarios

### iOS (ios/Runner/Info.plist)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>SGVRD necesita acceso a tu ubicación para registrar votantes</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>SGVRD necesita acceso a tu ubicación para registrar votantes</string>
<key>NSCameraUsageDescription</key>
<string>SGVRD necesita acceso a la cámara para tomar fotos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>SGVRD necesita acceso a tus fotos</string>
```

### Android (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.CALL_PHONE"/>
```

## 🐛 Debugging Tips

### Conexión con Backend
1. Si tienes problemas de certificado SSL:
   - Asegúrate de que `ApiService.allowSelfSignedCertificate()` esté activo
   - Para producción, usa un certificado válido

2. Para probar con backend local:
   - Cambia `baseUrl` en `api_constants.dart`
   - Usa `http://10.0.2.2:8000` para Android Emulator
   - Usa `http://localhost:8000` para iOS Simulator

### Hot Reload
- Comando: `r` en terminal
- Hot Restart: `R` en terminal
- No funciona con cambios en `main()` o nuevos packages

## 📚 Recursos Adicionales

### Documentación
- [Flutter Docs](https://flutter.dev/docs)
- [Dart Docs](https://dart.dev/guides)
- [Provider Pattern](https://pub.dev/packages/provider)
- [Go Router](https://pub.dev/packages/go_router)

### Packages Clave Utilizados
- `dio: ^5.4.0` - Cliente HTTP
- `provider: ^6.1.1` - Gestión de estado
- `go_router: ^13.1.0` - Navegación
- `flutter_secure_storage: ^9.0.0` - Almacenamiento seguro
- `geolocator: ^10.1.0` - GPS
- `image_picker: ^1.0.7` - Captura de imágenes
- `flutter_map: ^6.1.0` - Mapas
- `sqflite: ^2.3.0` - Base de datos local

## 🚀 Próximos Pasos Recomendados

1. **Completar formulario de votante**
   - Implementar búsqueda por cédula
   - Agregar captura de foto
   - Implementar captura GPS

2. **Implementar mapa interactivo**
   - Configurar flutter_map
   - Mostrar votantes con GPS
   - Agregar filtros

3. **Agregar modo offline**
   - Configurar SQLite
   - Implementar sincronización
   - Manejar conflictos

4. **Testing**
   - Escribir unit tests
   - Widget tests
   - Integration tests

5. **Optimización**
   - Lazy loading de imágenes
   - Caché de datos
   - Reducir tamaño del APK

## 💡 Notas Importantes

1. **Seguridad**: Nunca hardcodees credenciales en el código
2. **Performance**: Usa `const` constructors donde sea posible
3. **Estado**: Mantén el estado mínimo necesario
4. **Errores**: Siempre maneja errores de red y muestra feedback al usuario
5. **UX**: Muestra loaders durante operaciones asíncronas

## 📞 Información del Backend

- **URL**: https://198.100.150.217
- **Tipo**: Laravel 8.x con JWT
- **Base de Datos**: SQL Server
- **Autenticación**: Bearer Token JWT

## ✨ Características Especiales del Proyecto

1. **Multi-usuario**: Admin, Candidato, Coordinador, Invitado
2. **GPS Obligatorio**: Para nuevos votantes
3. **Fotos del Padrón**: Se obtienen del servidor
4. **Control de Duplicados**: Validación por cédula
5. **Jerarquía**: Candidatos > Coordinadores > Votantes

---

**¡Éxito con el desarrollo en tu Mac Studio!** 🚀

Si necesitas ayuda adicional, el código está completamente documentado y listo para continuar el desarrollo.