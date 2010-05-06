require "rubygems"
require 'spec/rake/spectask'
require 'jeweler'

Jeweler::Tasks.new do |gem|
  gem.name = %q{bunny}
  gem.version = "0.6.0"
  gem.authors = ["Chris Duncan"]
  gem.date = %q{2009-10-05}
  gem.description = %q{Another synchronous Ruby AMQP client}
  gem.email = %q{celldee@gmail.com}
  gem.rubyforge_project = %q{bunny-amqp}
  gem.has_rdoc = true
  gem.extra_rdoc_files = [ "README.rdoc" ]
  gem.rdoc_options = [ "--main", "README.rdoc" ]
  gem.homepage = %q{http://github.com/celldee/bunny/tree/master}
  gem.summary = %q{A synchronous Ruby AMQP client that enables interaction with AMQP-compliant brokers/servers.}
end

Jeweler::GemcutterTasks.new

QrackLib = FileList["qrack/lib/**/*.rb"]
LocalQrack = QrackLib.map{|there| there.gsub(/^qrack\/lib/, "lib/qrack") }

QrackLib.zip(LocalQrack).each{|there, here|
  file here => there do 
    sh "cp #{there} #{here}"
  end
}

namespace "qrack" do
  task "clone" do
    unless File.exists? "qrack"
      puts "Where would you like to clone today? (default: http://github.com/celldee/qrack.git)"
      url = STDIN.gets.strip
      url = "http://github.com/celldee/qrack.git" if url.empty?
      sh "git clone #{url} qrack"
    end
  end

  task "update" => "qrack:clone" do
    sh "cd qrack && git pull"
  end

  task "generate" => LocalQrack do
    require "qrack/ext/qparser"
    QParser.new(
      :spec_in => "qrack/ext/amqp-0.8.json",
      :frame_out => "lib/qrack/transport/frame.rb",
      :spec_out => "lib/qrack/protocol/spec.rb"
    ).generate
  end
end

desc "Run AMQP 0-8 rspec tests"
Spec::Rake::SpecTask.new("spec") do |t|
  t.spec_files = FileList["spec/spec_08/*_spec.rb"]
  t.spec_opts = ['--color']
end

