if defined?(EM) && defined?(Fiber)

  module Bunny
    class ClientBase < Qrack::Client
      alias :old_socket :socket
      def socket
        return old_socket if !EM.reactor_running?

        return @socket if @socket and (@status == :connected) and not @socket.closed?
        begin
          @socket = EventedBunnyConnection.connect(@host, @port, @connect_timeout)
        rescue => e
          @status = :not_connected
          raise Bunny::ServerDownError, e.message
        end
        @socket
      end
    end
  end
  
  module EventedBunnyConnection
    include EM::Deferrable

    def self.connect(host, port, timeout, &block)
      fiber = Fiber.current
      conn = EM.connect(host, port, self, host, port) do |conn|
        conn.pending_connect_timeout = timeout
      end
      conn.callback do |*args|
        fiber.resume(args)
      end
      conn.errback do |*args|
        fiber.resume(RuntimeError.new(*args))
      end
      result = Fiber.yield
      if result.is_a?(Exception)
        raise result
      end
      conn

    end

    def initialize(host, port=9090)
      @host, @port = host, port
      @index = 0
      @connected = false
      @buf = ''
    end

    def trap
      begin
        yield
      rescue Exception => ex
        puts ex.message
        puts ex.backtrace.join("\n")
      end
    end

    def close
      trap do
        @connected = false
        close_connection(true)
      end
    end

    def write(data)
      send_data(data)
    end

    def read(size)
      trap do
        if can_read?(size)
          yank(size)
        else
          raise IOError, "Not connected to #{@host}:#{@port}" if closed?
          raise ArgumentError, "Unexpected state" if @size or @callback

          fiber = Fiber.current
          @size = size
          @callback = proc { |data|
            fiber.resume(data)
          }
          Fiber.yield
        end
      end
    end

    def receive_data(data)
      trap do
        (@buf) << data

        if @callback and can_read?(@size)
          callback = @callback
          data = yank(@size)
          @callback = @size = nil
          callback.call(data)
        end
      end
    end

    def closed?
      !@connected
    end

    def connection_completed
      @connected = true
      succeed
    end

    def unbind
      @connected = false if @connected
    end

    def can_read?(size)
      @buf.size >= @index + size
    end

    private

    BUFFER_SIZE = 4096

    def yank(len)
      data = @buf.slice(@index, len)
      @index += len
      @index = @buf.size if @index > @buf.size
      if @index >= BUFFER_SIZE
        @buf = @buf.slice(@index..-1)
        @index = 0
      end
      data
    end
  end
end
