module Qrack
	class ClientTimeout < Timeout::Error; end
  class ConnectionTimeout < Timeout::Error; end

	# Client ancestor class
	class Client
	end
end
