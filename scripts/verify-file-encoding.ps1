# verify-file-encoding.ps1 - Verification d'encodage post-ecriture
# Version: 1.0.0
# IntentHash: 0xENCODING_VERIFY_20260604
# LastSynced: 2026-06-04
# SyncGroup: ENCODING-20260604
#
# Usage:
#   verify-file-encoding.ps1 -Path <filePath> [-Fix]
#   verify-file-encoding.ps1 -Path <filePath1>,<filePath2>,... [-Fix]
#
# Verifie:
#   1. Absence de BOM (Byte Order Mark)
#   2. Absence de caracteres non-ASCII (pour .json/.ps1/.yml/.yaml)
#   3. Validite syntaxique JSON (pour .json)
#   4. Absence de caracteres de controle (sauf tab, LF, CR)
#
# Reference: GOVERNANCE-HUB/ENCODING-CONVENTION.md
# SyncGroup: ENCODING-20260604 | LastSynced: 2026-06-04
#
# Fichiers couples (mise a jour obligatoire si ce script change):
#   - GOVERNANCE-HUB/ENCODING-CONVENTION.md  (0xENCODING_CONVENTION_20260604)
#   - AGENT_RAM.yaml / ERR_006               (0xAGENT_RAM_V2_1_ENCODING_ERROR_20260604)
#   - REPO-STANDARDS/RSS-v1/config-file-lifecycle.md (0xCONFIG_FILE_LIFECYCLE_20260604)
#   - GOVERNANCE-HUB/CHANGE-CONTROL.md       (0xCHANGE_CONTROL_20260604)

param(
    [Parameter(Mandatory=$true)]
    [string[]]$Path,

    [switch]$Fix
)

$ErrorActionPreference = "Continue"
$exitCode = 0

# Types de fichiers ou le non-ASCII est interdit
$asciiOnlyTypes = @('.json', '.jsonc', '.ps1', '.yml', '.yaml', '.bat', '.cmd')

foreach ($filePath in $Path) {
    Write-Host "=== $filePath ===" -ForegroundColor Cyan

    if (-not (Test-Path $filePath)) {
        Write-Host "[FAIL] Fichier introuvable" -ForegroundColor Red
        $exitCode = 1
        continue
    }

    $bytes = [System.IO.File]::ReadAllBytes($filePath)
    $content = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)
    $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
    $hasError = $false

    # 1. Verification BOM
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        Write-Host "[FAIL] BOM detecte (EF BB BF)" -ForegroundColor Red
        $hasError = $true
        if ($Fix) {
            $cleanBytes = $bytes[3..($bytes.Length - 1)]
            [System.IO.File]::WriteAllBytes($filePath, $cleanBytes)
            Write-Host "[FIX] BOM supprime" -ForegroundColor Yellow
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            $content = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)
        }
    } else {
        Write-Host "[OK] Pas de BOM" -ForegroundColor Green
    }

    # 2. Verification non-ASCII (selon type)
    if ($asciiOnlyTypes -contains $ext) {
        $nonAsciiMatches = [regex]::Matches($content, '[^\x00-\x7F]')
        if ($nonAsciiMatches.Count -gt 0) {
            Write-Host "[FAIL] $($nonAsciiMatches.Count) caractere(s) non-ASCII detecte(s):" -ForegroundColor Red
            foreach ($m in $nonAsciiMatches | Select-Object -First 10) {
                $hex = [System.Convert]::ToString([int]$m.Value[0], 16).ToUpper().PadLeft(4, '0')
                Write-Host "       0x$hex '$($m.Value)' at pos $($m.Index)" -ForegroundColor Red
            }
            $hasError = $true
            if ($Fix) {
                # Supprimer les caracteres non-ASCII (remplacement par vide)
                $cleanContent = $content -replace '[^\x00-\x7F]', ''
                [System.IO.File]::WriteAllText($filePath, $cleanContent, [System.Text.UTF8Encoding]::new($false))
                Write-Host "[FIX] Caracteres non-ASCII supprimes" -ForegroundColor Yellow
                $content = $cleanContent
            }
        } else {
            Write-Host "[OK] Pas de caracteres non-ASCII" -ForegroundColor Green
        }
    }

    # 3. Verification caracteres de controle
    $ctrlMatches = [regex]::Matches($content, '[\x00-\x08\x0B\x0C\x0E-\x1F]')
    if ($ctrlMatches.Count -gt 0) {
        Write-Host "[FAIL] $($ctrlMatches.Count) caractere(s) de controle detecte(s)" -ForegroundColor Red
        $hasError = $true
    } else {
        Write-Host "[OK] Pas de caracteres de controle" -ForegroundColor Green
    }

    # 4. Verification syntaxe JSON
    if ($ext -eq '.json' -or $ext -eq '.jsonc') {
        try {
            $null = $content | ConvertFrom-Json
            Write-Host "[OK] JSON valide" -ForegroundColor Green
        } catch {
            Write-Host "[FAIL] JSON invalide: $($_.Exception.Message)" -ForegroundColor Red
            $hasError = $true
        }
    }

    if ($hasError) {
        $exitCode = 1
    }
    Write-Host ""
}

exit $exitCode
