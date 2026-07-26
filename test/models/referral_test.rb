require "test_helper"

class ReferralTest < ActiveSupport::TestCase
  test "generates a unique token on create" do
    referral = Referral.create!(name: "Maria", phone: "11999999999")
    assert referral.token.present?
  end

  test "is invalid without name or phone" do
    referral = Referral.new
    assert_not referral.valid?
    assert_includes referral.errors[:name], "não pode ficar em branco"
    assert_includes referral.errors[:phone], "não pode ficar em branco"
  end

  test "does not allow duplicate tokens at the validation level" do
    root = Referral.create!(name: "Root", phone: "111")
    dup = Referral.new(name: "Dup", phone: "222", token: root.token)
    assert_not dup.valid?
    assert_includes dup.errors[:token], "já está em uso"
  end

  test "root referral has depth 0 and nil referrer" do
    root = Referral.create!(name: "Root", phone: "111")
    assert_equal 0, root.depth
    assert root.root?
  end

  test "child referral computes depth from referrer" do
    root = Referral.create!(name: "Root", phone: "111")
    child = Referral.create!(name: "Child", phone: "222", referrer: root)
    assert_equal 1, child.depth
  end

  test "ancestors walks the chain back to root, excluding self" do
    root = Referral.create!(name: "Root", phone: "111")
    mid = Referral.create!(name: "Mid", phone: "222", referrer: root)
    leaf = Referral.create!(name: "Leaf", phone: "333", referrer: mid)

    assert_equal [mid, root], leaf.ancestors
  end

  test "chain includes self and runs from root to self" do
    root = Referral.create!(name: "Root", phone: "111")
    mid = Referral.create!(name: "Mid", phone: "222", referrer: root)
    leaf = Referral.create!(name: "Leaf", phone: "333", referrer: mid)

    assert_equal [root, mid, leaf], leaf.chain
  end

  test "destroying a referrer nullifies referrer_id on children instead of destroying them" do
    root = Referral.create!(name: "Root", phone: "111")
    child = Referral.create!(name: "Child", phone: "222", referrer: root)

    root.destroy!
    assert_nil child.reload.referrer_id
  end

  test "a phone already used by the referrer cannot join under them" do
    root = Referral.create!(name: "Root", phone: "11999999999")
    dup = Referral.new(name: "Self invite", phone: "11999999999", referrer: root)

    assert_not dup.valid?
    assert_includes dup.errors[:base], "Você já faz parte desta indicação e não pode se indicar"
  end

  test "a phone already used further up the chain cannot join further down" do
    root = Referral.create!(name: "Root", phone: "11999999999")
    mid = Referral.create!(name: "Mid", phone: "11888888888", referrer: root)
    dup = Referral.new(name: "Self invite", phone: "11999999999", referrer: mid)

    assert_not dup.valid?
    assert_includes dup.errors[:base], "Você já faz parte desta indicação e não pode se indicar"
  end

  test "phone comparison ignores formatting when checking for self-invitation" do
    root = Referral.create!(name: "Root", phone: "(11) 99999-9999")
    dup = Referral.new(name: "Self invite", phone: "11999999999", referrer: root)

    assert_not dup.valid?
    assert_includes dup.errors[:base], "Você já faz parte desta indicação e não pode se indicar"
  end

  test "a phone not present anywhere in the chain can join normally" do
    root = Referral.create!(name: "Root", phone: "11999999999")
    child = Referral.new(name: "Child", phone: "11888888888", referrer: root)

    assert child.valid?
  end

  test "a root does not need to check for self-invitation" do
    referral = Referral.new(name: "Root", phone: "11999999999")
    assert referral.valid?
  end
end
