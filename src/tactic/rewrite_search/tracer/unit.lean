import tactic.iconfig
import tactic.rewrite_search.core
import tactic.rewrite_search.module

open tactic.rewrite_search

namespace tactic.rewrite_search.tracer.unit

open tactic

meta def init : tactic (init_result unit) := init_result.pure ()
meta def publish_vertex (_ : unit) (_ : vertex) : tactic unit := skip
meta def publish_edge (_ : unit) (_ : edge) : tactic unit := skip
meta def publish_visited (_ : unit) (_ : vertex) : tactic unit := skip
meta def publish_finished (_ : unit) (_ : list edge) : tactic unit := skip
meta def dump (_ : unit) (_ : string) : tactic unit := skip
meta def pause (_ : unit) : tactic unit := skip

end tactic.rewrite_search.tracer.unit

namespace tactic.rewrite_search.tracer

open tactic.rewrite_search.tracer.unit

meta def no_cfg (_ : name) (_ : interactive.parse interactive.types.texpr) : cfgtactic unit := tactic.skip

iconfig_add rewrite_search [ no : custom no_cfg ]

meta def unit_cnst := λ α β γ,
tracer.mk α β γ unit.init unit.publish_vertex unit.publish_edge unit.publish_visited unit.publish_finished unit.dump unit.pause

meta def unit : tactic expr :=
  generic `tactic.rewrite_search.tracer.unit_cnst

meta def unit_cfg (_ : name) : cfgtactic _root_.unit :=
  iconfig.publish `tracer $ cfgopt.value.pexpr $ expr.const `unit []

iconfig_add rewrite_search [ tracer.unit : custom unit_cfg ]

end tactic.rewrite_search.tracer
