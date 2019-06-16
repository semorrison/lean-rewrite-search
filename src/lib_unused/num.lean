import data.pnat.basic
import lib.num

lemma pnat.succ_pred (n : ℕ+) : nat.succ (nat.pred n) = n :=
begin
  cases n with n h,
  cases n,
  have := lt_irrefl _ h ; contradiction,
  simp
end

def fin.with_max' (n : ℕ) (m : ℕ+) : fin m :=
⟨ min n (m-1), begin
                 have p := min_le_right n (nat.pred m),
                 have q := nat.lt_succ_of_le p,
                 rw nat.succ_pred_eq_of_pos at q,
                 exact q,
                 exact m.property,
               end ⟩