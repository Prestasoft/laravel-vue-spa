# Script para instalar Flutter en Windows
# Ejecutar como Administrador

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Instalador de Flutter para SGVRD App" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar si se está ejecutando como administrador
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "Este script necesita ejecutarse como Administrador." -ForegroundColor Red
    Write-Host "Por favor, cierre y ejecute PowerShell como Administrador." -ForegroundColor Yellow
    pause
    exit 1
}

# Directorio de instalación
$flutterPath = "C:\flutter"

# Verificar si Flutter ya está instalado
if (Test-Path "$flutterPath\bin\flutter.bat") {
    Write-Host "Flutter ya está instalado en $flutterPath" -ForegroundColor Green

    $response = Read-Host "¿Desea actualizar Flutter? (S/N)"
    if ($response -ne 'S' -and $response -ne 's') {
        Write-Host "Instalación cancelada." -ForegroundColor Yellow
        pause
        exit 0
    }
}

# Descargar Flutter SDK
Write-Host "Descargando Flutter SDK..." -ForegroundColor Yellow
$flutterZipUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.9-stable.zip"
$zipPath = "$env:TEMP\flutter.zip"

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $flutterZipUrl -OutFile $zipPath -UseBasicParsing
    Write-Host "Descarga completada." -ForegroundColor Green
}
catch {
    Write-Host "Error al descargar Flutter: $_" -ForegroundColor Red
    pause
    exit 1
}

# Extraer Flutter
Write-Host "Extrayendo Flutter SDK..." -ForegroundColor Yellow

# Eliminar instalación anterior si existe
if (Test-Path $flutterPath) {
    Remove-Item -Path $flutterPath -Recurse -Force
}

# Extraer
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, "C:\")

# Eliminar archivo zip
Remove-Item $zipPath -Force

Write-Host "Flutter extraído en $flutterPath" -ForegroundColor Green

# Agregar Flutter al PATH del sistema
Write-Host "Configurando variables de entorno..." -ForegroundColor Yellow

$currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($currentPath -notlike "*$flutterPath\bin*") {
    [Environment]::SetEnvironmentVariable(
        "Path",
        "$currentPath;$flutterPath\bin",
        "Machine"
    )
    Write-Host "Flutter agregado al PATH del sistema." -ForegroundColor Green
} else {
    Write-Host "Flutter ya está en el PATH." -ForegroundColor Yellow
}

# Refrescar variables de entorno en la sesión actual
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Verificar instalación
Write-Host ""
Write-Host "Verificando instalación..." -ForegroundColor Yellow
& "$flutterPath\bin\flutter.bat" --version

# Ejecutar flutter doctor
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Ejecutando Flutter Doctor" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
& "$flutterPath\bin\flutter.bat" doctor

# Aceptar licencias de Android
Write-Host ""
Write-Host "Aceptando licencias de Android..." -ForegroundColor Yellow
& "$flutterPath\bin\flutter.bat" doctor --android-licenses

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host " Instalación completada!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Cyan
Write-Host "1. Cierre y vuelva a abrir PowerShell o Command Prompt" -ForegroundColor White
Write-Host "2. Navegue a: C:\inetpub\wwwroot\app\sgvrd_flutter" -ForegroundColor White
Write-Host "3. Ejecute: flutter pub get" -ForegroundColor White
Write-Host "4. Para compilar APK: flutter build apk --debug" -ForegroundColor White
Write-Host "5. O ejecute el script: build-app.bat" -ForegroundColor White
Write-Host ""

pause