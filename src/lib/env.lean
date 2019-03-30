import tactic.basic

namespace environment

-- Warning, I have to compute a list of all of the declarations first.
meta def decl_ommap {α : Type} (e : environment) (f : declaration → tactic (option α)) : tactic (list α) :=
  e.get_decls.mfoldl (λ l d, do
    r ← f d,
    return $ match r with
    | some r := r :: l
    | none := l
    end
  ) []

end environment