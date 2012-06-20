require 'rails/generators'
require 'rails/generators/actions'

# This generator adds an initializer and default empty database to your Rails
# application. It can be invoked on the command line like:
#
#     rails generate ambry
#
class AmbryGenerator < Rails::Generators::Base

  # Create the initializer and empty database.
  def create_files
    initializer("ambry.rb") do
      <<-EOI
require "ambry/adapters/yaml"
require "ambry/active_model"
Ambry.remove_adapter :main
Ambry::Adapters::YAML.new :file => Rails.root.join('db', 'ambry.yml')
      EOI
    end
    create_file("db/ambry.yml", '')
  end
end