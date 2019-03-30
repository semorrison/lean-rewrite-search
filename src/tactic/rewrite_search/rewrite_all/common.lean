import data.option.basic
import tactic.rewrite_search.core.data

universe u

-- rewrite_all.2, if resurrected, needs to implement this now, see TODO below:

meta structure tracked_rewrite :=
(exp : expr)
(proof : tactic expr)
-- TODO perhaps make this an `option (list side)`, so that the underlying implementation
-- can not return it if it wants.
(addr : list side)