param(
  [Parameter(Mandatory=$true)]
  [ValidateSet("dir-exists","notes-exists","sources-exists","state-exists","session","all")]
  [string]$Check
)

$ErrorActionPreference = "Stop"

$asiDir = ".asi/onboard"
$notesFile = Join-Path $asiDir "NOTES.md"
$sourcesFile = Join-Path $asiDir "SOURCES.md"
$stateFile = Join-Path $asiDir "STATE.json"

function Assert-Exists($path, $label) {
  if (Test-Path $path) {
    Write-Host "PASS: $label exists"
    return $true
  }
  Write-Host "FAIL: $label does not exist"
  return $false
}

switch ($Check) {
  "dir-exists" { if (-not (Assert-Exists $asiDir $asiDir)) { exit 1 } }
  "notes-exists" { if (-not (Assert-Exists $notesFile $notesFile)) { exit 1 } }
  "sources-exists" { if (-not (Assert-Exists $sourcesFile $sourcesFile)) { exit 1 } }
  "state-exists" { if (-not (Assert-Exists $stateFile $stateFile)) { exit 1 } }
  "session" {
    $ok = $true
    $ok = (Assert-Exists $asiDir $asiDir) -and $ok
    $ok = (Assert-Exists $notesFile $notesFile) -and $ok
    $ok = (Assert-Exists $sourcesFile $sourcesFile) -and $ok
    $ok = (Assert-Exists $stateFile $stateFile) -and $ok
    if (-not $ok) { exit 1 }
  }
  "all" { & $PSCommandPath -Check "session" }
}

exit 0

