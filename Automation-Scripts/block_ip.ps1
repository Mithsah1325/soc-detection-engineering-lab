param(
    [Parameter(Mandatory = $true)]
    [string]$IpAddress,

    [string]$RulePrefix = "SOC-Block"
)

$ErrorActionPreference = "Stop"

if (-not [System.Net.IPAddress]::TryParse($IpAddress, [ref]([System.Net.IPAddress]$null))) {
    throw "Invalid IP address: $IpAddress"
}

$ruleName = "$RulePrefix-$IpAddress"

$existingRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
if ($null -ne $existingRule) {
    Write-Host "[+] Firewall rule already exists: $ruleName"
    exit 0
}

New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -Action Block -RemoteAddress $IpAddress | Out-Null
Write-Host "[+] Blocked inbound traffic from $IpAddress with rule '$ruleName'"