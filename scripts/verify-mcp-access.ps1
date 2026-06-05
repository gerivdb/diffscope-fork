# verify-mcp-access.ps1 - Verifie l'acces MCP cross-repo
# IntentHash: 0xMCP_VERIFY_20260603

param(
    [switch]$Fix
)

$ErrorActionPreference = "Stop"

$requiredPaths = @(
    "C:\DevTools",
    "D:\DO\WEB"
)

$mcpConfig = "C:\DevTools\.kilocode\mcp.json"

Write-Host "=== Verification Acces MCP ===" -ForegroundColor Cyan
Write-Host ""

# 1. Verifier les repertoires
foreach ($path in $requiredPaths) {
    if (Test-Path $path) {
        Write-Host "[OK] $path existe" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] $path introuvable" -ForegroundColor Red
    }
}

# 2. Verifier la config MCP
if (Test-Path $mcpConfig) {
    Write-Host "[OK] mcp.json existe" -ForegroundColor Green
    $config = Get-Content $mcpConfig -Raw | ConvertFrom-Json
    $dirs = $config.mcpServers.filesystem.allowedDirectories
    foreach ($path in $requiredPaths) {
        if ($dirs -contains $path) {
            Write-Host "[OK] $path dans allowedDirectories" -ForegroundColor Green
        } else {
            Write-Host "[FAIL] $path manquant dans allowedDirectories" -ForegroundColor Red
            if ($Fix) {
                $dirs += $path
                Write-Host "[FIX] $path ajoute" -ForegroundColor Yellow
            }
        }
    }
    if ($Fix) {
        $config | ConvertTo-Json -Depth 10 | Set-Content $mcpConfig -Encoding UTF8
        Write-Host "[FIX] mcp.json mis a jour" -ForegroundColor Yellow
    }
} else {
    Write-Host "[WARN] mcp.json introuvable" -ForegroundColor Yellow
    if ($Fix) {
        $newConfig = @{
            mcpServers = @{
                filesystem = @{
                    command = "npx"
                    args = @("-y", "@modelcontextprotocol/server-filesystem", "C:\\DevTools", "D:\\DO\\WEB")
                    allowedDirectories = $requiredPaths
                }
            }
        }
        $newConfig | ConvertTo-Json -Depth 10 | Set-Content $mcpConfig -Encoding UTF8
        Write-Host "[FIX] mcp.json cree" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== Verification terminee ===" -ForegroundColor Cyan
