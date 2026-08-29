param(
    [switch]$Write
)

$ErrorActionPreference = 'Stop'
$workspaceRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$blockDirectory = Join-Path $workspaceRoot 'Collatz\Certified\Finite\NoParadoxicalRange26017Blocks'
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

function Test-OrWriteExactSource {
    param(
        [string]$Path,
        [string]$Content
    )

    $normalized = $Content.Replace("`r`n", "`n") + "`n"
    if ($Write) {
        [System.IO.Directory]::CreateDirectory((Split-Path -Parent $Path)) | Out-Null
        [System.IO.File]::WriteAllText($Path, $normalized, $utf8NoBom)
    } else {
        if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
            throw "Missing generated source: $Path"
        }
        $actual = [System.IO.File]::ReadAllText($Path).Replace("`r`n", "`n")
        if ($actual -cne $normalized) {
            throw "Generated source differs: $Path"
        }
    }
}

for ($block = 0; $block -lt 40; $block++) {
    $id = $block.ToString('000')
    $content = @"
import Collatz.Certified.Finite.NoParadoxicalRange26017

namespace Collatz.Certified.Finite

theorem noParadoxicalRange26017Block${id}_true :
    noParadoxicalRange26017BlockCheck $block = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
"@
    Test-OrWriteExactSource `
        -Path (Join-Path $blockDirectory "Block${id}.lean") `
        -Content $content
}

$tail = @"
import Collatz.Certified.Finite.NoParadoxicalRange26017

namespace Collatz.Certified.Finite

theorem noParadoxicalRange26017Tail_true :
    noParadoxicalRange26017TailCheck = true := by
  set_option maxRecDepth 1000000 in
    decide

end Collatz.Certified.Finite
"@
Test-OrWriteExactSource -Path (Join-Path $blockDirectory 'Tail.lean') -Content $tail

if ($Write) {
    "Regenerated 40 full block wrappers and the exact tail."
} else {
    "All 40 full block wrappers and the exact tail match the generator."
}
