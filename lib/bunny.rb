$:.unshift File.expand_path(File.dirname(__FILE__))

# Ruby standard libraries
%w[socket thread timeout logger].each do |file|
	require file
end


require 'qrack'
require 'bunny/client'
require 'bunny/exchange'
require 'bunny/queue'
require 'bunny/channel'
require 'bunny/subscription'

module Bunny

include Qrack

	class Error < StandardError; end

	class ConnectionError < Bunny::Error; end
	class ForcedChannelCloseError < Bunny::Error; end
	class ForcedConnectionCloseError < Bunny::Error; end
	class MessageError < Bunny::Error; end
	class ProtocolError < Bunny::Error; end
	class ServerDownError < Bunny::Error; end
	class UnsubscribeError < Bunny::Error; end
	class AcknowledgementError < Bunny::Error; end
	
	VERSION = '0.6.0'
	
	# Returns the Bunny version number

	def self.version
		VERSION
	end
	
	# Instantiates new Bunny::Client

	def self.new(opts = {})
		# Set up Bunny according to AMQP spec version required
		spec_version = opts[:spec] || '08'

		# Return client
		setup(spec_version, opts)
	end
	
	# Runs a code block using a short-lived connection

  def self.run(opts = {}, &block)
    raise ArgumentError, 'Bunny#run requires a block' unless block

		# Set up Bunny according to AMQP spec version required
		spec_version = opts[:spec] || '08'
		client = setup(spec_version, opts)
		
    begin
      client.start
      block.call(client)
    ensure
      client.stop
    end

		# Return success
		:run_ok
  end

  include Qrack
	private
	
	def self.setup(version, opts)	
    Bunny::Client.new(opts)
	end

end
