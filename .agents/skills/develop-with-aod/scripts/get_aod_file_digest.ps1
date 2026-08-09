[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]$AodYamlPath
)

$ErrorActionPreference = 'Stop'

$file = Get-Item -LiteralPath $AodYamlPath -ErrorAction Stop
if ($file.PSIsContainer) {
    throw "AOD-YAML path is a directory: $($file.FullName)"
}
if (-not $file.Name.EndsWith('.aod.yaml', [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "AOD-YAML filename must end in .aod.yaml: $($file.Name)"
}

$hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $file.FullName).Hash.ToLowerInvariant()
"sha256:$hash"
