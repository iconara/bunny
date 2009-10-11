# cli_spec.rb

# Testing Bunny CLI

require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. lib bunny]))
require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. ext trollop]))
require File.expand_path(File.join(File.dirname(__FILE__), %w[.. helpers spec_trollop]))
require 'tempfile'

describe 'Bunny::Commander' do

  it "should display help page when -h option supplied" do
		# Clear out the argument array to get rid of RSpec options
		ARGV.clear
		ARGV.push('-h')
    tmpfile = Bunny::Commander.get_options
		tmpfile.rewind	
		tmpfile.read.should include("Bunny Ruby AMQP client command line interface")
		tmpfile.close
  end

	it "should display help page when --help option supplied" do
		# Clear out the argument array to get rid of RSpec options
		ARGV.clear
		ARGV.push('--help')
    tmpfile = Bunny::Commander.get_options
		tmpfile.rewind	
		tmpfile.read.should include("Bunny Ruby AMQP client command line interface")
		tmpfile.close
  end

	it "should display version details when -v option supplied" do
		ARGV.clear
		ARGV.push('-v')
    version = Bunny::Commander.get_options
		version.should include("bunny_cli v")
	end
	
	it "should display version details when --version option supplied" do
		ARGV.clear
		ARGV.push('--version')
    version = Bunny::Commander.get_options
		version.should include("bunny_cli v")
	end	

	it "should store default options when none are passed in" do
		ARGV.clear
    global_opts = Bunny::Commander.get_options
		global_opts[:user].should == 'guest'
		global_opts[:debug].should == false
		global_opts[:help].should == false
	  global_opts[:host].should == 'localhost'
	  global_opts[:pass].should == 'guest'
		global_opts[:port].should == 5672
		global_opts[:spec].should == '08'
		global_opts[:ssl].should == false
		global_opts[:timeout].should == 5
		global_opts[:verify].should == false
		global_opts[:version].should == false
		global_opts[:vhost].should == '/'
	end
	
	it "should store user name when passed in with -u option" do
		ARGV.clear
		%w[-u freddie].each do |arg|
			ARGV.push(arg)
		end
    global_opts = Bunny::Commander.get_options
		global_opts[:user].should == 'freddie'
	end
	
	it "should store user name when passed in with --user option" do
		ARGV.clear
		%w[--user freddie].each do |arg|
			ARGV.push(arg)
		end
    global_opts = Bunny::Commander.get_options
		global_opts[:user].should == 'freddie'
	end
	
	it "should store user password when passed in with -p option" do
		ARGV.clear
		%w[-p opensesame].each do |arg|
			ARGV.push(arg)
		end
    global_opts = Bunny::Commander.get_options
		global_opts[:pass].should == 'opensesame'
	end
	
	it "should store user password when passed in with --pass option" do
		ARGV.clear
		%w[--pass opensesame].each do |arg|
			ARGV.push(arg)
		end
    global_opts = Bunny::Commander.get_options
		global_opts[:pass].should == 'opensesame'
	end
	
	it "should store host when passed in with -H option" do
		ARGV.clear
		%w[-H dev.baggins.com].each do |arg|
			ARGV.push(arg)
		end
    global_opts = Bunny::Commander.get_options
		global_opts[:host].should == 'dev.baggins.com'
	end
	
	it "should store host when passed in with --host option" do
		ARGV.clear
		%w[--host dev.baggins.com].each do |arg|
			ARGV.push(arg)
		end
    global_opts = Bunny::Commander.get_options
		global_opts[:host].should == 'dev.baggins.com'
	end
	
	it "should store port number when passed in with -P option" do
		ARGV.clear
		%w[-P 7777].each do |arg|
			ARGV.push(arg)
		end
    global_opts = Bunny::Commander.get_options
		global_opts[:port].should == 7777
	end
	
	it "should store port number when passed in with --port option" do
		ARGV.clear
		%w[--port 7777].each do |arg|
			ARGV.push(arg)
		end
    global_opts = Bunny::Commander.get_options
		global_opts[:port].should == 7777
	end
	
	it "should store virtual host when passed in with -V option" do
		ARGV.clear
		%w[-V financial].each do |arg|
			ARGV.push(arg)
		end
    global_opts = Bunny::Commander.get_options
		global_opts[:vhost].should == 'financial'
	end
	
	it "should store virtual host when passed in with --vhost option" do
		ARGV.clear
		%w[--vhost financial].each do |arg|
			ARGV.push(arg)
		end
    global_opts = Bunny::Commander.get_options
		global_opts[:vhost].should == 'financial'
	end
	
	it "should store connection timeout when passed in with -t option" do
		ARGV.clear
		%w[-t 10].each do |arg|
			ARGV.push(arg)
		end
    global_opts = Bunny::Commander.get_options
		global_opts[:timeout].should == 10
	end
	
	it "should store connection timeout when passed in with --timeout option" do
		ARGV.clear
		%w[--timeout 10].each do |arg|
			ARGV.push(arg)
		end
    global_opts = Bunny::Commander.get_options
		global_opts[:timeout].should == 10
	end
	
	it "should store debug flag when passed in as -d option" do
		ARGV.clear
		ARGV.push('-d')
    global_opts = Bunny::Commander.get_options
		global_opts[:debug].should == true
	end
	
	it "should store debug flag when passed in as --debug option" do
		ARGV.clear
		ARGV.push('--debug')
    global_opts = Bunny::Commander.get_options
		global_opts[:debug].should == true
	end
	
	it "should store AMQP spec version when passed in with -S option" do
		ARGV.clear
		%w[-S 0-9-1].each do |arg|
			ARGV.push(arg)
		end
    global_opts = Bunny::Commander.get_options
		global_opts[:spec].should == '0-9-1'
	end
	
	it "should store AMQP spec version when passed in with --spec option" do
		ARGV.clear
		%w[--spec 0-9-1].each do |arg|
			ARGV.push(arg)
		end
    global_opts = Bunny::Commander.get_options
		global_opts[:spec].should == '0-9-1'
	end
	
	it "should store SSL flag when passed in as -s option" do
		ARGV.clear
		ARGV.push('-s')
    global_opts = Bunny::Commander.get_options
		global_opts[:ssl].should == true
	end
	
	it "should store SSL flag when passed in as --ssl option" do
		ARGV.clear
		ARGV.push('--ssl')
    global_opts = Bunny::Commander.get_options
		global_opts[:ssl].should == true
	end
	
	it "should store SSL verify flag when passed in as -r option" do
		ARGV.clear
		ARGV.push('-r')
    global_opts = Bunny::Commander.get_options
		global_opts[:verify].should == true
	end
	
	it "should store SSL verify flag when passed in as --verify option" do
		ARGV.clear
		ARGV.push('--verify')
    global_opts = Bunny::Commander.get_options
		global_opts[:verify].should == true
	end
	
	it "should display an error when an unknown option is supplied" do
		ARGV.clear
		ARGV.push('-z')
	  tmpfile = Bunny::Commander.get_options
		tmpfile.rewind	
		tmpfile.read.should include("Error: unknown argument '-z'.")
		tmpfile.close
	end
	
	it "should display an error when no options or subcommands are supplied" do
		ARGV.clear
		Bunny::Commander.get_options
	  cmd, tmpfile = Bunny::Commander.get_subcommand
		tmpfile.rewind	
		tmpfile.read.should include("Error: No subcommand given. What do you want me to do?.")
		tmpfile.close
	end
	
	it "should display an error when an unknown subcommand is supplied" do
		ARGV.clear
		ARGV.push('bogus')
		Bunny::Commander.get_options
	  cmd, tmpfile = Bunny::Commander.get_subcommand
		tmpfile.rewind	
		tmpfile.read.should include("Error: Unknown subcommand \"bogus\".\nTry --help for help.\n")
		tmpfile.close
	end
	
	it "should raise an error when an unknown user name is supplied" do
		ARGV.clear
		%w[-u bob qdec -n testq].each do |arg|
			ARGV.push(arg)
		end		
		global_opts = Bunny::Commander.get_options
	  cmd, tmpfile = Bunny::Commander.get_subcommand
		lambda { Bunny::Commander.open_connection(global_opts) }.should raise_error(Bunny::ProtocolError)
	end
	
	it "should raise an error when an unknown user password is supplied" do
		ARGV.clear
		
		%w[-p opensesame qdec -n testq].each do |arg|
			ARGV.push(arg)
		end
		
		global_opts = Bunny::Commander.get_options
	  cmd, tmpfile = Bunny::Commander.get_subcommand
		lambda { Bunny::Commander.open_connection(global_opts) }.should raise_error(Bunny::ProtocolError)
	end
	
end