# encoding: utf-8
require "fileutils"
require File.expand_path("../test_helper", __FILE__)
require "prequel/adapters/yaml"

class FileAdapterTest < Test::Unit::TestCase

  def setup
    Prequel.adapters = {}
    @adapter = adapter_class.new(:file => path)
    @adapter.instance_variable_set :@db, hash
  end

  def teardown
    Prequel.adapters = {}
  end

  def hash
    {"Class" => {:a => :b, :unicode => "ü"}}
  end

  def path
    File.expand_path("../file_adapter_test.bin", __FILE__)
  end

  def adapter_class
    Prequel::Adapters::File
  end

  def teardown
    FileUtils.rm_f path
  end

  test "should export data to string" do
    assert_not_nil @adapter.export_data
  end

  test "should write data to file system" do
    assert @adapter.save_database
    assert File.exists? path
  end

  test "should load data from file system" do
    @adapter.save_database
    a2 = @adapter.class.new(:name => "a2", :file => path)
    assert_equal @adapter.db["Class"][:unicode].bytes.entries, a2.db["Class"][:unicode].bytes.entries
  end
end

class YAMLAdapterTest < FileAdapterTest

  def path
    File.expand_path("../file_adapter_test.yml", __FILE__)
  end

  def adapter_class
    Prequel::Adapters::YAML
  end
end
