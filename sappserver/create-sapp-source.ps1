param(
    [string]$Repo,
    [switch]$KeepPool,
    [switch]$NoSamples,
    [switch]$ValidateOnly
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $Repo) {
    $Repo = Join-Path $Root "repo"
}

$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
    $python = Get-Command py -ErrorAction SilentlyContinue
}
if (-not $python) {
    throw "Python was not found. Install Python or MSYS2 Python, then run this script again."
}

$spk = Join-Path $Root "spk.py"
$argsList = @()
if ($python.Name -eq "py.exe") {
    $argsList += "-3"
}
$argsList += $spk
if ($ValidateOnly) {
    $argsList += @("validate", "--repo", $Repo)
} else {
    $argsList += @("index", "--repo", $Repo)
    if ($KeepPool -or $NoSamples) {
        $argsList += "--no-samples"
    }
}

& $python.Source @argsList
