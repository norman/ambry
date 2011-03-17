require File.expand_path("../spec_helper", __FILE__)
require "prequel/active_model"

class Book
  extend Prequel::Model
  extend Prequel::ActiveModel
  field :slug, :title, :author
  validates_presence_of :slug
  validates_uniqueness_of :slug, :title
  before_save :save_callback_fired
  before_destroy :destroy_callback_fired

  def save_callback_fired
    @save_callback_fired = true
  end

  def destroy_callback_fired
    @destroy_callback_fired = true
  end
end

module ActiveModuleSupportSpecHelper
  def valid_book
    {:slug => "war-and-peace", :title => "War and Peace", :author => "Leo Tolstoy"}
  end

  def load_fixtures
    Prequel.adapters.clear
    Prequel::Adapter.new :name => :main
    Book.use :main
    @model = Book.create! valid_book
  end
end

describe Prequel::ActiveModel do

  before { load_fixtures }

  include ActiveModuleSupportSpecHelper
  include ActiveModel::Lint::Tests

  describe "#keys" do
    it "should return an array of attribute names" do
      assert @model.keys.include?(:slug), "@model.keys should include :slug"
    end
  end

  describe "#model_name" do
    it "should return an ActiveModel::Name" do
      assert_kind_of ::ActiveModel::Name, @model.model_name
    end
  end

  describe "#save!" do
    it "should raise an exception if the model is not valid" do
      assert_raises Prequel::PrequelError do
        Book.new.save!
      end
    end
  end

  describe "#to_json" do
    it "should serialize" do
      json = @model.to_json
      refute_nil @model.to_json
      assert_match /"author":"Leo Tolstoy"/, json
    end
  end

  describe "#to_xml" do
    it "should serialize to XML" do
      xml = @model.to_xml
      refute_nil xml
      assert_match /<author>Leo Tolstoy<\/author>/, xml
    end
  end

  describe "#valid?" do
    it "should do validation" do
      book = Book.new
      refute book.valid?
      book.slug = "hello-world"
      assert book.valid?
    end
  end

  describe "callbacks" do
    it "should fire save callbacks" do
      book = Book.new valid_book
      book.save
      assert book.instance_variable_defined? :@save_callback_fired
    end

    it "should fire destroy callbacks" do
      @model.destroy
      assert @model.instance_variable_defined? :@destroy_callback_fired
    end

  end

  describe ".validates_uniqueness_of" do
    it "should validate on id attribute" do
      @book = Book.new valid_book.merge(:title => "War and Peace II")
      refute @book.valid?
      @book.slug = "war-and-peace-2"
      assert @book.valid?
    end

    it "should validate on non-id attribute" do
      @book = Book.new valid_book.merge(:slug => "war-and-peace-2")
      refute @book.valid?
      @book.title = "War and Peace II"
      assert @book.valid?
    end
  end
end