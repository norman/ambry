require File.expand_path("../test_helper", __FILE__)
require "prequel/adapters/yaml"

class Person
  extend Prequel::Model
  attr_accessor :email, :name

  def self.stooges
    with_index("stooges") do
      find {|p| p[:email] =~ /3stooges.com/}
    end
  end

  def self.non_howards
    with_index("non_howards") do
      find {|p| p[:name] !~ /Howard/}
    end
  end
end

class ModelTest < Test::Unit::TestCase

  def setup
    Prequel.adapters.clear
    Prequel::Adapters::YAML.new \
      :name => :main,
      :file => File.expand_path("../fixtures.yml", __FILE__)
    Person.use :main
  end

  test "`get` should return a model instance" do
    assert_equal "Moe Howard", Person.get("moe@3stooges.com").name
  end

  test "`brackets` should return a hash" do
    assert_equal "Moe Howard", Person["moe@3stooges.com"][:name]
  end

  test "`create` should store a model instance in the database" do
    assert Person.create \
      :name  => "Curly Joe DeRita",
      :email => "curlyjoe@3stooges.com"
  end

  test "`delete` should remove a model instance in the database" do
    assert_equal Person["moe@3stooges.com"], Person.delete("moe@3stooges.com")
    assert_raise Prequel::NotFoundError do
      Person["moe@3stooges.com"]
    end
  end

  test "`find` should return an instance of key set" do
    assert_equal Prequel::KeySet, Person.find.class
  end

  test "finds should proxy block args" do
    result = Person.get "moe@3stooges.com"
    assert_equal result, Person.first {|p| p[:name]  == "Moe Howard"}
    assert_equal result, Person.first {|p| p["name"] == "Moe Howard"}
    assert_equal result, Person.first {|p| p.name    == "Moe Howard"}
  end

  test "`find_by_key` finds only by key" do
    result = Person.get "moe@3stooges.com"
    assert_equal result, Person.find_by_key {|p| p == "moe@3stooges.com"}.first
  end

  test "should raise error when accessing non existant method by proxy" do
    assert_raise NoMethodError do
      Person.find {|p| p.foobar == "Moe Howard"}
    end
  end

  test "should sort entries" do
    assert_equal "Curly Howard", Person.all.sort {|a, b| a[:name] <=> b[:name]}.first.name
    assert_equal "Shemp Howard", Person.all.sort {|a, b| b[:name] <=> a[:name]}.first.name
  end

  test "`count` should count model instances" do
    assert_equal 4, Person.count
  end

  test "`count` should count model instances with a block" do
    assert_equal 1, Person.count {|p| p.name == "Moe Howard"}
  end

  test "`limit` should limit entries" do
    assert_equal 2, Person.find.limit(2).count
  end

  test "`should` when chaining nonexistant filter" do
    assert_raise NoMethodError do
      Person.non_howards.smurf
    end
  end

  test "should raise NotFoundError when not found" do
    assert_raise Prequel::NotFoundError do
      Person.first {|p| p.email == "fdfdfds"}
    end
  end
  
  test "should get instances" do
    assert_equal 4, Person.all.instances.size 
  end

  ## Note: These are key set specific and should go there.

  test "`each` should iterate with a hash" do
    Person.all.each {|k| assert_equal Hash, k.class}
  end

  test "`each_key` should iterate with a string" do
    Person.all.each_key {|k| assert_equal String, k.class}
  end

  test "`each_instance` should iterate with a model instance" do
    Person.all.each_instance {|k| assert_equal Person, k.class}
  end

  test "should use indexes" do
    Person.create \
      :name  => "Ted Healy",
      :email => "ted@healy.com"

    assert Person.stooges.keys.include?("moe@3stooges.com")
    assert Person.stooges.keys.include?("larry@3stooges.com")

    assert !Person.non_howards.keys.include?("moe@3stooges.com")
    assert Person.non_howards.keys.include?("ted@healy.com")
    assert Person.non_howards.keys.include?("larry@3stooges.com")

    assert !Person.stooges.non_howards.keys.include?("moe@3stooges.com")
    assert !Person.stooges.non_howards.keys.include?("ted@healy.com")
    assert Person.stooges.non_howards.keys.include?("larry@3stooges.com")
  end
end
