require File.expand_path("../spec_helper", __FILE__)

describe Norman::Adapter do

  before { Norman.adapters.clear }
  after  { Norman.adapters.clear }

  describe "#initialize" do

    it "should register itself" do
      Norman::Adapter.new :name => :an_adapter
      assert_equal :an_adapter,  Norman.adapters.keys.first
    end

    it "should use a default name if none given" do
      assert_equal Norman.default_adapter_name, Norman::Adapter.new.name
    end

    it "should raise error if a duplicate name is used" do
      assert_raises Norman::NormanError do
        2.times {Norman::Adapter.new(:name => :test_adapter)}
      end
    end

    it "should set an empty hash as the db" do
      assert_equal Hash.new, Norman::Adapter.new.db
    end
  end

  describe "#db_for" do

    before { load_fixtures }

    it "should return a instance of Hash" do
      adapter = Norman.adapters[:main]
      assert_kind_of Hash, adapter.db_for(Person)
    end
  end

  describe "stubbed io operations" do
    it "should return true" do
      adapter = Norman::Adapter.new
      [:export_data, :import_data, :save_database].each do |method|
        assert adapter.send method
      end
    end
  end
end
