import data.equiv.basic
import group_theory.subgroup
import set_theory.cardinal
import order.basic
import tactic.abel

-- import for_mathlib.with_zero
import for_mathlib.punit_instances

universes u v
set_option old_structure_cmd true

class linear_ordered_comm_monoid (α : Type*) extends comm_monoid α, linear_order α :=
(mul_le_mul_left : ∀ {a b : α}, a ≤ b → ∀ c : α, c * a ≤ c * b)

class linear_ordered_comm_group (α : Type*) extends comm_group α, linear_ordered_comm_monoid α

namespace linear_ordered_structure
variables {α : Type u} [linear_ordered_comm_monoid α] {x y z : α}
variables {β : Type v} [linear_ordered_comm_monoid β]

lemma mul_le_mul_left (h : x ≤ y) (c : α) : c * x ≤ c * y :=
linear_ordered_comm_monoid.mul_le_mul_left h c

class linear_ordered_comm_monoid.is_hom (f : α → β) extends is_monoid_hom f : Prop :=
(ord : ∀ {a b : α}, a ≤ b → f a ≤ f b)

structure linear_ordered_comm_monoid.equiv extends equiv α β :=
(is_hom : linear_ordered_comm_monoid.is_hom to_fun)

lemma mul_le_mul_right (H : x ≤ y) : ∀ z : α, x * z ≤ y * z :=
λ z, mul_comm z x ▸ mul_comm z y ▸ mul_le_mul_left H z
end linear_ordered_structure

namespace linear_ordered_structure
section monoid
variables {α : Type u} [linear_ordered_comm_monoid α] {x y z : α}
variables {β : Type v} [linear_ordered_comm_monoid β]

lemma one_le_mul_of_one_le_of_one_le (Hx : 1 ≤ x) (Hy : 1 ≤ y) : 1 ≤ x * y :=
have h1 : x * 1 ≤ x * y, from mul_le_mul_left Hy x,
have h2 : x ≤ x * y, by rwa mul_one x at h1,
le_trans Hx h2

lemma one_le_pow_of_one_le {n : ℕ} (H : 1 ≤ x) : 1 ≤ x^n :=
begin
  induction n with n ih,
  { exact le_refl 1 },
  { exact one_le_mul_of_one_le_of_one_le H ih }
end

lemma mul_le_one_of_le_one_of_le_one (Hx : x ≤ 1) (Hy : y ≤ 1) : x * y ≤ 1 :=
have h1 : x * y ≤ x * 1, from mul_le_mul_left Hy x,
have h2 : x * y ≤ x, by rwa mul_one x at h1,
le_trans h2 Hx

lemma pow_le_one_of_le_one {n : ℕ} (H : x ≤ 1) : x^n ≤ 1 :=
begin
  induction n with n ih,
  { exact le_refl 1 },
  { exact mul_le_one_of_le_one_of_le_one H ih }
end

/-- Wedhorn Remark 1.6 (3) -/
lemma eq_one_of_pow_eq_one {n : ℕ} (hn : n ≠ 0) (H : x ^ n = 1) : x = 1 :=
begin
  rcases nat.exists_eq_succ_of_ne_zero hn with ⟨n, rfl⟩, clear hn,
  induction n with n ih,
  { simpa using H },
  { cases le_total x 1,
    all_goals
    { have h1 := mul_le_mul_right h (x ^ (n+1)),
      rw pow_succ at H,
      rw [H, one_mul] at h1 },
    { have h2 := pow_le_one_of_le_one h,
      exact ih (le_antisymm h2 h1) },
    { have h2 := one_le_pow_of_one_le h,
      exact ih (le_antisymm h1 h2) } }
end

open_locale classical

lemma le_one_of_pow_le_one {a : α} (n : ℕ) (hn : n ≠ 0) (h : a^n ≤ 1) : a ≤ 1 :=
begin
  rcases lt_or_eq_of_le h with H|H,
  { apply le_of_lt, contrapose! H, exact one_le_pow_of_one_le H, },
  { apply le_of_eq, exact eq_one_of_pow_eq_one hn H }
