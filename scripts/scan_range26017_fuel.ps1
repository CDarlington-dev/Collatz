$ErrorActionPreference = 'Stop'

# Independent design-time scan for the fuel parameter used by the Lean
# checker.  This script is not in the proof's trust boundary: every resulting
# interval proposition is reduced again by ordinary Lean `decide`, and fuel
# exhaustion away from 1 returns false.

$lo = 10015
$hi = 26017
$maxSteps = -1
$maxStepsStart = 0
$maxState = [System.Numerics.BigInteger]::Zero
$maxStateStart = 0
$paradoxicalPrefixes = 0

for ($start = $lo; $start -le $hi; $start++) {
    $current = [System.Numerics.BigInteger]$start
    $length = 0
    $powTwo = [System.Numerics.BigInteger]::One
    $powThree = [System.Numerics.BigInteger]::One

    while ($current -ne 1) {
        if ($current % 2 -eq 1) {
            $current = (3 * $current + 1) / 2
            $powThree *= 3
        } else {
            $current /= 2
        }
        $length++
        $powTwo *= 2

        if ($current -gt $maxState) {
            $maxState = $current
            $maxStateStart = $start
        }
        if ($powThree -lt $powTwo -and $start -le $current) {
            $paradoxicalPrefixes++
        }
        if ($length -gt 10000) {
            throw "Unexpected scan limit at start $start"
        }
    }

    if ($length -gt $maxSteps) {
        $maxSteps = $length
        $maxStepsStart = $start
    }
}

[ordered]@{
    map = 'accelerated: even n/2; odd (3n+1)/2'
    lo_inclusive = $lo
    hi_inclusive = $hi
    starts = $hi - $lo + 1
    maximum_steps_to_first_one = $maxSteps
    maximum_steps_start = $maxStepsStart
    maximum_state = $maxState.ToString()
    maximum_state_start = $maxStateStart
    paradoxical_prefixes = $paradoxicalPrefixes
} | ConvertTo-Json
