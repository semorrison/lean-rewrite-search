-- Copyright (c) 2017 Scott Morrison. All rights reserved.
-- Released under Apache 2.0 license as described in the file LICENSE.
-- Authors: Scott Morrison

import .at_least_one 

open tactic


meta def auto_cases_at (h : expr) : tactic string :=
do (do
   n ← num_goals,
   cases h,
   n' ← num_goals,
   guard (n' < n),
   pp ← pp h, 
   return ("cases " ++ pp.to_string)
) <|>
do {  t' ← infer_type h,
      t' ← whnf t',
      let use_cases := match t' with
      | `(unit)      := tt
      | `(punit)     := tt
      | `(ulift _)   := tt
      | `(plift _)   := tt
      | `(prod _ _)  := tt
      | `(and _ _)   := tt
      | `(sigma _)   := tt
      | `(subtype _) := tt
      | `(Exists _)  := tt
      | `(fin 0)     := tt
      | `(sum _ _)   := tt -- This is perhaps dangerous!
      | `(or _ _)    := tt -- This is perhaps dangerous!
      | _            := ff
      end,
      if use_cases then
        do cases h, pp ← pp h, return ("cases " ++ pp.to_string)
      else
        match t' with
        -- `cases` can be dangerous on `eq` and `quot`, producing mysterious errors during type checking.
        -- instead we attempt `induction`
        | `(eq _ _)        := (do induction h, pp ← pp h, return ("induction " ++ pp.to_string))
        | `(quot _)        := do induction h, pp ← pp h, return ("induction " ++ pp.to_string)
        | _                := failed
        end
}

/-- Applies `cases` or `induction` on certain hypotheses. -/
meta def auto_cases : tactic string :=
do l ← local_context,
   results ← at_least_one (l.reverse.map(λ h, auto_cases_at h)),
   return (string.intercalate ", " results)
