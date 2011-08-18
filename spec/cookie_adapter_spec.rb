require File.expand_path("../spec_helper", __FILE__)
require "ambry/adapters/cookie"

class User
  extend Ambry::Model
  field :email, :name
end

module CookieAdapterSpecHelpers
  def secret
    "ssssshh... this is a secret!"
  end

  def sample_data
    # hash = {"User" => {valid_user[:email] => valid_user}}
    # p ActiveSupport::MessageVerifier.new(secret).generate(Zlib::Deflate.deflate(Marshal.dump(hash)))
    "BAgiTnicY+GoZvNU4gwtTi1is2JzDQHxhLPyUx2KkzNy81P1kvNz2awZQqrZrTjzEnNTPZX4" +
    "vfJTFYLBkiAJK67U3MTMHKyaAJGaGlk=--08913fe1c677e4bb0dd34ef90fb22f9027e587f4"
  end

  def valid_user
    @valid_user ||= {:name => "Joe Schmoe", :email => "joe@schmoe.com"}
  end

  def load_fixtures
    Ambry.adapters.clear
    @adapter = Ambry::Adapters::Cookie.new \
      :name   => :cookie,
      :secret => secret
    User.use :cookie, :sync => true
  end
end

describe Ambry::Adapters::Cookie do

  include CookieAdapterSpecHelpers

  before { load_fixtures }
  after  { Ambry.adapters.clear }

  describe Ambry::Adapters::Cookie do

    describe "#initialize" do
      it "should decode signed data if given" do
        adapter = Ambry::Adapters::Cookie.new \
          :secret => secret,
          :data   => sample_data
        assert_kind_of Hash, adapter.db["User"]
        assert_equal "joe@schmoe.com", adapter.db["User"].keys.first
      end

      it "should load properly with nil or blank data" do
        [nil, ""].each_with_index do |arg, index|
          adapter = Ambry::Adapters::Cookie.new \
            :secret => secret,
            :data   => arg,
            :name   => :"main_#{index}"
          assert_instance_of Hash, adapter.db
        end
      end
    end

    describe "#export_data" do
      it "should encode and sign the database" do
        User.create \
          :name  => Faker::Name.name,
          :email => Faker::Internet.email
        refute_nil @adapter.export_data
      end
    end

    describe "#save_database" do
      it "should raise a AmbryError if signed data exceeds max data length" do
        Ambry::Adapters::Cookie.stubs(:max_data_length).returns(1)
        assert_raises Ambry::AmbryError do
          User.create valid_user
        end
      end
    end
  end
end