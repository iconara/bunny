module Bunny
	
=begin rdoc

=== DESCRIPTION:

Asks the server to start a "consumer", which is a transient request for messages from a specific
queue. Consumers last as long as the channel they were created on, or until the client cancels them
with an _unsubscribe_. Every time a message reaches the queue it is passed to the _blk_ for
processing. If error occurs, _Bunny_::_ProtocolError_ is raised.

==== OPTIONS:
* <tt>:consumer_tag => '_tag_'</tt> - Specifies the identifier for the consumer. The consumer tag is
  local to a connection, so two clients can use the same consumer tags. If this option is not
  specified a server generated name is used.
* <tt>:no_ack=> true (_default_) or false</tt> - If set to _true_, the server does not expect an
  acknowledgement message from the client. If set to _false_, the server expects an acknowledgement
  message from the client and will re-queue the message if it does not receive one within a time specified
  by the server.
* <tt>:exclusive => true or false (_default_)</tt> - Request exclusive consumer access, meaning
  only this consumer can access the queue.
* <tt>:nowait => true or false (_default_)</tt> - Ignored by Bunny, always _false_.
* <tt>:timeout => number of seconds - The subscribe loop will continue to wait for
  messages until terminated (Ctrl-C or kill command) or this timeout interval is reached.
* <tt>:message_max => max number messages to process</tt> - When the required number of messages
  is processed subscribe loop is exited.

==== RETURNS:

<tt>details</tt> is a hash containing <tt>{:consumer_tag, :delivery_tag, :redelivered, :exchange, :routing_key}</tt>.
If <tt>:timeout => > 0</tt> is reached Qrack::ClientTimeout is raised

=end
	
	class Subscription09
		attr_accessor :consumer_tag, :message_max, :timeout, :ack, :exclusive
		attr_reader :client, :queue, :message_count
	
		def initialize(client, queue, opts = {})
			@client = client
			@queue = queue
		
			# Get timeout value
			@timeout = opts[:timeout] || nil
		
			# Get maximum amount of messages to process
			@message_max = opts[:message_max] || nil

			# If a consumer tag is not passed in the server will generate one
			@consumer_tag = opts[:consumer_tag] || nil

			# Ignore the :nowait option if passed, otherwise program will hang waiting for a
			# response from the server causing an error.
			opts.delete(:nowait)

			# Do we want to have to provide an acknowledgement?
			@ack = opts[:ack] || nil
			
			# Does this consumer want exclusive use of the queue?
			@exclusive = opts[:exclusive] || false
		
			# Initialize message counter
			@message_count = 0
			
			# Give queue reference to this subscription
			@queue.subscription = self
			
			# Store options
			@opts = opts
		
		end
	
		def setup_consumer
			client.send_frame(
				Qrack::Protocol09::Basic::Consume.new({ :reserved_1 => 0,
																			 					:queue => queue.name,
																	 		 					:consumer_tag => consumer_tag,
																	 		 					:no_ack => !ack,
																								:exclusive => exclusive,
																	 		 					:nowait => false}.merge(@opts))
												)

			method = client.next_method
		
			if method.is_a?(Qrack::Protocol09::Basic::ConsumeOk)
				@consumer_tag = method.consumer_tag
			else
				raise Bunny::ProtocolError,	"Error subscribing to queue #{queue.name}"
			end
		
		end
	
		def start(&blk)
			# Do not process any messages if zero message_max
			if message_max == 0
				return
			end
			
			# Notify server about new consumer
			setup_consumer

			# Start subscription loop
			loop do
			
				begin
					method = client.next_method(:timeout => timeout)
				rescue Qrack::ClientTimeout
					queue.unsubscribe(:consumer_tag => consumer_tag)
					break
				end
		
				# get delivery tag to use for acknowledge
				delivery_tag = method.delivery_tag if @ack
		
				header = client.next_payload

			  # If maximum frame size is smaller than message payload body then message
				# will have a message header and several message bodies				
			  msg = ''
				while msg.length < header.size
					msg += client.next_payload
				end

				# If block present, pass the message info to the block for processing		
				blk.call({:header => header, :payload => msg, :delivery_details => method.arguments, :queue => queue}) if !blk.nil?

				# Increment message counter
				@message_count += 1

				# Exit loop if message_max condition met
				if (!message_max.nil? and message_count == message_max)
					queue.unsubscribe(:consumer_tag => consumer_tag)
					break
				end
			
				# Have to do the ack here because the ack triggers the release of messages from the server
				# if you are using Client#qos prefetch and you will get extra messages sent through before
				# the unsubscribe takes effect to stop messages being sent to this consumer unless the ack is
				# deferred.
				queue.ack(:delivery_tag => delivery_tag) if @ack
		
			end
		
		end
	
	end
	
end