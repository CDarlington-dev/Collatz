param(
    [ValidateRange(0, 98)]
    [ValidateScript({ $_ % 2 -eq 0 })]
    [int]$StartBlock = 0
)

$ErrorActionPreference = 'Stop'
$workspaceRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$env:ELAN_HOME = Join-Path $workspaceRoot '.tooling\elan-home'
$lakePath = Join-Path $env:ELAN_HOME 'bin\lake.exe'

if (-not (Test-Path -LiteralPath $lakePath -PathType Leaf)) {
    throw "Lake executable not found at $lakePath"
}

function Invoke-LakeBuild {
    param([string[]]$Targets)

    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    & $lakePath build @Targets
    $timer.Stop()
    if ($LASTEXITCODE -ne 0) {
        throw "Lake failed while building: $($Targets -join ', ')"
    }
    "targets=$($Targets -join ',') elapsed_seconds=$([math]::Round($timer.Elapsed.TotalSeconds, 3))"
}

$total = [System.Diagnostics.Stopwatch]::StartNew()
Set-Location -LiteralPath $workspaceRoot
try {
    Invoke-LakeBuild @('Collatz.Certified.Finite.OptimizedFirstExcursion')
    for ($first = $StartBlock; $first -lt 98; $first += 2) {
        $targets = @(
            'Collatz.Certified.Finite.OptimizedFirstExcursionBlocks.Block' +
                $first.ToString('000')
        )
        $targets += (
            'Collatz.Certified.Finite.OptimizedFirstExcursionBlocks.Block' +
                ($first + 1).ToString('000')
        )
        Invoke-LakeBuild $targets
    }
    if ($StartBlock -le 98) {
        Invoke-LakeBuild @(
            'Collatz.Certified.Finite.OptimizedFirstExcursionBlocks.Block098',
            'Collatz.Certified.Finite.OptimizedFirstExcursionBlocks.Tail'
        )
    }
    Invoke-LakeBuild @('Collatz.Certified.Finite.OptimizedFirstExcursionKernel')
    & $lakePath env lean Collatz\Certified\Finite\OptimizedFirstExcursionAxiomAudit.lean
    if ($LASTEXITCODE -ne 0) {
        throw 'Lean failed while checking the axiom audit.'
    }
} finally {
    $total.Stop()
    Set-Location -LiteralPath $PSScriptRoot
}

"optimized_first_excursion_total_seconds=$([math]::Round($total.Elapsed.TotalSeconds, 3))"
