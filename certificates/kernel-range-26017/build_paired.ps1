$ErrorActionPreference = 'Stop'
$workspaceRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$env:ELAN_HOME = Join-Path $workspaceRoot '.tooling\elan-home'
$lake = Join-Path $env:ELAN_HOME 'bin\lake.exe'

if (-not (Test-Path -LiteralPath $lake -PathType Leaf)) {
    throw "Lake executable not found at $lake"
}

Set-Location -LiteralPath $workspaceRoot
$total = [System.Diagnostics.Stopwatch]::StartNew()

& $lake build Collatz.Certified.Finite.NoParadoxicalRange26017
if ($LASTEXITCODE -ne 0) { throw 'Base module failed' }

$prefix = 'Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Block'
for ($first = 0; $first -lt 40; $first += 2) {
    $second = $first + 1
    $target1 = $prefix + $first.ToString('000')
    $target2 = $prefix + $second.ToString('000')
    $pair = [System.Diagnostics.Stopwatch]::StartNew()
    & $lake build $target1 $target2
    if ($LASTEXITCODE -ne 0) {
        throw "Block pair $first,$second failed"
    }
    $pair.Stop()
    "pair=$($first.ToString('000'))-$($second.ToString('000')) " +
        "elapsed_seconds=$([math]::Round($pair.Elapsed.TotalSeconds, 3))"
}

& $lake build Collatz.Certified.Finite.NoParadoxicalRange26017Blocks.Tail
if ($LASTEXITCODE -ne 0) { throw 'Tail failed' }

& $lake build Collatz.Certified.Finite.NoParadoxicalRange26017Kernel
if ($LASTEXITCODE -ne 0) { throw 'Aggregate failed' }

& $lake env lean Collatz\Certified\Finite\NoParadoxicalRange26017AxiomAudit.lean
if ($LASTEXITCODE -ne 0) { throw 'Axiom audit failed' }

$total.Stop()
"complete elapsed_seconds=$([math]::Round($total.Elapsed.TotalSeconds, 3))"
