param(
  [Parameter(Mandatory=$true)]
  [ValidateRange(1,3)]
  [int]$Step,
  [switch]$Advance
)

$ErrorActionPreference = "Stop"

try {
  $repoRoot = (git rev-parse --show-toplevel 2>$null)
  if (-not $repoRoot) { $repoRoot = "." }
} catch {
  $repoRoot = "."
}

Set-Location $repoRoot

$asiDir = ".asi/onboard"
$notesFile = Join-Path $asiDir "NOTES.md"
$stateFile = Join-Path $asiDir "STATE.json"
$sourcesFile = Join-Path $asiDir "SOURCES.md"

if (-not (Test-Path $notesFile) -or -not (Test-Path $sourcesFile) -or -not (Test-Path $stateFile)) {
  throw "Onboarding artifacts missing. Run scripts/init.ps1 first."
}

$notes = Get-Content -Raw $notesFile
if ($notes -notmatch "### Step $Step — ") {
  throw "NOTES.md does not contain injected entry for step $Step"
}

Write-Host "PASS: Step $Step appears injected into NOTES.md"

if ($Advance -and (Get-Command jq -ErrorAction SilentlyContinue)) {
  $ts = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
  $tmp = "$stateFile.tmp"
  jq --arg step "$Step" --arg ts "$ts" `
    '.steps[$step].status = "complete" | .steps[$step].completed_at = $ts | .current_step = ($step | tonumber)' `
    $stateFile | Set-Content -Path $tmp
  Move-Item -Force $tmp $stateFile
  Write-Host "PASS: STATE.json advanced to step $Step"
}

exit 0

