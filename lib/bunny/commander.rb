module Bunny
	class Commander
		
		SUB_COMMANDS = %w(queue_declare
											queue_delete
											exchange_declare
											exchange_delete)
											
		def self.start
			begin
				# Get global options
				global_opts = get_options()
				# Get subcommand and options
				cmd, cmd_opts = get_subcommands()
				# Process the command
				process_command(global_opts, cmd, cmd_opts)
		  rescue Bunny::CliError => e
		    $stderr.puts e.message
		  end
		end

		def self.get_options
			# Parse the command line options
			global_opts = Trollop::options do
				version "bunny_cli v0.1.0"
				banner <<-EOF 
\n#====================================#
# This is the command line interface #
#    to the Bunny Ruby AMQP client   #
#====================================#

Usage: bunny [options] <subcommand>

Options:

EOF

				opt :help, "Show this message"
			  opt :host, "Host name", :default => 'localhost', :short => 'H'
			  opt :pass, "User password", :default => 'guest'
				opt :port, "Port number", :default => 5672, :short => 'P'
				opt :ssl, "Use SSL encryption", :default => false
				opt :timeout, "Connection timeout in seconds", :default => 5
			  opt :user, "User name", :default => 'guest'
				opt :verify, "Verify server (SSL)", :default => true, :short => 'r'
				opt :version, "Print version and exit"
				opt :vhost, "Virtual host", :default => '/', :short => 'V'
				stop_on SUB_COMMANDS
				text <<-EOF

Subcommands:

  type bunny <subcommand> -h | --help for options

  queue_declare    :  Declare a queue
  queue_delete     :  Delete a queue
  exchange_declare :  Declare an exchange
  exchange_delete  :  Delete an exchange

EOF

			end

		end

		def self.get_subcommands
			# Parse command line subcommands
			cmd = ARGV.shift # get the subcommand
			cmd_opts = case cmd
				when nil
					Trollop::die "No subcommand given. What do you want me to do?"
			  when "queue_declare"
			    Trollop::options do
						opt :name, "Name of queue", :required => true, :type => :string
			      opt :autodelete, "Automatically delete queue when not in use"
						opt :help, "Show this message"
			    end
				when "queue_delete"
			    Trollop::options do
						opt :name, "Name of queue", :required => true, :type => :string
						opt :help, "Show this message"
			    end
			  else
			    Trollop::die "Unknown subcommand #{cmd.inspect}"
			  end

			[cmd, cmd_opts]

		end

		def self.process_command(global_opts, cmd, cmd_opts)
			# Decide what to do
			case cmd
				when 'queue_declare'
					code_string = "q = c.queue(\'#{cmd_opts[:name]}\')"
					code_string += "; puts \"\n================================\""
					code_string += "; puts \"Queue: \#{q.name} created successfully\""
					code_string += "; puts \"================================\n\n\""
				when 'queue_delete'
					code_string = "q = c.queue(\'#{cmd_opts[:name]}\')"
					code_string += "; q.delete()"
					code_string += "; puts \"\n================================\""
					code_string += "; puts \"Queue: \#{q.name} deleted successfully\""
					code_string += "; puts \"================================\n\n\""
				when 'exchange_declare'

				when 'exchange_delete'
			end

			Bunny.run(:host => global_opts[:host],
								:port => global_opts[:port],
								:vhost => global_opts[:vhost],
								:user => global_opts[:user],
								:pass => global_opts[:pass],
								:connect_timeout => global_opts[:timeout]) { |c| eval(code_string, binding, __FILE__, __LINE__) }
		end
		
	end
		
end