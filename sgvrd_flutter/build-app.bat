@echo off
echo ========================================
echo  SGVRD Flutter App Build Script
echo ========================================
echo.

echo Instalando dependencias...
call flutter pub get
if %errorlevel% neq 0 (
    echo Error al instalar dependencias
    pause
    exit /b 1
)

echo.
echo Limpiando proyecto...
call flutter clean
if %errorlevel% neq 0 (
    echo Error al limpiar proyecto
    pause
    exit /b 1
)

echo.
echo Instalando dependencias nuevamente...
call flutter pub get
if %errorlevel% neq 0 (
    echo Error al instalar dependencias
    pause
    exit /b 1
)

echo.
echo ========================================
echo  Seleccione tipo de compilación:
echo ========================================
echo  1. Debug APK (para desarrollo)
echo  2. Release APK (para producción)
echo  3. App Bundle (para Play Store)
echo  4. Solo probar en emulador
echo ========================================
echo.

set /p build_type="Ingrese opción (1-4): "

if "%build_type%"=="1" (
    echo.
    echo Compilando APK Debug...
    call flutter build apk --debug
    if %errorlevel% equ 0 (
        echo.
        echo ========================================
        echo  ¡APK Debug creado exitosamente!
        echo ========================================
        echo Ubicación: build\app\outputs\flutter-apk\app-debug.apk
        echo.
        explorer build\app\outputs\flutter-apk
    )
) else if "%build_type%"=="2" (
    echo.
    echo Compilando APK Release...
    call flutter build apk --release
    if %errorlevel% equ 0 (
        echo.
        echo ========================================
        echo  ¡APK Release creado exitosamente!
        echo ========================================
        echo Ubicación: build\app\outputs\flutter-apk\app-release.apk
        echo.
        explorer build\app\outputs\flutter-apk
    )
) else if "%build_type%"=="3" (
    echo.
    echo Compilando App Bundle...
    call flutter build appbundle --release
    if %errorlevel% equ 0 (
        echo.
        echo ========================================
        echo  ¡App Bundle creado exitosamente!
        echo ========================================
        echo Ubicación: build\app\outputs\bundle\release\app-release.aab
        echo.
        explorer build\app\outputs\bundle\release
    )
) else if "%build_type%"=="4" (
    echo.
    echo Ejecutando en emulador...
    call flutter run
) else (
    echo Opción inválida
)

echo.
pause