require 'rails/generators'
require 'rails/generators/actions'

class PrequelGenerator < Rails::Generators::Base

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