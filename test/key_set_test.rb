require File.expand_path("../test_helper", __FILE__)
require "ostruct"

class KeySet < Test::Unit::TestCase

  def setup
    @mapper = {
      "a" => {:name => "Larry"},
      "b" => {:name => "Moe"},
      "c" => {:name => "Curly"}
    }
    @ks = Prequel::KeySet.new(["a", "b"], @mapper)
    @ks2 = Prequel::KeySet.new(["b", "c"], @mapper)
  end

  test "concatenation" do
    assert_equal ["a", "b", "c"], (@ks + @ks2).keys
  end

  test "intersection" do
    assert_equal ["b"], (@ks & @ks2).keys
  end

  test "difference" do
    assert_equal ["a"], (@ks - @ks2).keys
  end

  test "union" do
    assert_equal ["a", "b", "c"], (@ks | @ks2).keys
  end

  test "each should yield to the value looked up by the mapper" do
    @ks.each {|k| assert_equal Hash, k.class}
  end

end
