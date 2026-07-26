require "test_helper"

class ReferralDiscountTest < ActiveSupport::TestCase
  test "discount percentage grows per level of depth from the chain's own initial discount" do
    root = Referral.create!(name: "Root", phone: "111")
    child = Referral.create!(name: "Child", phone: "222", referrer: root)
    grandchild = Referral.create!(name: "Grandchild", phone: "333", referrer: child)

    initial = Referral::DEFAULT_INITIAL_DISCOUNT_PERCENTAGE
    rate = Referral::DEFAULT_DISCOUNT_PERCENTAGE_PER_LEVEL

    assert_equal initial, root.discount_percentage
    assert_equal initial + rate, child.discount_percentage
    assert_equal initial + (rate * 2), grandchild.discount_percentage
  end

  test "discount percentage is capped at 20%" do
    referral = Referral.new(depth: 50, initial_discount_percentage: 0, discount_percentage_per_level: 2.5,
                            max_discount_percentage: 20.0)
    assert_equal 20.0, referral.discount_percentage
  end

  test "root created without explicit discount settings gets the hardcoded defaults" do
    root = Referral.create!(name: "Root", phone: "111")
    assert_equal Referral::DEFAULT_INITIAL_DISCOUNT_PERCENTAGE, root.initial_discount_percentage.to_f
    assert_equal 2.5, root.discount_percentage_per_level.to_f
    assert_equal 20.0, root.max_discount_percentage.to_f
  end

  test "root created with explicit custom discount settings keeps them" do
    root = Referral.create!(name: "Root", phone: "111", initial_discount_percentage: 5.0,
                            discount_percentage_per_level: 1.0, max_discount_percentage: 10.0)
    assert_equal 5.0, root.initial_discount_percentage.to_f
    assert_equal 1.0, root.discount_percentage_per_level.to_f
    assert_equal 10.0, root.max_discount_percentage.to_f
  end

  test "child with no explicit discount settings inherits all three from its referrer" do
    root = Referral.create!(name: "Root", phone: "111", initial_discount_percentage: 5.0,
                            discount_percentage_per_level: 1.0, max_discount_percentage: 10.0)
    child = Referral.create!(name: "Child", phone: "222", referrer: root)

    assert_equal root.initial_discount_percentage, child.initial_discount_percentage
    assert_equal root.discount_percentage_per_level, child.discount_percentage_per_level
    assert_equal root.max_discount_percentage, child.max_discount_percentage
  end

  test "child with explicit discount settings keeps its own instead of inheriting" do
    root = Referral.create!(name: "Root", phone: "111", initial_discount_percentage: 5.0,
                            discount_percentage_per_level: 1.0, max_discount_percentage: 10.0)
    child = Referral.create!(name: "Child", phone: "222", referrer: root, initial_discount_percentage: 0.0,
                             discount_percentage_per_level: 3.0, max_discount_percentage: 30.0)

    assert_equal 0.0, child.initial_discount_percentage.to_f
    assert_equal 3.0, child.discount_percentage_per_level.to_f
    assert_equal 30.0, child.max_discount_percentage.to_f
  end

  test "discount_percentage combines the record's own settings with its own depth, capped at its own max" do
    referral = Referral.new(depth: 4, initial_discount_percentage: 5.0, discount_percentage_per_level: 10.0,
                            max_discount_percentage: 30.0)
    assert_equal 30.0, referral.discount_percentage

    referral.depth = 1
    assert_equal 15.0, referral.discount_percentage
  end

  test "discount settings reject negative values" do
    referral = Referral.new(name: "Bad", phone: "111", initial_discount_percentage: -1)
    assert_not referral.valid?
    assert_includes referral.errors[:initial_discount_percentage], "precisa ser maior ou igual a 0"
  end
end
