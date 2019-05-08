import data.option.defs data.mllist
import tactic.rewrite_search.core.data

open tactic

universe u

namespace tactic.rewrite_all
meta structure cfg extends rewrite_cfg :=
(try_simp   : bool := ff) -- TODO move the handling logic for me into rewrite_all.wrappers
(discharger : tactic unit := skip)
(simplifier : expr → tactic (expr × expr) := λ e, failed) -- FIXME this currently breaks "explanations"

-- rewrite_all.2, if resurrected, needs to implement this now, see TODO below:
meta structure tracked_rewrite :=
(exp : expr)
(proof : tactic expr)
-- TODO perhaps make this an `option (list side)`, so that the underlying implementation
-- can not return it if it wants.
(addr : list side)
end tactic.rewrite_all

section
variables {m : Type u → Type u} [monad m]
meta def tactic.mllist.squash {α : Type u} (t : m (mllist m α)) : mllist m α :=
(mllist.m_of_list [t]).join
end

