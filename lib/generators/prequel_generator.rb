require 'rails/generators'
require 'rails/generators/actions'

# This generator adds an initializer and default empty database to your Rails
# application. It can be invoked on the command line like:
#
#     rails generate prequel
#
class PrequelGenerator < Rails::Generators::Base

  # Create the initializer and empty database.
  def create_files
    initializer("prequel.rb") do
      <<-EOI
require "prequel/adapters/yaml"
require "prequel/active_model"
Prequel::Adapters::YAML.new :file => Rails.root.join('db', 'prequel.yml')
      EOI
    end
    create_file("db/prequel.yml", '')
  end
end