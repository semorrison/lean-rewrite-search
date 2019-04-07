import data.option
import data.buffer

import .interaction_monad

universes u v w

namespace list

def min {α : Type u} (l : list α) [has_le α] [@decidable_rel α has_le.le] : option α :=
l.foldl (λ o a, match o with | none := some a | some b := if b ≤ a then b else a end) none

-- def multiplex {α : Type u} : list α → list α → list α
-- | [] l := l
-- | l [] := l
-- | (a₁ :: l₁) (a₂ :: l₂) := [a₁, a₂].append $ l₁.multiplex l₂

def split_on_aux {α : Type u} [decidable_eq α] (a : α) : list α → list α → list (list α)
| [] l       := [l.reverse]
| (h :: t) l := if h = a then
                  l.reverse :: (split_on_aux t [])
                else
                  split_on_aux t (h :: l)

def split_on {α : Type u} [decidable_eq α] (a : α) : list α → list (list α)
| l := split_on_aux a l []

-- def erasep {α : Type u} (f : α → Prop) [decidable_pred f] : list α → list α
-- | [] := []
-- | (h :: t) := if f h then t else (h :: t.erasep)

-- This is monad.sequence
-- def factor {m : Type u → Type v} [monad m] {α : Type u} : list (m α) → m (list α)
-- | []          := return []
-- | (a :: rest) := do a ← a, rest ← factor rest, return $ (a :: rest)

-- def ffactor {m : Type u → Type v} [monad m] [alternative m] {α : Type u} : list (m α) → m (list α)
-- | []          := return []
-- | (a :: rest) := do
--   a ← (some <$> a) <|> pure none,
--   rest ← ffactor rest,
--   return $ a.to_list ++ rest

end list
