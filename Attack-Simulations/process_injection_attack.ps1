param(
    [string]$TargetProcess = "notepad.exe",
    [switch]$KeepTargetOpen
)

$ErrorActionPreference = "Stop"

Write-Host "[+] Starting process injection behavior simulation"

$target = Start-Process -FilePath $TargetProcess -PassThru
Start-Sleep -Seconds 1

$encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes("Write-Output 'inject_simulation_marker'"))
Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -EncodedCommand $encoded" | Out-Null

Write-Host "[+] Spawned suspicious child PowerShell process with encoded command"
Write-Host "[+] Target PID: $($target.Id)"

if (-not $KeepTargetOpen) {
    Stop-Process -Id $target.Id -ErrorAction SilentlyContinue
    Write-Host "[+] Closed target process"
}

Write-Host "[+] Process simulation completed"
