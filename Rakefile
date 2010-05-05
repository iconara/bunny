require 'spec/rake/spectask'

desc "Run AMQP 0-8 rspec tests"
Spec::Rake::SpecTask.new("spec") do |t|
  t.spec_files = FileList["spec/spec_08/*_spec.rb"]
  t.spec_opts = ['--color']
end

namespace "qrack" do
  task "clone" do
    unless File.exists? "qrack"
      puts "Where would you like to clone today? (default: http://github.com/celldee/qrack.git)"
      url = STDIN.gets.strip
      url = "http://github.com/celldee/qrack.git" if url.empty?
      sh "git clone #{url} qrack"
    end
  end

  task "update" do
    sh "cd qrack && git pull"
  end
end
