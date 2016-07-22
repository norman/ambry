require File.expand_path("../spec_helper", __FILE__)

MockAdapter = Struct.new(:db)

class Value
  extend Ambry::Model
  field :a
end

describe Ambry::Mapper do

  describe "#initialize" do

    before do
      Ambry.adapters.clear
      @adapter = Ambry::Adapter.new
    end

    after do
      Ambry.adapters.clear
    end

    it "should set default adapter name if unspecified" do
      mapper = Ambry::Mapper.new "Class"
      assert_equal Ambry.default_adapter_name, mapper.adapter_name
    end

    it "should set adapter name if unspecified" do
      Ambry::Adapter.new :name => :hello
      mapper = Ambry::Mapper.new "Class", :hello
      assert_equal :hello, mapper.adapter_name
    end
  end

  describe "hash operations" do

    before { load_fixtures }
    after  { Ambry.adapters.clear }

    describe "#hash" do
      it "should get a hash corresponding to the mapped class" do
        assert_equal Person.mapper.adapter.db["Person"], Person.mapper.hash
      end
    end

    describe "#[]" do
      it "should return an attributes hash" do
        assert_kind_of Hash, Person.mapper["moe@3stooges.com"]
      end

      it "should raise NotFoundError if key doesn't exist" do
        assert_raises Ambry::NotFoundError do
          Person.mapper["BADKEY"]
        end
      end
    end

    describe "#[]=" do
      it "should return the value" do
        value = Person.mapper[:a] = Value.new(:a => "b")
        assert_equal "b", value.a
      end

      it "should set value#to_hash as value for key" do
        Person.mapper[:bogus] = Value.new(:a => "b")
        assert_equal "b", Person.mapper[:bogus][:a]
      end

      it "should freeze the value" do
        Person.mapper[:bogus] = Value.new(:a => "b")
        assert Person.mapper[:bogus].frozen?
      end
    end

    describe "#get" do
      it "should return a model instance" do
        assert_kind_of Person, Person.mapper.get("moe@3stooges.com")
      end
    end

    describe "#key_set" do
      it "should return a Ambry::KeySet with all keys" do
        ks = Person.mapper.key_set
        assert_kind_of Ambry::AbstractKeySet, ks
        assert_equal Person.count, ks.count
      end
    end

    describe "#put" do
      it "should add to hash and return the value" do
        instance = Value.new(:a => "b")
        assert value = Value.mapper.put(instance)
        assert_equal instance, value
      end
    end
  end
end
