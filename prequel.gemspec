require File.expand_path("../lib/prequel/version", __FILE__)

Gem::Specification.new do |s|
  s.authors           = "Norman Clarke"
  s.email             = "norman@njclarke.com"
  s.files             = `git ls-files`.split("\n").reject {|f| f =~ /^\./}
  s.has_rdoc          = true
  s.homepage          = "http://github.com/norman/prequel"
  s.name              = "prequel"
  s.platform          = Gem::Platform::RUBY
  s.rubyforge_project = "[none]"
  s.summary           = "An ActiveModel-compatible ORM-like library for storing model instances in an in-memory Hash."
  s.test_files        = Dir.glob "test/**/*_test.rb"
  s.version           = Prequel::Version::STRING
  s.description       = <<-EOD
    An ActiveModel-compatible ORM-like library for storing model instances in
    an in-memory Hash, intended for smallish amounts of mostly read-only data.
  EOD
  s.add_development_dependency "ffaker"
  s.add_development_dependency "minitest"
  s.add_development_dependency "mocha"
  s.add_development_dependency "activesupport"
end