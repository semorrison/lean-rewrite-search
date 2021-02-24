import tactic.rewrite_search

universes u₁ u₂

open category_theory

variables {D : Type u₂} {C : Type u₁} [𝒟 : category D] [𝒞 : category C]
include C 𝒞 D 𝒟

local attribute [search]
functor.map_comp is_equivalence.fun_inv_map nat_iso.naturality_1 nat_iso.naturality_2
nat_iso.hom_app_inv_app_id category.assoc is_equivalence.fun_inv_map is_equivalence.inv_fun_map
category.comp_id category.id_comp

instance full_of_equivalence (F : C ⥤ D) [is_equivalence F] : full F :=
{ preimage := λ X Y f, (F.fun_inv_id.app X).inv ≫ (F.inv.map f) ≫ (F.fun_inv_id.app Y).hom,
  witness' := λ X Y f,
  begin
    apply F.inv.injectivity,
    rewrite_search { explain := tt, visualiser },
  end }