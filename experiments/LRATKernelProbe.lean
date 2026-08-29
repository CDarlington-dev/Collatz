import Mathlib.Tactic.Sat.FromLRAT

namespace LRATKernelProbe

lrat_proof xor_unsat
  "p cnf 2 4\n1 2 0\n-1 2 0\n1 -2 0\n-1 -2 0\n"
  "5 -2 0 4 3 0\n5 d 3 4 0\n6 1 0 5 1 0\n6 d 1 0\n7 0 5 2 6 0\n"

#print axioms xor_unsat

end LRATKernelProbe
