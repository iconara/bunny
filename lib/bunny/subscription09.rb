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
	
	class Subscription09 < Qrack::Subscription
	
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
	
	end
	
end