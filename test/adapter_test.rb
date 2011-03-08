require File.expand_path("../test_helper", __FILE__)

class AdapterTest < Test::Unit::TestCase

  def setup
    Prequel.adapters = {}
  end

  def teardown
    Prequel.adapters = {}
  end

  test "should register adapter upon creation" do
    Prequel.expects(:register_adapter)
    assert Prequel::Adapter.new(:name => "test_adapter")
  end

  test "should assign a default name to itself if none given" do
    assert_equal Prequel.default_adapter_name, Prequel::Adapter.new.name
  end

  test "should raise error if a duplicate name is used" do
    Prequel.expects(:adapters).returns({:test_adapter => true})
    assert_raise Prequel::PrequelError do
      Prequel::Adapter.new(:name => :test_adapter)
    end
  end

  test "should load and set an empty hash as the db on initialization" do
    assert_equal Hash.new, Prequel::Adapter.new.db
  end

  test "should get a key set with all keys for a given class" do
    adapter = Prequel::Adapter.new
    adapter.instance_variable_set :@db, {"Class" => {:a => :b}}
    mapper = Struct.new(:klass).new("Class")
    assert_equal :a, adapter.key_set(mapper).keys.first
  end

  test "stubbed io operations should all return true" do
    adapter = Prequel::Adapter.new
    [:export_data, :import_data, :save_database].each do |method|
      assert adapter.send method
    end
  end
end
