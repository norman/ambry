require File.expand_path("../spec_helper", __FILE__)

MockAdapter = Struct.new(:db)

describe Prequel::Mapper do

  describe "#initialize" do

    before do
      Prequel.adapters.clear
      @adapter = Prequel::Adapter.new
    end

    after do
      Prequel.adapters.clear
    end

    it "should set default adapter name if unspecified" do
      mapper = Prequel::Mapper.new "Class"
      assert_equal Prequel.default_adapter_name, mapper.adapter_name
    end

    it "should set adapter name if unspecified" do
      Prequel::Adapter.new :name => :hello
      mapper = Prequel::Mapper.new "Class", :hello
      assert_equal :hello, mapper.adapter_name
    end
  end

  describe "hash operations" do

    before { load_fixtures }
    after  { Prequel.adapters.clear }

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
        assert_raises Prequel::NotFoundError do
          Person.mapper["BADKEY"]
        end
      end
    end

    describe "#[]=" do
      it "should return the value" do
        value = Person.mapper[:bogus] = {:a => "b"}
        assert_equal "b", value[:a]
      end

      it "should set value#to_hash as value for key" do
        value = Person.mapper[:bogus] = {:a => "b"}
        assert_equal "b", Person.mapper[:bogus][:a]
      end

      it "should freeze the value" do
        value = Person.mapper[:bogus] = {:a => "b"}
        assert Person.mapper[:bogus].frozen?
      end
    end

    describe "#get" do
      it "should return a model instance" do
        assert_kind_of Person, Person.mapper.get("moe@3stooges.com")
      end
    end

    describe "#key_set" do
      it "should return a Prequel::KeySet with all keys" do
        ks = Person.mapper.key_set
        assert_kind_of Prequel::KeySet, ks
        assert_equal Person.count, ks.count
      end
    end

    describe "#put" do
      it "should invoke #to_id and add to hash" do
        instance = Object.new
        instance.expects(:to_id).returns(:a)
        instance.expects(:to_hash).returns(:b => "c")
        assert val = Person.mapper.put(instance)
        refute Person.mapper[:a].nil?
      end
    end
  end
end
