# Script para configurar HTTPS en IIS
# Ejecutar como Administrador

Write-Host "Configurando HTTPS para Sistema de Votantes" -ForegroundColor Cyan

# Crear certificado SSL autofirmado
Write-Host "Creando certificado SSL..." -ForegroundColor Yellow

$cert = New-SelfSignedCertificate `
    -DnsName "198.100.150.217", "localhost" `
    -CertStoreLocation "cert:\LocalMachine\My" `
    -FriendlyName "Sistema Votantes SSL" `
    -NotAfter (Get-Date).AddYears(5)

Write-Host "Certificado creado: $($cert.Thumbprint)" -ForegroundColor Green

# Importar modulos IIS
Import-Module IISAdministration
Import-Module WebAdministration

# Verificar binding HTTPS existente
$binding = Get-WebBinding -Name "app" -Protocol "https" -ErrorAction SilentlyContinue

if ($binding) {
    Write-Host "Eliminando binding HTTPS existente..." -ForegroundColor Yellow
    Remove-WebBinding -Name "app" -Protocol "https" -Port 443
}

# Crear binding HTTPS
Write-Host "Creando binding HTTPS..." -ForegroundColor Yellow

New-WebBinding -Name "app" `
    -Protocol "https" `
    -Port 443 `
    -IPAddress "198.100.150.217"

# Asignar certificado
$binding = Get-WebBinding -Name "app" -Protocol "https"
$binding.AddSslCertificate($cert.Thumbprint, "My")

Write-Host "Binding HTTPS configurado" -ForegroundColor Green

# Configurar firewall
Write-Host "Configurando firewall..." -ForegroundColor Yellow

$rule = Get-NetFirewallRule -DisplayName "HTTPS Sistema Votantes" -ErrorAction SilentlyContinue
if (-not $rule) {
    New-NetFirewallRule `
        -DisplayName "HTTPS Sistema Votantes" `
        -Direction Inbound `
        -Protocol TCP `
        -LocalPort 443 `
        -Action Allow
    Write-Host "Regla de firewall creada" -ForegroundColor Green
}

# Reiniciar IIS
Write-Host "Reiniciando IIS..." -ForegroundColor Yellow
iisreset /noforce

Write-Host ""
Write-Host "CONFIGURACION COMPLETADA" -ForegroundColor Green
Write-Host ""
Write-Host "Acceso HTTP:  http://198.100.150.217" -ForegroundColor White
Write-Host "Acceso HTTPS: https://198.100.150.217" -ForegroundColor Green
Write-Host ""
Write-Host "NOTA: El navegador mostrara una advertencia de seguridad." -ForegroundColor Yellow
Write-Host "Haz clic en Avanzado y luego en Continuar al sitio." -ForegroundColor Yellow