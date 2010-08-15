module Qrack
  class ClientTimeout < Timeout::Error; end
  class ConnectionTimeout < Timeout::Error; end
  class Cancelled < StandardError; end

  # Client ancestor class
  class Client
  end
end
