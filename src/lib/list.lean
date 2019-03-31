import data.option
import data.buffer

import .interaction_monad

universes u v w

namespace list

private def min_rel_aux {α : Type u} (r : α → α → Prop) [decidable_rel r] (curr : α) : list α → α
| [] := curr
| (a :: rest) := if r a curr then a else curr

def min_rel {α : Type u} (l : list α) (r : α → α → Prop) [decidable_rel r] : option α :=
  match l with
  | [] := none
  | (a :: rest) := some $ min_rel_aux r a rest
  end

def min {α : Type u} (l : list α) [has_lt α] [@decidable_rel α has_lt.lt] : option α :=
  min_rel l has_lt.lt

def multiplex {α : Type u} : list α → list α → list α
| [] l := l
| l [] := l
| (a₁ :: l₁) (a₂ :: l₂) := [a₁, a₂].append $ l₁.multiplex l₂

def split_on_aux {α : Type u} [decidable_eq α] (a : α) : list α → list α → list (list α)
| [] l       := [l.reverse]
| (h :: t) l := if h = a then
                  l.reverse :: (split_on_aux t [])
                else
                  split_on_aux t (h :: l)

def split_on {α : Type u} [decidable_eq α] (a : α) : list α → list (list α)
| l := split_on_aux a l []

def erase_first_such_that {α : Type u} (f : α → Prop) [decidable_pred f] : list α → list α
| [] := []
| (h :: t) := if f h then t else (h :: t.erase_first_such_that)

meta def factor {m : Type u → Type u} [monad m] {α : Type u} : list (m α) → m (list α)
| []          := return []
| (a :: rest) := do a ← a, rest ← factor rest, return $ (a :: rest)

meta def ffactor {m : Type u → Type v} [monad m] [alternative m] {α : Type u} : list (m α) → m (list α)
| []          := return []
| (a :: rest) := do
  a ← (some <$> a) <|> pure none,
  rest ← ffactor rest,
  return $ a.to_list ++ rest

end list
