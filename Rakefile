require 'spec/rake/spectask'

QrackLib = FileList["qrack/lib/**/*.rb"]
LocalQrack = QrackLib.map{|there| there.gsub(/^qrack\/lib/, "lib/qrack") }

QrackLib.zip(LocalQrack).each{|there, here|
  file here => there do 
    sh "cp #{there} #{here}"
  end
}

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
  

  task "generate" => LocalQrack do
    require "qrack/ext/qparser"
    QParser.new(
      :spec_in => "qrack/ext/amqp-0.8.json",
      :frame_out => "lib/qrack/transport/frame.rb",
      :spec_out => "lib/qrack/protocol/spec.rb"
    ).generate
  end
end