end

end monoid

section group
variables {α : Type u} [linear_ordered_comm_group α] {x y z : α}
variables {β : Type v} [linear_ordered_comm_group β]

class linear_ordered_comm_group.is_hom (f : α → β) extends is_group_hom f : Prop :=
(ord : ∀ {a b : α}, a ≤ b → f a ≤ f b)

-- this is Kenny's; I think we should have iff
structure linear_ordered_comm_group.equiv extends equiv α β :=
(is_hom : linear_ordered_comm_group.is_hom to_fun)

lemma div_le_div (a b c d : α) : a * b⁻¹ ≤ c * d⁻¹ ↔ a * d ≤ c * b :=
begin
  split ; intro h,
  have := mul_le_mul_right (mul_le_mul_right h b) d,
  rwa [inv_mul_cancel_right, mul_assoc _ _ b, mul_comm _ b, ← mul_assoc, inv_mul_cancel_right] at this,
  have := mul_le_mul_right (mul_le_mul_right h d⁻¹) b⁻¹,
  rwa [mul_inv_cancel_right, _root_.mul_assoc, _root_.mul_comm d⁻¹ b⁻¹, ← mul_assoc, mul_inv_cancel_right] at this,
end

lemma inv_le_one_of_one_le (H : 1 ≤ x) : x⁻¹ ≤ 1 :=
by simpa using mul_le_mul_left H (x⁻¹)

lemma inv_le_inv_of_le (H : x ≤ y) : y⁻¹ ≤ x⁻¹ :=
have h1 : _ := mul_le_mul_left H (x⁻¹ * y⁻¹),
by rwa [inv_mul_cancel_right, mul_comm x⁻¹, inv_mul_cancel_right] at h1

lemma le_one_or_inv_le_one (x : α) : x ≤ 1 ∨ x⁻¹ ≤ 1 :=
or.imp id inv_le_one_of_one_le (le_total x 1)

lemma le_or_inv_le_inv (x y : α) : x ≤ y ∨ x⁻¹ ≤ y⁻¹ :=
or.imp id inv_le_inv_of_le (le_total x y)

end group

end linear_ordered_structure

namespace linear_ordered_structure
variables {α : Type*} [linear_ordered_comm_group α]
instance inhabited : inhabited α := ⟨1⟩

lemma mul_lt_right  :
  ∀ {a b} c : α, a < b → a*c < b*c :=
begin
  introv h,
  rw lt_iff_le_and_ne,
  refine ⟨linear_ordered_structure.mul_le_mul_right (le_of_lt h) _, _⟩,
  intro h',
  rw mul_right_cancel h' at h,
  exact lt_irrefl b h
end

lemma mul_lt_left  :
  ∀ {a b} c : α, a < b → c*a < c*b :=
begin
  introv h,
  rw [mul_comm c, mul_comm c],
  exact mul_lt_right _ h,
end

lemma mul_lt_mul  :
  ∀ {a b c d : α}, a < b → c < d → a*c < b*d :=
begin
  introv hab hcd,
  calc a*c < b*c : mul_lt_right _ hab
  ... < b*d : mul_lt_left _ hcd
end

lemma lt_of_mul_lt_mul_left {α : Type*} [linear_ordered_comm_group α] :
  ∀ a b c : α, a * b < a * c → b < c :=
