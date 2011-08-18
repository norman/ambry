require "rake"
require "rake/testtask"
require "rake/clean"
require "rubygems/package_task"

task :default => :spec
task :test => :spec

CLEAN << %w[pkg doc coverage .yardoc]

begin
  desc "Run SimpleCov"
  task :coverage do
    ENV["coverage"] = "true"
    Rake::Task["spec"].execute
  end
rescue LoadError
end

gemspec = File.expand_path("../ambry.gemspec", __FILE__)
if File.exist? gemspec
  Gem::PackageTask.new(eval(File.read(gemspec))) { |pkg| }
end

Rake::TestTask.new(:spec) { |t| t.pattern = "spec/**/*_spec.rb" }

begin
  require "yard"
  YARD::Rake::YardocTask.new do |t|
    t.options = ["--output-dir=doc"]
    t.options << "--files" << ["Guide.md", "Changelog.md"].join(",")
  end
rescue LoadError
end

desc "Run benchmarks"
task :bench do
  require File.expand_path("../extras/bench", __FILE__)
end
