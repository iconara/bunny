require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. lib bunny]))

Bunny.new.start # FIXME: Hack to get all the requires

describe Qrack::Transport::Buffer do
	[
		[:long, 10],
		[:long, 1272536777],
 		[:table, {:kittens => "awesome", :header2=>1272536777}]

	].each do |type, value|
		it "should read #{value.inspect} as it writes it when encoded as #{type}" do
			it = Qrack::Transport::Buffer.new
			it.write type, value
			it.rewind
			it.read(type).should == value
		end
	end
end
