require File.expand_path("../test_helper", __FILE__)

class MapperTest < Test::Unit::TestCase

  MockAdapter = Struct.new(:db)

  def setup
    @adapter = MockAdapter.new({})
    Prequel.adapters = {Prequel.default_adapter_name => @adapter}
    @mapper = Prequel::Mapper.new("Class")
  end

  def teardown
    Prequel.adapters.clear
  end

  test "should set default adapter name if unspecified" do
    assert_equal :main, @mapper.adapter_name
  end

  test "should get a hash corresponding to the mapped class" do
    assert_equal @adapter.db["Class"], @mapper.hash
  end

  test "should get entry by key" do
    entry = @adapter.db["Class"]["hello-world"] = {:a => :b}
    assert_equal entry, @mapper["hello-world"]
  end

  test "should invoke to_hash and freeze on entry before adding" do
    entry = {:a => :b}
    entry.expects(:to_hash).returns(entry)
    entry.expects(:freeze).returns(entry)
    assert @mapper["hello-world"] = entry
  end

  test "should delegate key_set to adapter" do
    @adapter.expects(:key_set).returns(true)
    assert @mapper.key_set
  end
end
