gem 'rspec', '1.3.0'
require 'spec/rake/spectask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "acts-as-taggable-on"
    gemspec.summary = "ActsAsTaggableOn is a tagging plugin for Rails that provides multiple tagging contexts on a single model."
    gemspec.description = "With ActsAsTaggableOn, you could tag a single model on several contexts, such as skills, interests, and awards. It also provides other advanced functionality."
    gemspec.email = "michael@intridea.com"
    gemspec.homepage = "http://github.com/mbleigh/acts-as-taggable-on"
    gemspec.authors = ["Michael Bleigh"]
    gemspec.files =  FileList["[A-Z]*", "{generators,lib,spec,rails}/**/*"] - FileList["**/*.log"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

desc 'Default: run specs'
task :default => :spec
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList["spec/**/*_spec.rb"]
end

Spec::Rake::SpecTask.new('rcov') do |t|
  t.spec_files = FileList["spec/**/*_spec.rb"]
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec']
end
