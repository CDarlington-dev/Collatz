param(
    [ValidateSet('Base', 'Range', 'Range26017', 'Excursion', 'OptimizedExcursion', 'All')]
    [string]$Family = 'All',
    [ValidateRange(0, 1000000)]
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

    $arguments = @('build') + $Targets
    & $lakePath @arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Lake failed while building: $($Targets -join ', ')"
    }
}

function Build-BlockFamily {
    param(
        [string]$BaseModule,
        [string]$BlockPrefix,
        [int]$BlockCount,
        [string]$AggregateModule,
        [string]$TailModule = '',
        [int]$FirstBlock = 0
    )

    Invoke-LakeBuild @($BaseModule)
    for ($first = $FirstBlock; $first -lt $BlockCount; $first += 2) {
        $targets = @($BlockPrefix + $first.ToString('000'))
        if ($first + 1 -lt $BlockCount) {
            $targets += $BlockPrefix + ($first + 1).ToString('000')
        }
        Invoke-LakeBuild $targets
    }
    if ($TailModule) {
        Invoke-LakeBuild @($TailModule)
    }
    Invoke-LakeBuild @($AggregateModule)
}

$timer = [System.Diagnostics.Stopwatch]::StartNew()
Set-Location -LiteralPath $workspaceRoot
try {
    if ($Family -eq 'Base' -or $Family -eq 'All') {
        Build-BlockFamily `
            -BaseModule 'Collatz.Certified.Finite.BaseClassification' `
            -BlockPrefix 'Collatz.Certified.Finite.BaseClassificationBlocks.Block' `
            -BlockCount 47 `
            -AggregateModule 'Collatz.Certified.Finite.BaseClassificationKernel' `
            -FirstBlock $StartBlock
    }
    if ($Family -eq 'Range' -or $Family -eq 'All') {
        Build-BlockFamily `
            -BaseModule 'Collatz.Certified.Finite.NoParadoxicalRange' `
            -BlockPrefix 'Collatz.Certified.Finite.NoParadoxicalRangeBlocks.Block' `
            -BlockCount 54 `
            -AggregateModule 'Collatz.Certified.Finite.NoParadoxicalRangeKernel' `
            -FirstBlock $StartBlock
    }
    if ($Family -eq 'Range26017' -or $Family -eq 'All') {
        Build-BlockFamily `
            -BaseModule 'Collatz.Certified.Finite.NoParadoxicalRange26017' `
            -BlockPrefix 'Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block' `
            -BlockCount 40 `
            -TailModule 'Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Tail' `
            -AggregateModule 'Collatz.Certified.Finite.NoParadoxicalRange26017Kernel' `
            -FirstBlock $StartBlock
    }
    if ($Family -eq 'Excursion' -or $Family -eq 'All') {
        Build-BlockFamily `
            -BaseModule 'Collatz.Certified.Finite.FirstExcursionKernelBase' `
            -BlockPrefix 'Collatz.Certified.Finite.FirstExcursionBlocks.Block' `
            -BlockCount 114 `
            -AggregateModule 'Collatz.Certified.Finite.FirstExcursionKernel' `
            -FirstBlock $StartBlock
    }
    if ($Family -eq 'OptimizedExcursion' -or $Family -eq 'All') {
        Build-BlockFamily `
            -BaseModule 'Collatz.Certified.Finite.OptimizedFirstExcursion' `
            -BlockPrefix 'Collatz.Certified.Finite.OptimizedFirstExcursionBlocks.Block' `
            -BlockCount 99 `
            -TailModule 'Collatz.Certified.Finite.OptimizedFirstExcursionBlocks.Tail' `
            -AggregateModule 'Collatz.Certified.Finite.OptimizedFirstExcursionKernel' `
            -FirstBlock $StartBlock
    }
} finally {
    $timer.Stop()
    Set-Location -LiteralPath $PSScriptRoot
}

"kernel block build family=$Family start_block=$StartBlock elapsed_seconds=$([math]::Round($timer.Elapsed.TotalSeconds, 3))"
