# ================================================================
# push-igp-to-github.ps1  — creates the repo (if needed) and uploads
# the IGP-Deep-Dive lab to GitHub via the REST API. No git required.
#
# HOW TO RUN:
#   1. Create a token at https://github.com/settings/tokens
#      (Fine-grained: "Administration" = Read/Write, "Contents" = Read/Write,
#       or a classic token with the  repo  scope)
#   2. Paste the token into $TOKEN below
#   3. Right-click this file -> "Run with PowerShell"
#   4. After it finishes, delete the token from this file and revoke it
# ================================================================

$TOKEN   = "PASTE_YOUR_TOKEN_HERE"   # <-- replace this
$OWNER   = "bosamart"
$REPO    = "IGP-Deep-Dive"           # repo name to create / push to
$PRIVATE = $false                    # set $true for a private repo
$DESC    = "IS-IS & OSPF deep-dive lab: configs, topology, docs, and verification notes"
$BASE    = "C:\Users\ATH\Claude\Projects\Network-Engineering\Labs\IGP-Deep-Dive"

$headers = @{
    Authorization = "token $TOKEN"
    Accept        = "application/vnd.github+json"
    "User-Agent"  = $OWNER
}

# ---- Validate token ----
if ($TOKEN -eq "PASTE_YOUR_TOKEN_HERE") {
    Write-Host "ERROR: You forgot to paste your token!" -ForegroundColor Red
    pause; exit
}

Write-Host ""
Write-Host "=== Pushing IGP-Deep-Dive Lab to GitHub ===" -ForegroundColor Cyan
Write-Host ""

# ---- Create the repo if it does not exist ----
Write-Host "[1/3] Ensuring repo $OWNER/$REPO exists..." -ForegroundColor Cyan
$repoUrl = "https://api.github.com/repos/$OWNER/$REPO"
$exists  = $false
try {
    Invoke-RestMethod -Uri $repoUrl -Headers $headers -Method Get | Out-Null
    $exists = $true
    Write-Host "  Repo already exists - will push into it." -ForegroundColor Yellow
} catch {}

if (-not $exists) {
    $createBody = @{
        name        = $REPO
        description = $DESC
        private     = $PRIVATE
        auto_init   = $false
    }
    try {
        Invoke-RestMethod -Uri "https://api.github.com/user/repos" -Headers $headers `
            -Method Post -Body (ConvertTo-Json $createBody) -ContentType "application/json" | Out-Null
        Write-Host "  Created https://github.com/$OWNER/$REPO" -ForegroundColor Green
    } catch {
        Write-Host "  FAIL creating repo - $($_.Exception.Message)" -ForegroundColor Red
        pause; exit
    }
}

# ---- Upload one file ----
function Push-File($localPath, $repoPath) {
    $content = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($localPath))
    $url     = "https://api.github.com/repos/$OWNER/$REPO/contents/$repoPath"

    # Get existing SHA if the file is already there (so we update instead of fail)
    $sha = $null
    try {
        $existing = Invoke-RestMethod -Uri $url -Headers $headers -Method Get
        $sha = $existing.sha
    } catch {}

    $body = @{ message = "Add $repoPath"; content = $content }
    if ($sha) { $body.sha = $sha }

    try {
        Invoke-RestMethod -Uri $url -Headers $headers -Method Put `
            -Body (ConvertTo-Json $body) -ContentType "application/json" | Out-Null
        Write-Host "  OK   $repoPath" -ForegroundColor Green
    } catch {
        Write-Host "  FAIL $repoPath - $($_.Exception.Message)" -ForegroundColor Red
    }
}

# ---- Walk the lab folder and upload everything ----
Write-Host ""
Write-Host "[2/3] Uploading files..." -ForegroundColor Cyan

$files = Get-ChildItem -Path $BASE -Recurse -File | Where-Object {
    $_.FullName -ne $PSCommandPath          # don't upload this script itself
}

foreach ($f in $files) {
    $rel = $f.FullName.Substring($BASE.Length).TrimStart('\').Replace('\','/')
    Push-File $f.FullName $rel
}

Write-Host ""
Write-Host "[3/3] Done!" -ForegroundColor Green
Write-Host ""
Write-Host "Repo: https://github.com/$OWNER/$REPO" -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANT: delete your token from this file and revoke it at" -ForegroundColor Yellow
Write-Host "           https://github.com/settings/tokens" -ForegroundColor Yellow
Write-Host ""
pause
