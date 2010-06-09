require "bunny/util/fifo"

describe Fifo do
  it "should report empty only when empty" do
    it = Fifo.new
    it.should be_empty
    it.push "foo"
    it.should_not be_empty
    it.pop
    it.should be_empty
  end

  it "should pop in the right order" do
    it = Fifo.new

    args = ["foo", "bar","baz"]

    args.each{|x| it.push x }
    args.each{|x| x.should == it.pop } 
  end
 
  it "should return nil when popping an empty queue" do
    Fifo.new.pop.should be(nil)    
  end 

  it "should keep working if you interleave pushes and pops" do
    it = Fifo.new

    (1..3).each{|i| it.push i }
    it.pop.should == 1   
    (4..6).each{|i| it.push i }
    it.pop.should == 2   
    it.pop.should == 3 
    it.pop.should == 4
    it.pop.should == 5
    it.pop.should == 6
    it.pop.should == nil
  end

  it "should push a single element correctly" do
    it = Fifo.new.push("foo")

    it.pop.should == "foo"
    it.should be_empty
  end
end
