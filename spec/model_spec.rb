require File.expand_path("../spec_helper", __FILE__)

describe Ambry::Model do
  before { load_fixtures }
  after  { Ambry.adapters.clear }

  describe "#initialize" do

    it "can be called with no arguments" do
      assert Person.new
    end

    it "can be called with a block" do
      p = Person.new do |person|
        person.name = "joe"
      end
      assert_equal "joe", p.name
    end

    it "can be called with attributes and a block" do
      assert Person.new(:name => "foo") {|p| p.name = "bar"}
    end

    it "calls the block after setting sttributes" do
      person = Person.new(:name => "foo") {|p| p.name = "bar"}
      assert_equal "bar", person.name
    end

    it "can set attributes from a hash" do
      p = Person.new :name => "joe"
      assert_equal "joe", p.name
    end

    # This means your custom accessors will be invoked.
    it "invokes attr writers" do
      class Person
        def name=(val); @name = "doe"; end
      end
      p = Person.new(:name => "joe")
      class Person
        def name=(val); @name = val; end
      end

      assert_equal "doe", p.name
    end

    # Don't loop through params that potentially came from the Internet,
    # because we need to cast keys to Symbol, and that could leak memory.
    it "iterates over attribute names, not params" do
      assert_send([Person.attribute_names, :each])
      Person.new(:name => "joe")
    end
  end

  describe ".mapper" do
    it "lazy-loads mapper if it's not set" do
      Person.instance_variable_set :@mapper, nil
      assert Person.mapper
    end
  end

  describe ".use" do
    it "sets a new mapper for the specified adapter" do
      Person.instance_variable_set :@mapper, nil
      Person.use :main
      refute_nil Person.mapper
    end
  end

  describe ".create" do
    it "should add an instance to the database" do
      Person.create(:name => "Ted Healy", :email => "ted@3stooges.com")
      assert_equal "Ted Healy", Person.get("ted@3stooges.com").name
    end
  end


  describe "an attribute reader" do
    it "reads (first) from an instance var" do
      p = Person.first
      p.instance_variable_set :@name, "foo"
      p.instance_variable_set :@attributes, nil
      assert_equal "foo", p.name
    end

    # This also provides an easy way to check if a model instance has been
    # edited. However most of the time we don't need this because Ambry is
    # not intended for frequent writes.
    it "reads (second) from an attribute array" do
      p = Person.first
      assert_nil p.instance_variable_get :@name
      refute_nil p.instance_variable_get :@attributes
      refute_nil p.name
    end
  end

  describe "an attribute writer" do

    # The attributes hash is never written to, only replaced.
    it "only sets instance vars" do
      p = Person.first
      p.name = "foo"
      assert_equal "foo", p.instance_variable_get(:@name)
      refute_equal "foo", p.instance_variable_get(:@attributes)[:name]
    end
  end

  describe "#==" do
    it "returns true if the class and id are the same" do
      p = Person.first
      p2 = Person.new(:email => p.email)
      assert_equal p, p2
    end
  end

  describe "#to_hash" do
    it "returns a hash of the model's attributes" do
      p = Person.new(:name => "joe")
      assert_equal "joe", p.to_hash[:name]
    end
  end

  describe "#to_id" do
    it "returns the key attribute" do
      p = Person.first
      assert_equal p.email, p.to_id
    end
  end

  describe "#id_changed?" do
    it "should be true if the id changed" do
      p = Person.get("moe@3stooges.com")
      refute p.id_changed?
    end

    it "should be false if the id didn't change" do
      p = Person.get("moe@3stooges.com")
      p.email = "moe2@3stooges.com"
      assert p.id_changed?
    end
  end

  describe "#update" do
    it "updates the database" do
      p = Person.get("moe@3stooges.com")
      original = p.name
      p.update(:name => "Joe Schmoe")
      p = Person.get("moe@3stooges.com")
      refute_equal original, p.name
    end

    it "should allow updating the key" do
      count = Person.count
      p = Person.get("moe@3stooges.com")
      p.update(:email => "moe2@3stooges.com")
      assert_equal count, Person.count
    end

    it "should allow false as an update value (regression)" do
      p = Person.get("moe@3stooges.com")
      p.update(:name => false)
      assert_equal false, p.name
    end

  end

  describe "#save" do
    it "passes itself to Mapper#put" do
      p = Person.new(:name => "hello")
      assert_send([Person.mapper, :put, p])
      p.save
    end
  end
end
