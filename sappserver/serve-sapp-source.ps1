param(
    [int]$Port = 8080,
    [string]$BindAddress = "127.0.0.1",
    [string]$Repo,
    [switch]$NoGenerate
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

$server = Join-Path $Root "sapp_manage_server.py"
if ($python.Name -eq "py.exe") {
    & $python.Source -3 $server --repo $Repo --bind $BindAddress --port $Port
} else {
    & $python.Source $server --repo $Repo --bind $BindAddress --port $Port
}
