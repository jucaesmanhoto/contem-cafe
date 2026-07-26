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

  test "discount percentage grows 2.5 points per level of depth" do
    root = Referral.create!(name: "Root", phone: "111")
    child = Referral.create!(name: "Child", phone: "222", referrer: root)
    grandchild = Referral.create!(name: "Grandchild", phone: "333", referrer: child)

    assert_equal 0.0, root.discount_percentage
    assert_equal 2.5, child.discount_percentage
    assert_equal 5.0, grandchild.discount_percentage
  end

  test "discount percentage is capped at 20%" do
    referral = Referral.new(depth: 50)
    assert_equal 20.0, referral.discount_percentage
  end
end
