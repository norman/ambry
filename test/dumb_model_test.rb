require File.expand_path("../test_helper", __FILE__)
require "fileutils"

class DumbModelTest < Test::Unit::TestCase

  def setup
    mapper = DumbModel::Mapper.new(File.expand_path("../dumb.bin", __FILE__))
    Person.mapper = mapper
    Animal.mapper = mapper
    person = Person.create(:name => "Moe Howard",   :email => "moe@3stooges.com")
    person = Person.create(:name => "Shemp Howard", :email => "shemp@3stooges.com")
    person = Person.create(:name => "Curly Howard", :email => "curly@3stooges.com")
    person = Person.create(:name => "Larry Fine",   :email => "larry@3stooges.com")
    animal = Animal.create(:species => "Canis Familaris", :common_name => "Dog")
    Person.mapper.save_database
  end
  
  def teardown
    FileUtils.rm(File.expand_path("../dumb.bin", __FILE__))
  end
  
  test "should count people" do
    assert_equal 4, Person.count
  end
  
  test "should get person by key" do
    assert_equal "moe@3stooges.com", Person.get("Moe Howard").email
  end
  

end