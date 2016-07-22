require File.expand_path("../lib/ambry/version", __FILE__)

Gem::Specification.new do |s|
  s.authors           = "Norman Clarke"
  s.email             = "norman@njclarke.com"
  s.files             = `git ls-files`.split("\n").reject {|f| f =~ /^\./}
  s.homepage          = "http://github.com/norman/ambry"
  s.name              = "ambry"
  s.platform          = Gem::Platform::RUBY
  s.rubyforge_project = "[none]"
  s.summary           = "An ActiveModel-compatible ORM-like library for storing model instances in an in-memory Hash."
  s.test_files        = Dir.glob "test/**/*_test.rb"
  s.version           = Ambry::Version::STRING
  s.description       = <<-EOD
    Ambry is not an ORM, man! It's a database and ORM replacement for (mostly)
    static models and small datasets. It provides ActiveModel compatibility, and
    flexible searching and storage.
  EOD
  s.add_development_dependency "ffaker"
  s.add_development_dependency "minitest", "~> 5.1"
  s.add_development_dependency "activesupport", "~> 5.0"
  s.add_development_dependency "activemodel", "~> 5.0"
  s.add_development_dependency "rake"
end
