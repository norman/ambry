# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

classes = [Prequel::Adapters::File, Prequel::Adapters::YAML]

classes.each do |klass|

  describe klass.to_s do

    before do
      Prequel.adapters = {}
      @path = File.expand_path("../file_adapter_test", __FILE__)
      @adapter = klass.new(:file => @path)
      @adapter.instance_variable_set :@db, {
        "Class" => {
          :a => :b,
          :unicode => "ü"
        }
      }
    end

    after do
      Prequel.adapters = {}
      FileUtils.rm_f @path
    end

    describe "#export_data" do
      it "should be a string" do
        assert_kind_of String, @adapter.export_data
      end
    end

    describe "#save_database" do
      it "should write the data to disk" do
        assert @adapter.save_database
        assert File.exists? @path
      end
    end

    describe "#load_database" do
      it "should load the data from the filesystem" do
        @adapter.save_database
        a2 = @adapter.class.new(:name => "a2", :file => @path)
        assert_equal @adapter.db["Class"][:unicode].bytes.entries, a2.db["Class"][:unicode].bytes.entries
      end
    end
  end
end
