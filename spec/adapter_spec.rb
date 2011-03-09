require File.expand_path("../spec_helper", __FILE__)

describe Prequel::Adapter do

  before { Prequel.adapters.clear }
  after  { Prequel.adapters.clear }

  describe "#initialize" do

    it "should register itself" do
      Prequel::Adapter.new :name => :an_adapter
      assert_equal :an_adapter,  Prequel.adapters.keys.first
    end

    it "should use a default name if none given" do
      assert_equal Prequel.default_adapter_name, Prequel::Adapter.new.name
    end

    it "should raise error if a duplicate name is used" do
      assert_raises Prequel::PrequelError do
        2.times {Prequel::Adapter.new(:name => :test_adapter)}
      end
    end

    it "should set an empty hash as the db" do
      assert_equal Hash.new, Prequel::Adapter.new.db
    end
  end

  describe "#key_set" do

    before { load_fixtures }

    it "should return a instance of key_set" do
      adapter = Prequel.adapters[:main]
      assert_kind_of Prequel::KeySet, adapter.key_set(Person.mapper)
    end
  end

  describe "stubbed io operations" do
    it "should return true" do
      adapter = Prequel::Adapter.new
      [:export_data, :import_data, :save_database].each do |method|
        assert adapter.send method
      end
    end
  end
end