λ a b c h, lt_of_not_ge (λ h', lt_irrefl _ $ lt_of_lt_of_le h $
                               linear_ordered_structure.mul_le_mul_left h' a)

-- TODO: for completeness, we would need variations
lemma mul_inv_lt_of_lt_mul {x y z : α} (h : x < y*z) : x*z⁻¹ < y :=
by simpa [mul_inv_cancel_right] using mul_lt_right z⁻¹ h

-- TODO find the right decidability type class when PRing, instead of using `classical`
lemma exists_square_le (a : α) : ∃ b : α, b*b ≤ a :=
begin
  classical,
  by_cases h : a < 1,
  { use a,
    have := mul_lt_right a h,
    rw one_mul at this,
    exact le_of_lt this },
  { use 1,
    push_neg at h,
    rwa mul_one }
end

end linear_ordered_structure

namespace linear_ordered_structure
variables {α : Type*} [linear_ordered_comm_group α]
variables {β : Type v} [linear_ordered_comm_group β]

class is_convex (S : set α) : Prop :=
(one_mem : (1:α) ∈ S)
(mul_mem : ∀ {x y}, x ∈ S → y ∈ S → x * y ∈ S)
(inv_mem : ∀ {x}, x ∈ S → x⁻¹ ∈ S)
(mem_of_between : ∀ {x y}, x ≤ y → y ≤ (1:α) → x ∈ S → y ∈ S)

class is_proper_convex (S : set α) extends is_convex S : Prop :=
(exists_ne : ∃ (x y : α) (hx : x ∈ S) (hy : y ∈ S), x ≠ y)

definition convex_linear_order : linear_order {S : set α // is_convex S} :=
{ le_total := λ ⟨x, hx⟩ ⟨y, hy⟩, classical.by_contradiction $ λ h,
    let ⟨h1, h2⟩ := not_or_distrib.1 h,
        ⟨m, hmx, hmny⟩ := set.not_subset.1 h1,
        ⟨n, hny, hnnx⟩ := set.not_subset.1 h2 in
    begin
      cases le_total m n with hmn hnm,
      { cases le_one_or_inv_le_one n with hn1 hni1,
        { exact hnnx (@@is_convex.mem_of_between _ hx hmn hn1 hmx) },
        { cases le_total m (n⁻¹) with hmni hnim,
          { exact hnnx (inv_inv n ▸ (@@is_convex.inv_mem _ hx $ @@is_convex.mem_of_between _ hx hmni hni1 hmx)) },
          { cases le_one_or_inv_le_one m with hm1 hmi1,
            { exact hmny (@@is_convex.mem_of_between _ hy hnim hm1 $ @@is_convex.inv_mem _ hy hny) },
            { exact hmny (inv_inv m ▸ (@@is_convex.inv_mem _ hy $ @@is_convex.mem_of_between _ hy (inv_le_inv_of_le hmn) hmi1 $ @@is_convex.inv_mem _ hy hny)) } } } },
      { cases le_one_or_inv_le_one m with hm1 hmi1,
        { exact hmny (@@is_convex.mem_of_between _ hy hnm hm1 hny) },
        { cases le_total n (m⁻¹) with hnni hmim,
          { exact hmny (inv_inv m ▸ (@@is_convex.inv_mem _ hy $ @@is_convex.mem_of_between _ hy hnni hmi1 hny)) },
          { cases le_one_or_inv_le_one n with hn1 hni1,
            { exact hnnx (@@is_convex.mem_of_between _ hx hmim hn1 $ @@is_convex.inv_mem _ hx hmx) },
            { exact hnnx (inv_inv n ▸ (@@is_convex.inv_mem _ hx $ @@is_convex.mem_of_between _ hx (inv_le_inv_of_le hnm) hni1 $ @@is_convex.inv_mem _ hx hmx)) } } } }
    end,
  .. subtype.partial_order is_convex }

def ker (f : α → β) (hf : linear_ordered_comm_group.is_hom f) : set α :=
{ x | f x = 1 }

theorem ker.is_convex (f : α → β) (hf : linear_ordered_comm_group.is_hom f) : is_convex (ker f hf) :=
{ one_mem := is_group_hom.map_one f,
  mul_mem := λ x y hx hy, show f (x * y) = 1, by dsimp [ker] at hx hy; rw
    [is_mul_hom.map_mul f, hx, hy, mul_one],
  inv_mem := λ x hx, show f x⁻¹ = 1, by dsimp [ker] at hx;
    rw [is_group_hom.map_inv f x, hx, one_inv],
  mem_of_between := λ x y hxy hy1 hx,
    le_antisymm (is_group_hom.map_one f ▸ linear_ordered_comm_group.is_hom.ord _ hy1)
      (hx ▸ linear_ordered_comm_group.is_hom.ord _ hxy) }

def height (α : Type) [linear_ordered_comm_group α] : cardinal :=
cardinal.mk {S : set α // is_proper_convex S}

namespace is_convex
open_locale classical

variables (S : set α) [is_convex S]

lemma mem_of_between' {a b c : α} (ha : a ∈ S) (hc : c ∈ S) (hab : a ≤ b) (hbc : b ≤ c) :
  b ∈ S :=
begin
  cases le_total b 1 with hb hb,
  { exact is_convex.mem_of_between hab hb ha },
  rw ← _root_.inv_inv b,
  apply is_convex.inv_mem,
  apply @is_convex.mem_of_between α _ S _ c⁻¹ _ _ _ (is_convex.inv_mem hc),
  { contrapose! hbc, have := mul_lt_right (b*c) hbc,
    rwa [inv_mul_cancel_left, mul_left_comm, mul_left_inv, mul_one] at this },
  { contrapose! hb, simpa using mul_lt_right b hb, }
end

lemma pow_mem {a : α} (ha : a ∈ S) (n : ℕ) : a^n ∈ S :=
begin
  induction n with n ih, { rw pow_zero, exact is_convex.one_mem S },
  rw pow_succ, exact is_convex.mul_mem ha ih,
end

lemma gpow_mem {a : α} (ha : a ∈ S) : ∀ (n : ℤ), a^n ∈ S
| (int.of_nat n) := by { rw [gpow_of_nat], exact is_convex.pow_mem S ha n }
| -[1+n] := by { apply is_convex.inv_mem, exact is_convex.pow_mem S ha _ }

end is_convex

namespace is_proper_convex
variables {x y z : α}

lemma exists_one_lt (S : set α) [h : is_proper_convex S] :
  ∃ a : α, a ∈ S ∧ 1 < a :=
begin
  choose x y hx hy hxy using h.exists_ne,
  rcases lt_trichotomy 1 x with Hx|rfl|Hx,
  { use [x, hx, Hx] },
  { rcases lt_trichotomy 1 y with Hy|rfl|Hy,
    { use [y, hy, Hy] },
    { contradiction },
    { refine ⟨y⁻¹, is_convex.inv_mem hy, _⟩,
      simpa using mul_lt_right y⁻¹ Hy, } },
  { refine ⟨x⁻¹, is_convex.inv_mem hx, _⟩,
    simpa using mul_lt_right x⁻¹ Hx, }
end

lemma exists_lt_one (S : set α) [h : is_proper_convex S] :
  ∃ a : α, a ∈ S ∧ a < 1 :=
begin
  rcases exists_one_lt S with ⟨x, H1, H2⟩,
  use [x⁻¹, is_convex.inv_mem H1],
  simpa using mul_lt_right x⁻¹ H2,
end

end is_proper_convex

end linear_ordered_structure

section
set_option old_structure_cmd true

/-- An ordered commutative monoid is a commutative monoid
  with a partial order such that mulition is an order embedding, i.e.
  `a * b ≤ a * c ↔ b ≤ c`.

  This name is needed because the `ordered_comm_monoid` that exists in mathlib
  is actually an additive monoid. TODO: refactor this. -/
class actual_ordered_comm_monoid (α : Type*) extends comm_monoid α, partial_order α :=
(mul_le_mul_left       : ∀ a b : α, a ≤ b → ∀ c : α, c * a ≤ c * b)
(lt_of_mul_lt_mul_left : ∀ a b c : α, a * b < a * c → b < c)
end

namespace actual_ordered_comm_monoid
variables {α : Type*} [actual_ordered_comm_monoid α] {a b c d : α}

lemma mul_le_mul_left' (h : a ≤ b) : c * a ≤ c * b :=
actual_ordered_comm_monoid.mul_le_mul_left a b h c

lemma mul_le_mul_right' (h : a ≤ b) : a * c ≤ b * c :=
mul_comm c a ▸ mul_comm c b ▸ mul_le_mul_left' h

lemma lt_of_mul_lt_mul_left' (a : α) : a * b < a * c → b < c :=
actual_ordered_comm_monoid.lt_of_mul_lt_mul_left a b c

lemma mul_le_mul' (h₁ : a ≤ b) (h₂ : c ≤ d) : a * c ≤ b * d :=
_root_.le_trans (mul_le_mul_right' h₁) (mul_le_mul_left' h₂)

lemma le_mul_of_nonneg_right' (h : b ≥ 1) : a ≤ a * b :=
have a * b ≥ a * 1, from mul_le_mul_left' h,
by rwa mul_one at this

lemma le_mul_of_nonneg_left' (h : b ≥ 1) : a ≤ b * a :=
have 1 * a ≤ b * a, from mul_le_mul_right' h,
by rwa one_mul at this

lemma lt_of_mul_lt_mul_right' (b : α) (h : a * b < c * b) : a < c :=
lt_of_mul_lt_mul_left' b
  (show b * a < b * c, begin rw [mul_comm b a, mul_comm b c], assumption end)

-- here we start using properties of one.
lemma le_mul_of_nonneg_of_le' (ha : 1 ≤ a) (hbc : b ≤ c) : b ≤ a * c :=
one_mul b ▸ mul_le_mul' ha hbc

lemma le_mul_of_le_of_nonneg' (hbc : b ≤ c) (ha : 1 ≤ a) : b ≤ c * a :=
mul_one b ▸ mul_le_mul' hbc ha

lemma mul_nonneg' (ha : 1 ≤ a) (hb : 1 ≤ b) : 1 ≤ a * b :=
le_mul_of_nonneg_of_le' ha hb

lemma mul_gt_one_of_gt_one_of_nonneg' (ha : 1 < a) (hb : 1 ≤ b) : 1 < a * b :=
lt_of_lt_of_le ha $ le_mul_of_nonneg_right' hb

lemma mul_gt_one' (ha : 1 < a) (hb : 1 < b) : 1 < a * b :=
mul_gt_one_of_gt_one_of_nonneg' ha $ le_of_lt hb

lemma mul_gt_one_of_nonneg_of_gt_one' (ha : 1 ≤ a) (hb : 1 < b) : 1 < a * b :=
lt_of_lt_of_le hb $ le_mul_of_nonneg_left' ha

lemma mul_nongt_one' (ha : a ≤ 1) (hb : b ≤ 1) : a * b ≤ 1 :=
one_mul (1:α) ▸ (mul_le_mul' ha hb)

lemma mul_le_of_nongt_one_of_le' (ha : a ≤ 1) (hbc : b ≤ c) : a * b ≤ c :=
one_mul c ▸ mul_le_mul' ha hbc

lemma mul_le_of_le_of_nongt_one' (hbc : b ≤ c) (ha : a ≤ 1) : b * a ≤ c :=
mul_one c ▸ mul_le_mul' hbc ha

lemma mul_neg_of_neg_of_nongt_one' (ha : a < 1) (hb : b ≤ 1) : a * b < 1 :=
lt_of_le_of_lt (mul_le_of_le_of_nongt_one' (le_refl _) hb) ha

lemma mul_neg_of_nongt_one_of_neg' (ha : a ≤ 1) (hb : b < 1) : a * b < 1 :=
lt_of_le_of_lt (mul_le_of_nongt_one_of_le' ha (le_refl _)) hb

lemma mul_neg' (ha : a < 1) (hb : b < 1) : a * b < 1 :=
mul_neg_of_nongt_one_of_neg' (le_of_lt ha) hb

lemma lt_mul_of_nonneg_of_lt' (ha : 1 ≤ a) (hbc : b < c) : b < a * c :=
lt_of_lt_of_le hbc $ le_mul_of_nonneg_left' ha

lemma lt_mul_of_lt_of_nonneg' (hbc : b < c) (ha : 1 ≤ a) : b < c * a :=
lt_of_lt_of_le hbc $ le_mul_of_nonneg_right' ha

lemma lt_mul_of_gt_one_of_lt' (ha : 1 < a) (hbc : b < c) : b < a * c :=
lt_mul_of_nonneg_of_lt' (le_of_lt ha) hbc

lemma lt_mul_of_lt_of_gt_one' (hbc : b < c) (ha : 1 < a) : b < c * a :=
lt_mul_of_lt_of_nonneg' hbc (le_of_lt ha)

lemma mul_lt_of_nongt_one_of_lt' (ha : a ≤ 1) (hbc : b < c) : a * b < c :=
lt_of_le_of_lt (mul_le_of_nongt_one_of_le' ha (le_refl _)) hbc

lemma mul_lt_of_lt_of_nongt_one' (hbc : b < c) (ha : a ≤ 1)  : b * a < c :=
lt_of_le_of_lt (mul_le_of_le_of_nongt_one' (le_refl _) ha) hbc

lemma mul_lt_of_neg_of_lt' (ha : a < 1) (hbc : b < c) : a * b < c :=
mul_lt_of_nongt_one_of_lt' (le_of_lt ha) hbc

lemma mul_lt_of_lt_of_neg' (hbc : b < c) (ha : a < 1) : b * a < c :=
mul_lt_of_lt_of_nongt_one' hbc (le_of_lt ha)

lemma mul_eq_one_iff' (ha : 1 ≤ a) (hb : 1 ≤ b) : a * b = 1 ↔ a = 1 ∧ b = 1 :=
iff.intro
  (assume hab : a * b = 1,
   have a ≤ 1, from hab ▸ le_mul_of_le_of_nonneg' (le_refl _) hb,
   have a = 1, from _root_.le_antisymm this ha,
   have b ≤ 1, from hab ▸ le_mul_of_nonneg_of_le' ha (le_refl _),
   have b = 1, from _root_.le_antisymm this hb,
   and.intro ‹a = 1› ‹b = 1›)
  (assume ⟨ha', hb'⟩, by rw [ha', hb', mul_one])

lemma mul_eq_one_iff_of_le_one' (ha : a ≤ 1) (hb : b ≤ 1) : a * b = 1 ↔ a = 1 ∧ b = 1 :=
begin
  refine iff.intro _ (assume ⟨ha', hb'⟩, by rw [ha', hb', mul_one]),
  intro hab,
  have : 1 ≤ a, { rw [← mul_one a, ← hab], exact mul_le_mul' (le_refl _) hb, },
  have : 1 ≤ b, { rw [← one_mul b, ← hab], exact mul_le_mul' ha (le_refl _), },
  split; apply _root_.le_antisymm; assumption
end

lemma square_gt_one {a : α} (h : 1 < a) : 1 < a*a :=
mul_gt_one' h h

lemma pow_le_one {a : α} (h : a ≤ 1) (n : ℕ) : a^n ≤ 1 :=
begin
  induction n with n ih, {rwa pow_zero},
  rw pow_succ,
  transitivity a,
  { simpa only [mul_one] using mul_le_mul_left' ih },
  { exact h }
end

lemma one_le_pow {a : α} (h : 1 ≤ a) (n : ℕ) : 1 ≤ a^n :=
begin
  induction n with n ih, {rwa pow_zero},
  rw pow_succ,
  transitivity a,
  { exact h },
  { simpa only [mul_one] using mul_le_mul_left' ih }
end

end actual_ordered_comm_monoid

variables {Γ₀ : Type*} [linear_ordered_comm_group Γ₀]

example (Γ₀ : Type*) [linear_ordered_comm_group Γ₀] : (1 : with_zero Γ₀) ≠ 0 := by simp

class linear_ordered_cancel_comm_monoid_with_zero (α : Type*)
  extends linear_ordered_comm_monoid α, zero_ne_one_class α :=
(zero_le : ∀ a : α, 0 ≤ a)
(mul_left_cancel {a b c : α} (h : a ≠ 0) : a * b = a * c → b = c)

namespace linear_ordered_cancel_comm_monoid_with_zero

-- variables {α : Type u} [linear_ordered_cancel_comm_monoid_with_zero α] {x: α}
-- when we need to make an API for this object

end linear_ordered_cancel_comm_monoid_with_zero

instance punit.linear_ordered_comm_group : linear_ordered_comm_group punit :=
{ mul_le_mul_left := λ a b h c, trivial,
  .. punit.decidable_linear_ordered_cancel_comm_monoid,
  .. punit.comm_group }

namespace with_zero

variables {α : Type u} {β : Type v}

variables [linear_ordered_comm_group α] [linear_ordered_comm_group β]

theorem map_mul (f : α → β) [is_group_hom f] (x y : with_zero α) :
map f (x * y) = option.map f x * option.map f y :=
begin
  cases hx : x; cases hy : y; try {refl},
  show some (f (val * val_1)) = some ((f val) * (f val_1)),
  apply option.some_inj.2,
  exact is_mul_hom.map_mul f val val_1
end

lemma mul_le_mul_left : ∀ a b : with_zero α, a ≤ b → ∀ c : with_zero α, c * a ≤ c * b
| (some x) (some y) hxy (some z) := begin
    rw with_bot.some_le_some at hxy,
    change @has_le.le (with_zero α) _ (some (z * x)) (some (z * y)),
    simp,
    exact linear_ordered_structure.mul_le_mul_left hxy z,
  end
| _        _        hxy 0        := by simp
| (some x) 0        hxy _        := by simp [le_antisymm hxy (le_of_lt (with_bot.bot_lt_some x))]
| 0        _        hxy (some _) := by simp

instance : linear_ordered_comm_monoid (with_zero α) :=
{ mul_le_mul_left := mul_le_mul_left,
  .. with_zero.comm_monoid,
  .. with_zero.linear_order }

theorem eq_zero_or_eq_zero_of_mul_eq_zero : ∀ x y : with_zero α, x * y = 0 → x = 0 ∨ y = 0
| (some x) (some y) hxy := false.elim $ option.no_confusion hxy
| 0        _        hxy := or.inl rfl
| _        0        hxy := or.inr rfl

@[simp] lemma mul_inv_self (a : with_zero α) : a * a⁻¹ ≤ 1 :=
begin
  cases a,
  { exact zero_le },
  { apply le_of_eq _,
    exact congr_arg some (mul_inv_self a) }
end

@[simp] lemma div_self (a : with_zero α) : a / a ≤ 1 := mul_inv_self a

@[move_cast] lemma div_coe' (a b : α) : (a*b⁻¹ : with_zero α) = a / b := rfl

lemma div_le_div (a b c d : with_zero α) (hb : b ≠ 0) (hd : d ≠ 0) :
  a / b ≤ c / d ↔ a * d ≤ c * b :=
begin
  rcases ne_zero_iff_exists.1 hb with ⟨b, rfl⟩,
  rcases ne_zero_iff_exists.1 hd with ⟨d, rfl⟩,
  with_zero_cases a c,
  exact linear_ordered_structure.div_le_div _ _ _ _
end

end with_zero

namespace with_zero
open linear_ordered_structure

lemma coe_of_gt {x y : with_zero Γ₀} (h : x < y) : ∃ γ : Γ₀, y = (γ : with_zero Γ₀) :=
by { with_zero_cases y }

lemma eq_coe_of_mul_eq_coe_right {x y : with_zero Γ₀} {γ : Γ₀} (h : x*y = γ) :
  ∃ γ' : Γ₀, y = γ' :=
begin
  rw ←with_zero.ne_zero_iff_exists,
  intro hy,
  rw [hy, mul_zero] at h,
  exact zero_ne_coe h
end

lemma eq_coe_of_mul_eq_coe_left {x y : with_zero Γ₀} {γ : Γ₀} (h : x*y = γ) :
  ∃ γ' : Γ₀, x = γ' :=
by rw mul_comm at h ; exact eq_coe_of_mul_eq_coe_right h

lemma eq_coe_of_mul_eq_coe {x y : with_zero Γ₀} {γ : Γ₀} (h : x*y = γ) :
  (∃ γ' : Γ₀, x = γ') ∧ ∃ γ'' : Γ₀, y = γ'' :=
⟨eq_coe_of_mul_eq_coe_left h, eq_coe_of_mul_eq_coe_right h⟩

lemma mul_inv_lt_of_lt_mul {x y z : with_zero Γ₀} (h : x < y*z) : x*z⁻¹ < y :=
begin
  cases coe_of_gt h with γ h',
  rcases eq_coe_of_mul_eq_coe h' with ⟨⟨γ', hy⟩, γ'', hz⟩,
  rw [hy, hz] at *,
  with_zero_cases x,
  exact mul_inv_lt_of_lt_mul h
end

lemma eq_inv_of_mul_eq_one_right {x y : with_zero Γ₀} (h : x*y = 1) : y = x⁻¹ :=
begin
  rcases eq_coe_of_mul_eq_coe h with ⟨⟨γ', hx⟩, γ'', hy⟩,
  rw [hx, hy] at *,
  norm_cast at *,
  rwa [mul_eq_one_iff_inv_eq, eq_comm] at h,
end

lemma eq_inv_of_mul_eq_one_left {x y : with_zero Γ₀} (h : x*y = 1) : x = y⁻¹ :=
begin
  rw mul_comm at h,
  exact eq_inv_of_mul_eq_one_right h,
end

instance : actual_ordered_comm_monoid (with_zero Γ₀) :=
{ mul_le_mul_left := λ x y x_le_y z,
    by { with_zero_cases x y z, exact linear_ordered_structure.mul_le_mul_left x_le_y z },
  lt_of_mul_lt_mul_left := λ x y z hlt,
    by { with_zero_cases x y z, exact linear_ordered_structure.lt_of_mul_lt_mul_left _ _ _ hlt },
  ..(by apply_instance : comm_monoid (with_zero Γ₀)),
  ..(by apply_instance : partial_order (with_zero Γ₀)),
}

variables {a b c d : with_zero Γ₀}

lemma mul_lt_mul : a < b → c < d → a*c < b*d :=
begin
  intros hab hcd,
  rcases coe_of_gt hcd with ⟨γ, rfl⟩,
  rcases coe_of_gt hab with ⟨γ', rfl⟩,
  with_zero_cases a c,
  exact linear_ordered_structure.mul_lt_mul hab hcd
end

lemma mul_lt_right (γ : Γ₀) (h : a < b) : a*γ < b*γ :=
begin
  rcases coe_of_gt h with ⟨γ', rfl⟩,
  with_zero_cases a,
  exact linear_ordered_structure.mul_lt_right _ h
end

lemma mul_lt_left (γ : Γ₀) (h : a < b) : (γ : with_zero Γ₀)*a < γ*b :=
begin
  repeat { rw mul_comm (γ : with_zero Γ₀) },
  exact mul_lt_right γ h
end

lemma le_of_le_mul_right (h : c ≠ 0) (hab : a * c ≤ b * c) : a ≤ b :=
begin
  replace hab := linear_ordered_structure.mul_le_mul_right hab c⁻¹,
  rwa [mul_assoc, mul_assoc, mul_right_inv _ h, mul_one, mul_one] at hab,
end

lemma le_of_le_mul_left (h : c ≠ 0) (hab : c * a ≤ c * b) :
  a ≤ b := by {rw [mul_comm, mul_comm c] at hab, exact with_zero.le_of_le_mul_right h hab}

lemma le_mul_inv_of_mul_le (h : c ≠ 0) (hab : a * c ≤ b) : a ≤ b * c⁻¹ :=
le_of_le_mul_right h (by rwa [mul_assoc, mul_left_inv _ h, mul_one])

lemma mul_inv_le_of_le_mul (h : c ≠ 0) (hab : a ≤ b * c) : a * c⁻¹ ≤ b :=
le_of_le_mul_right h (by rwa [mul_assoc, mul_left_inv _ h, mul_one])

end with_zero
