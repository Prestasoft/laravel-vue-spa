# Script para configurar HTTPS en IIS para el sitio "app"
# Ejecutar como Administrador

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Configuración de HTTPS para Sistema de Votantes" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 1. Crear certificado SSL autofirmado
Write-Host "`n1. Creando certificado SSL autofirmado..." -ForegroundColor Yellow

$cert = New-SelfSignedCertificate `
    -DnsName "198.100.150.217", "localhost", "sistema-votantes.local" `
    -CertStoreLocation "cert:\LocalMachine\My" `
    -FriendlyName "Sistema Votantes SSL" `
    -NotAfter (Get-Date).AddYears(5) `
    -KeyAlgorithm RSA `
    -KeyLength 2048

if ($cert) {
    Write-Host "   ✓ Certificado creado exitosamente" -ForegroundColor Green
    Write-Host "   Thumbprint: $($cert.Thumbprint)" -ForegroundColor Gray
} else {
    Write-Host "   ✗ Error al crear certificado" -ForegroundColor Red
    exit 1
}

# 2. Importar módulo de IIS
Write-Host "`n2. Importando módulo de IIS..." -ForegroundColor Yellow
Import-Module IISAdministration
Import-Module WebAdministration
Write-Host "   ✓ Módulos importados" -ForegroundColor Green

# 3. Agregar binding HTTPS al sitio
Write-Host "`n3. Configurando binding HTTPS..." -ForegroundColor Yellow

try {
    # Verificar si ya existe un binding HTTPS
    $existingBinding = Get-WebBinding -Name "app" -Protocol "https"

    if ($existingBinding) {
        Write-Host "   ! Eliminando binding HTTPS existente..." -ForegroundColor Yellow
        Remove-WebBinding -Name "app" -Protocol "https" -Port 443
    }

    # Crear nuevo binding HTTPS
    New-WebBinding -Name "app" `
        -Protocol "https" `
        -Port 443 `
        -IPAddress "198.100.150.217" `
        -SslFlags 0

    Write-Host "   ✓ Binding HTTPS creado en puerto 443" -ForegroundColor Green

    # Asignar certificado al binding
    $binding = Get-WebBinding -Name "app" -Protocol "https"
    $binding.AddSslCertificate($cert.Thumbprint, "My")

    Write-Host "   ✓ Certificado SSL asignado al binding" -ForegroundColor Green

} catch {
    Write-Host "   ✗ Error al configurar binding: $_" -ForegroundColor Red
}

# 4. Configurar reglas de firewall
Write-Host "`n4. Configurando firewall de Windows..." -ForegroundColor Yellow

try {
    # Verificar si ya existe la regla
    $existingRule = Get-NetFirewallRule -DisplayName "HTTPS Sistema Votantes" -ErrorAction SilentlyContinue

    if ($existingRule) {
        Write-Host "   ! Regla de firewall ya existe" -ForegroundColor Yellow
    } else {
        New-NetFirewallRule `
            -DisplayName "HTTPS Sistema Votantes" `
            -Direction Inbound `
            -Protocol TCP `
            -LocalPort 443 `
            -Action Allow `
            -Profile Any

        Write-Host "   ✓ Regla de firewall creada para puerto 443" -ForegroundColor Green
    }
} catch {
    Write-Host "   ✗ Error al configurar firewall: $_" -ForegroundColor Red
}

# 5. Reiniciar IIS
Write-Host "`n5. Reiniciando IIS..." -ForegroundColor Yellow
iisreset /noforce
Write-Host "   ✓ IIS reiniciado" -ForegroundColor Green

# 6. Mostrar información de acceso
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "CONFIGURACIÓN COMPLETADA" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Ahora puedes acceder al sistema usando:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  HTTP:  http://198.100.150.217" -ForegroundColor White
Write-Host "  HTTPS: https://198.100.150.217" -ForegroundColor Green
Write-Host ""
Write-Host "NOTA: El navegador mostrará una advertencia de seguridad" -ForegroundColor Yellow
Write-Host "porque el certificado es autofirmado. Puedes ignorarla" -ForegroundColor Yellow
Write-Host "haciendo clic en 'Avanzado' y luego 'Continuar'." -ForegroundColor Yellow
Write-Host ""
Write-Host "Para dispositivos móviles:" -ForegroundColor Cyan
Write-Host "- En Chrome Android: Toca Avanzado y luego Continuar" -ForegroundColor White
Write-Host "- En Safari iOS: Toca Detalles y luego Visitar sitio web" -ForegroundColor White
Write-Host ""