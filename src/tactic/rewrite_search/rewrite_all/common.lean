import data.option.defs data.mllist
import tactic.rewrite_search.core.data

open tactic

universe u

-- rewrite_all.2, if resurrected, needs to implement this now, see TODO below:

meta structure tracked_rewrite :=
(exp : expr)
(proof : tactic expr)
-- TODO perhaps make this an `option (list side)`, so that the underlying implementation
-- can not return it if it wants.
(addr : list side)

section
variables {m : Type u → Type u} [monad m]
meta def mllist.squash {α : Type u} (t : m (mllist m α)) : mllist m α :=
(mllist.m_of_list [t]).join

-- meta def bar : tactic (mllist tactic ℕ) :=
-- do trace "z",
--    return $ mllist.m_of_list $ (list.range 4).map (λ n, do trace n, return n)
-- meta def bar' : mllist tactic ℕ := mllist.squash bar

-- meta def qux : tactic unit :=
-- do l ← bar'.force,
--    trace l

-- example : false :=
-- by qux
end

