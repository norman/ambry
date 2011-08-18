require File.expand_path("../spec_helper", __FILE__)

describe Ambry::Adapter do

  before { Ambry.adapters.clear }
  after  { Ambry.adapters.clear }

  describe "#initialize" do

    it "should register itself" do
      Ambry::Adapter.new :name => :an_adapter
      assert_equal :an_adapter,  Ambry.adapters.keys.first
    end

    it "should use a default name if none given" do
      assert_equal Ambry.default_adapter_name, Ambry::Adapter.new.name
    end

    it "should raise error if a duplicate name is used" do
      assert_raises Ambry::AmbryError do
        2.times {Ambry::Adapter.new(:name => :test_adapter)}
      end
    end

    it "should set an empty hash as the db" do
      assert_equal Hash.new, Ambry::Adapter.new.db
    end
  end

  describe "#db_for" do

    before { load_fixtures }

    it "should return a instance of Hash" do
      adapter = Ambry.adapters[:main]
      assert_kind_of Hash, adapter.db_for(Person)
    end
  end

  describe "stubbed io operations" do
    it "should return true" do
      adapter = Ambry::Adapter.new
      [:export_data, :import_data, :save_database].each do |method|
        assert adapter.send method
      end
    end
  end
end
