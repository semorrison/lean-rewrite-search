-- Copyright (c) 2017 Scott Morrison. All rights reserved.
-- Released under Apache 2.0 license as described in the file LICENSE.
-- Authors: Scott Morrison

import .tactic_states
import .hash_target

open tactic

universe variables u v

structure loop_detection_state :=
  ( allowed_collisions : nat )
  ( past_goals : list string )

meta def get_state_hash { σ : Type } [ underlying_tactic_state σ ] ( s : σ ) : string :=
  match (hash_target s) with
  | result.success   hash    s' := hash
  | result.exception pos msg s' := undefined_core "unreachable"
  end

meta def detect_looping
  { σ α : Type }
  [ underlying_tactic_state σ ]
  ( t : interaction_monad (σ × loop_detection_state) α )
  ( allowed_collisions : nat := 0 )
    : interaction_monad σ α :=
λ s, (t (s, ⟨ allowed_collisions, [ get_state_hash s ] ⟩ )).map(λ s'', s''.1)

private meta def lift_ignore_first { σ τ α : Type } ( t : interaction_monad τ α ) : interaction_monad (σ × τ) α :=
  λ s, match t s.2 with
       | result.success   a       s2' := result.success   a       (s.1, s2')
       | result.exception msg pos s2' := result.exception msg pos (s.1, s2')
       end

private meta def lift_ignore_second { σ τ α : Type } ( t : interaction_monad σ α ) : interaction_monad (σ × τ) α :=
  λ s, match t s.1 with
       | result.success   a       s1' := result.success   a       (s1', s.2)
       | result.exception msg pos s1' := result.exception msg pos (s1', s.2)
       end

meta def loop_detector (hash : string) : interaction_monad loop_detection_state bool :=
λ s, if s.past_goals.mem hash then
       if s.allowed_collisions > 0 then
         result.success tt ⟨ s.allowed_collisions - 1, s.past_goals ⟩
       else
         result.success ff s
     else
       result.success tt ⟨ s.allowed_collisions, hash :: s.past_goals ⟩

@[inline] private meta def read' { σ : Type } : interaction_monad σ σ :=
λ s, result.success s s

meta def instrument_for_loop_detection { σ α : Type } [uts : underlying_tactic_state σ] ( t : interaction_monad σ α ) : interaction_monad (σ × loop_detection_state) α :=
  do a ← lift_ignore_second t,
     s ← read',
     let hash := get_state_hash s,
     p ← lift_ignore_first (loop_detector hash),
     if ¬ p then
       do
        let name := interaction_monad.result_to_string (decl_name s.1),
        interaction_monad.trace format!"chain encountered loop during elaboration {name}",
        interaction_monad.failed
     else
       pure a

meta instance instrument_for_loop_detection_coercion { α : Type } : has_coe (interaction_monad tactic_state α) (interaction_monad (tactic_state × loop_detection_state) α) :=
⟨ instrument_for_loop_detection ⟩ 

