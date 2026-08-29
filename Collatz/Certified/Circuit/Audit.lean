import Collatz.Certified.Circuit.Demo

/-!
# Kernel axiom audit for the circuit/LRAT path

This module is intentionally separate from the public import surface.  Build it to print the
axioms used by the structural circuit semantics, width-generic arithmetic bridge, and static
demo certificate.
-/

#print axioms Collatz.Certified.Circuit.satisfies_circuit_toFmla_iff
#print axioms Collatz.Certified.Circuit.no_model_of_lrat
#print axioms Collatz.Certified.Circuit.Bits.rippleAdd_value
#print axioms Collatz.Certified.Circuit.Bits.acceleratedBits_value
#print axioms Collatz.Certified.Circuit.Bits.fixedWidthAcceleratedBits_value_of_no_overflow
#print axioms Collatz.Certified.Circuit.Demo.acceleratedStep8_semantic
#print axioms Collatz.Certified.Circuit.Demo.interval26to27OneStep_lrat
#print axioms Collatz.Certified.Circuit.Demo.interval26to27OneStep_no_model

