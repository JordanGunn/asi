param(
  [Parameter(Mandatory=$true)]
  [ValidateSet("--check")]
  [string]$Mode
)

$missing = $false

if (Get-Command jq -ErrorAction SilentlyContinue) {
  Write-Host "PASS: jq found"
} else {
  Write-Host "WARN: jq not found (recommended for JSON handling)"
  $missing = $true
}

if (Get-Command git -ErrorAction SilentlyContinue) {
  Write-Host "PASS: git found"
} else {
  Write-Host "WARN: git not found (repo root detection may be limited)"
}

if (-not $missing) {
  Write-Host "PASS: bootstrap checks complete"
}

exit 0

