import .name

namespace lean.parser

open lean interactive.types

meta def opt_single_or_list {α : Type} (ps : lean.parser α) : lean.parser (list α) :=
  list_of ps <|> ((λ h, list.cons h []) <$> ps) <|> return []

meta def cur_options : lean.parser options := λ s, interaction_monad.result.success (parser_state.options s) s

meta def emit_command_here (str : string) : lean.parser string := do
  (_, left) ← with_input command_like str,
  return left

meta def emit_code_here (str : string) : lean.parser unit := do
  left ← emit_command_here str,
  if left.length = 0 then return ()
  else interaction_monad.fail "did not parse all of passed code"

-- TODO polish up the `mk_*` family to be more robust, to the point where we take
-- the same arguments as environment.add

meta def var_string (v : name × expr) : string :=
  "(" ++ to_string v.1 ++ " : " ++ to_string v.2 ++ ")"

-- FIXME at the moment attribute errors cause a red line at the top of the window
-- TODO support more compicated annotation syntax.
meta def mk_definition_here_raw (n : name) (vars : list (name × expr)) (type : option expr) (value : string) (is_meta : bool := ff) (annotations : list string := []) : lean.parser unit :=
  emit_code_here $
    (if annotations.length = 0 then "" else "@" ++ annotations.to_string ++ " ")
    ++ (if is_meta then "meta " else "") ++ "def " ++ to_string n
    ++ string.intercalate " " (vars.map var_string)
    ++ match type with | none := "" | some type := " : " ++ to_string type end
    ++ " := " ++ to_string value

meta def mk_definition_here (n : name) (vars : list (name × expr)) (type : option expr) (value : expr) (is_meta : bool := ff) (annotations : list name := []) : lean.parser unit :=
  mk_definition_here_raw n vars type (to_string value) is_meta (annotations.map to_string)

-- TODO implement `mk_attribute_here`/`mk_attribute_here_raw`

meta def get_current_namespace : lean.parser name := do
  n ← name.mk_user_fresh_name "secret" "ns___",
  mk_definition_here_raw n [] `(unit) "()",
  n ← tactic.resolve_constant n,
  return $ (list.range 5).foldl (λ nn : name, λ _, nn.get_prefix) n

end lean.parser