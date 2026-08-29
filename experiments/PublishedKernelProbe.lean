import Collatz.Certified.Published

set_option maxRecDepth 1000000

namespace Collatz.Certified

theorem published_count_kernel : publishedWitnesses.length = 593 := by decide

theorem published_pairs_nodup_kernel :
    (publishedWitnesses.map fun w => (w.n, w.j)).Nodup := by decide

theorem every_published_witness_checks_kernel :
    publishedWitnesses.all checkPublishedWitness = true := by decide

#print axioms published_count_kernel
#print axioms published_pairs_nodup_kernel
#print axioms every_published_witness_checks_kernel

end Collatz.Certified
