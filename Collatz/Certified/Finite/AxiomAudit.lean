import Collatz.Certified.Finite.FirstExcursionKernel

/-!
Standalone trust-boundary audit for the first-excursion certificate.  The
`firstExcursionCheck_true`/`firstExcursionEnvelope` pair records the original
native-evaluation route for comparison.  The `_kernel` theorems are the route
used by the exclusion theorem.
-/

#print axioms Collatz.Certified.Finite.orbitCheck_sound
#print axioms Collatz.Certified.Finite.endpoint_one_two_cycle_le_two
#print axioms Collatz.Certified.Finite.firstExcursionCheck_true
#print axioms Collatz.Certified.Finite.firstExcursionEnvelope
#print axioms Collatz.Certified.Finite.endpoint_113383_69
#print axioms Collatz.Certified.Finite.firstExcursionSeedExact
#print axioms Collatz.Certified.Finite.firstExcursionAllBlocks_true
#print axioms Collatz.Certified.Finite.firstExcursionEnvelope_kernel
#print axioms Collatz.Certified.Finite.firstExcursionSeedExact_kernel
