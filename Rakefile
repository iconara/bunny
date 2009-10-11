desc "Run CLI unit tests"
task :cli do
	require 'spec/rake/spectask'
	puts "===== Running CLI unit tests ====="
	Spec::Rake::SpecTask.new("cli") do |t|
		t.spec_files = FileList["test/unit/cli_spec.rb"]
		t.spec_opts = ['--color']
	end
end

desc "Run AMQP 0-8 unit tests"
task :unit08 do
	require 'spec/rake/spectask'
	puts "===== Running 0-8 unit tests ====="
	Spec::Rake::SpecTask.new("unit08") do |t|
		t.spec_files = FileList["test/unit/spec_08/*_spec.rb"]
		t.spec_opts = ['--color']
	end
end

desc "Run AMQP 0-9 unit tests"
task :unit09 do
	require 'spec/rake/spectask'
	puts "===== Running 0-9 unit tests ====="
	Spec::Rake::SpecTask.new("unit09") do |t|
		t.spec_files = FileList["test/unit/spec_09/*_spec.rb"]
		t.spec_opts = ['--color']
	end
end

desc "Run AMQP 0-8 rspec integration tests"
task :int08 do
	require 'spec/rake/spectask'
	puts "===== Running 0-8 integration tests ====="
	Spec::Rake::SpecTask.new("int08") do |t|
		t.spec_files = FileList["test/integration/spec_08/*_spec.rb"]
		t.spec_opts = ['--color']
	end
end

desc "Run AMQP 0-9 rspec integration tests"
task :int09 do
	require 'spec/rake/spectask'
	puts "===== Running 0-9 integration tests ====="
	Spec::Rake::SpecTask.new("int09") do |t|
		t.spec_files = FileList["test/integration/spec_09/*_spec.rb"]
		t.spec_opts = ['--color']
	end
end

task :default => [ :cli, :unit08 ]