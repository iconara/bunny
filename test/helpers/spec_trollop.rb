module Trollop
	# Override the options method. The exits have been commented
	# out to stop the tests halting prematurely
	
	# Get the temporary file library in order to create temp files
	require 'tempfile'
	
	class << self
		def options args = ARGV, *a, &b
		  @p = Parser.new(*a, &b)
		  begin
		    vals = @p.parse args
		    args.clear
		    @p.leftovers.each { |l| args << l }
		    vals
		  rescue CommandlineError => e
				# Output to a temporary file instead of STDERR
		    #$stderr.puts "Error: #{e.message}."
		    #$stderr.puts "Try --help for help."
				errfile = Tempfile.new('errorfile')
				errfile.puts "Error: #{e.message}."
		    errfile.puts "Try --help for help."
				errfile
		    #exit(-1)
		  rescue HelpNeeded
				# Output to a temporary file instead of STDOUT
				#@p.educate
				tmpfile = Tempfile.new('tempfile')
		    @p.educate(tmpfile)
				tmpfile
		    #exit
		  rescue VersionNeeded
				# Return version text instead of outputting it to STDOUT
		    #puts @p.version
				@p.version
		    #exit
		  end
		end
		
		def die arg, msg=nil
			# Output to a temporary file instead of STDERR
			errfile = Tempfile.new('errorfile')
			
		  if msg
		    #$stderr.puts "Error: argument --#{@p.specs[arg][:long]} #{msg}."
				errfile.puts "Error: argument --#{@p.specs[arg][:long]} #{msg}."
		  else
		    #$stderr.puts "Error: #{arg}."
				errfile.puts "Error: #{arg}."
		  end
		  #$stderr.puts "Try --help for help."
			errfile.puts "Try --help for help."
			errfile
		  #exit(-1)
		end
	end
	
end