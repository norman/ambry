require File.expand_path("../lib/dumb_model/version", __FILE__)

spec = Gem::Specification.new do |s|
  s.name              = "dumb_model"
  s.rubyforge_project = "[none]"
  s.version           = DumbModel::Version::STRING
  s.authors           = "Norman Clarke"
  s.email             = "norman@njclarke.com"
  s.homepage          = "http://github.com/norman/dumb_model"
  s.summary           = ""
  s.description       = ""
  s.platform         = Gem::Platform::RUBY
  s.has_rdoc         = true
  s.test_files       = Dir.glob "test/**/*_test.rb"
  s.files            = `git ls-files`.split("\n").reject {|f| f =~ /^\./}
end
