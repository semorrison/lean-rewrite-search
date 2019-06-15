import data.option.defs
import data.buffer

universes u v w

namespace list

def min {α : Type u} (l : list α) [has_le α] [@decidable_rel α has_le.le] : option α :=
l.foldl (λ o a, match o with | none := some a | some b := if b ≤ a then b else a end) none

end list
