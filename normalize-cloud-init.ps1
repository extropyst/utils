# PowerShell script para normalizar cloud-init.yml
param(
  [string]$File = 'cloud-init.yml'
)
if (-not (Test-Path $File)) { Write-Error "No encontrado: $File"; exit 2 }

# Backup
Copy-Item $File "$File.bak" -Force

# Leer, convertir CRLF->LF, tabs->2 espacios y quitar trailing spaces
$content = Get-Content $File -Raw
$content = $content -replace "\r\n","\n"
$content = $content -replace "\t","  "
$lines = $content -split "\n" | ForEach-Object { $_ -replace '\s+$','' }

# Reescribir con LF
[System.IO.File]::WriteAllText((Resolve-Path $File).Path, ($lines -join "`n"))
Write-Output "Normalización completada: $File (backup: $File.bak)"
