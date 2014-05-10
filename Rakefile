require 'bundler/gem_tasks'
require 'rdoc'
require 'rdoc/task'
require 'rake/testtask'

desc 'Generate documentation for the nagios-plugin gem.'
RDoc::Task.new do |rdoc|
  rdoc.main     = 'README.md'
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = 'nagios-plugin'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include("README.md", "lib/**/*.rb")
end

Rake::TestTask.new do |t|
  t.libs.push "lib"
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

desc "Run tests"
task :default => :test
