require 'rails/generators'
require 'rails/generators/actions'

# This generator adds an initializer and default empty database to your Rails
# application. It can be invoked on the command line like:
#
#     rails generate norman
#
class NormanGenerator < Rails::Generators::Base

  # Create the initializer and empty database.
  def create_files
    initializer("norman.rb") do
      <<-EOI
require "norman/adapters/yaml"
require "norman/active_model"
Norman::Adapters::YAML.new :file => Rails.root.join('db', 'norman.yml')
      EOI
    end
    create_file("db/norman.yml", '')
  end
end