require 'rails/generators'

class PrequelGenerator < Rails::Generators::Base
  initializer("prequel.rb") do
    'Prequel::Adapters::YAML.new(Rails.root.join("db", "prequel.yaml")'
  end
end