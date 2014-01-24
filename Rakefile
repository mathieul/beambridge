require "bundler/gem_tasks"

require "rake/testtask"

desc "Default: run unit tests."
task default: :test

desc "Test the beambridge plugin."
task :test do
  require 'open3'
  require 'fileutils'

  puts "\nCleaning extension build files and running all specs in native ruby mode..."
  `rm -f ext/*.bundle` && puts("rm -f ext/*.bundle")
  `rm -f ext/*.o` && puts("rm -f ext/*.o")
  Open3.popen3("ruby test/spec_suite.rb") do |stdin, stdout, stderr|
    while !stdout.eof?
      print stdout.read(1)
    end
  end

  puts "\nRunning `make` to build extensions and rerunning decoder specs..."
  Dir.chdir('ext') { `ruby extconf.rb` }
  Dir.chdir('ext') { `make` }
  Open3.popen3("ruby test/decode_spec.rb") do |stdin, stdout, stderr|
    while !stdout.eof?
      print stdout.read(1)
    end
  end
end

begin
  require "rdoc/task"
  desc "Generate documentation for the beambridge plugin."
  RDoc::Task.new(:rdoc) do |rdoc|
    rdoc.rdoc_dir = "rdoc"
    rdoc.title    = "Beambridge"
    rdoc.options << "--line-numbers"
    rdoc.rdoc_files.include("README*")
    rdoc.rdoc_files.include("lib/**/*.rb")
  end
rescue LoadError
  puts "RDoc::Task is not supported on this platform"
end
