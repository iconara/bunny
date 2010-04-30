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

  it "should raise an exception when reading tables with invalid key markers" do
    table = Qrack::Transport::Buffer.new
    
    table.write :shortstr, "kittens"
    table.write :octet, 107
   
    it = Qrack::Transport::Buffer.new
    it.write :longstr, table.data 
    it.rewind

    lambda{
      it.read :table
    }.should raise_exception 
  end

  it "should raise an exception when invalid types are included in tables" do
    lambda{
      Qrack::Transport::Buffer.new.write :table, {:class => String}
    }.should raise_exception
  end

end


