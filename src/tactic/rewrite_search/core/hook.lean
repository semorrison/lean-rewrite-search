import lib.tactic
import tactic.rewrite_search.rewrite_all.wrappers

import .common

namespace tactic.rewrite_search

meta def rewrite_progress := mllist tactic rewrite

meta def progress_init (rs : list (expr × bool)) (exp : expr) (cfg : rewrite_all.cfg) : tactic rewrite_progress := do
  l ← all_rewrites_mllist rs exp cfg,
  l.map $ λ t, ⟨t.1.exp, t.1.proof, how.rewrite t.2.1 t.2.2 t.1.addr⟩

meta def progress_next : rewrite_progress → tactic (rewrite_progress × option rewrite)
| mllist.nil        := return (mllist.nil, none)
| (mllist.cons a l) := do r ← l, return (r, some a)

meta def simp_rewrite (exp : expr) : tactic rewrite := do
  (simp_exp, simp_prf) ← tactic.simp_expr exp,
  return ⟨simp_exp, pure simp_prf, how.simp⟩

-- FIXME I don't know how to extract a proof of equality from `simp_lemmas.dsimplify`
-- meta def dsimp_rewrite (exp : expr) : tactic rewrite := do
--   dsimp_exp ← tactic.dsimp_expr exp,
--   return $ some ⟨dsimp_exp, ???, how.defeq⟩

meta def discover_more_rewrites (rs : list (expr × bool)) (exp : expr) (cfg : rewrite_all.cfg) (_ : side) (prog : option rewrite_progress) : tactic (option rewrite_progress × list rewrite) := do
  (prog, head) ← match prog with
         | some prog := pure (prog, [])
         | none := do
          prog ← progress_init rs exp cfg,
          sl ← if cfg.try_simp then option.to_list <$> tactic.try_core (simp_rewrite exp) else pure [],
          pure (prog, sl)
         end,
  (prog, rw) ← progress_next prog,
  return (some prog, head.append rw.to_list)

end tactic.rewrite_search