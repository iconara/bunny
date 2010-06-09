require "bunny/util/fifo"

module Qrack
  # Subscription ancestor class
  class Subscription

    attr_accessor :consumer_tag, :delivery_tag, :message_max, :timeout, :ack, :exclusive
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

      @deliveries = Fifo.new 
    end

    def deliver(details)
      if @callback  
        next_delivery = details
        while next_delivery
          callback = @callback
          begin
            @callback = nil 
            callback.call(next_delivery)
            next_delivery = @deliveries.pop
          ensure
            @callback = callback
          end
        end
      else
        @deliveries.push details
      end
    end    
  
    def callback(&blk)
      @callback = blk
    end

    def clear_callback
      @callback = nil
    end

    def clear_backlog
      if @callback 
        while !@deliveries.empty? and client.should_run
          @callback.call(@deliveries.pop)
        end 
      end
    end

    def suppress_callback
      callback = @callback
      @callback = nil
      begin 
        yield
      ensure
        @callback = callback
      end
    end

    def await_delivery
      suppress_callback do
        while @deliveries.empty?
          client.next_frame(:break_on_subscription => true)
        end
      end
    end

    def run(opts={}, &blk)
      opts = opts.dup
      opts[:timeout] ||= timeout
      begin
        callback(&blk) if blk
        client.run(opts)
      ensure
        clear_callback if blk
      end
    end

    def pop
      @deliveries.pop
    end

    def poll
      await_delivery
      pop
    end

    def start(&blk)
      setup_consumer
      run(&blk) if blk
      self
    end
  end
end
