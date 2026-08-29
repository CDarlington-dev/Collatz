import Std.Tactic.BVDecide
import Lean.Elab.Command
open Lean
run_cmd do
  for (n, _) in (← getEnv).constants.toList do
    if n.toString.contains "toCNF.go" || n.toString.contains "toCNF.State.empty" ||
        n.toString.contains "bitblast.go" then
      logInfo n.toString
