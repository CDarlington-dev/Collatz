import Collatz.Certified.Finite.ClassificationCertificate

/-!
# Axiom audit for the finite-classification certificate primitives

This module is intentionally tiny: compiling it prints the kernel dependencies
of the checker bridge and of both pure-kernel demonstration theorems.
-/

#print axioms Collatz.Certified.Finite.ScaledPrefixCell.paradoxical_iff_lattice
#print axioms Collatz.Certified.Finite.scannerCellBounds_iff
#print axioms Collatz.Certified.Finite.finiteBaseClassification_six
#print axioms Collatz.Certified.Finite.finiteBaseClassification_six_is_sharp
